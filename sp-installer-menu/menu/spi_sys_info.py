# This will be invoked by the System Information menu entry

import multiprocessing
import platform
import subprocess
import sys
import tempfile
import webbrowser

from functools import partial
from importlib import import_module


class UnknownPlatformError(Exception):
    """Exception raised for unknown platforms."""


# TODO: find a way to vendor the things that `pyvista.GPUInfo()` can give you
# (renderer name, renderer version...).


def _get_numpy_libs():
    bad_lib = "unknown linalg bindings"
    try:
        from threadpoolctl import threadpool_info
    except Exception as exc:
        return bad_lib + f" (threadpoolctl module not found: {exc})"
    pools = threadpool_info()
    rename = dict(
        openblas="OpenBLAS",
        mkl="MKL",
    )
    for pool in pools:
        if pool["internal_api"] in ("openblas", "mkl"):
            plural = "s" if (pool["num_threads"]) > 1 else ""
            return (
                f"{rename[pool['internal_api']]} "
                f"{pool['version']} with "
                f"{pool['num_threads']} thread{plural}"
            )
    return bad_lib


def _get_total_memory():
    """Return the total memory of the system in bytes."""
    if platform.system() == "Windows":
        o = subprocess.check_output(
            [
                "powershell.exe",
                "(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory",
            ]
        ).decode()
        total_memory = int(o)
    elif platform.system() == "Linux":
        o = subprocess.check_output(["free", "-b"]).decode()
        total_memory = int(o.splitlines()[1].split()[1])
    elif platform.system() == "Darwin":
        o = subprocess.check_output(["sysctl", "hw.memsize"]).decode()
        total_memory = int(o.split(":")[1].strip())
    else:
        raise UnknownPlatformError("Could not determine total memory")

    return total_memory


def _get_cpu_brand():
    """Return the CPU brand string."""
    if platform.system() == "Windows":
        o = subprocess.check_output(
            ["powershell.exe", "(Get-CimInstance Win32_Processor).Name"]
        ).decode()
        cpu_brand = o.strip().splitlines()[-1]
    elif platform.system() == "Linux":
        o = subprocess.check_output(["grep", "model name", "/proc/cpuinfo"]).decode()
        cpu_brand = o.splitlines()[0].split(": ")[1]
    elif platform.system() == "Darwin":
        o = subprocess.check_output(["sysctl", "machdep.cpu"]).decode()
        cpu_brand = o.split("brand_string: ")[1].strip()
    else:
        cpu_brand = "?"

    return cpu_brand


def main():
    """Print system information in a browser window."""
    ljust = 24  # TODO verify
    platform_str = platform.platform()
    # initialize output file
    fid = tempfile.NamedTemporaryFile(
        prefix="SP_sys_info", suffix=".html", delete=False
    )
    out = partial(print, end="", file=fid)

    out("Platform".ljust(ljust) + platform_str + "\n")
    out("Python".ljust(ljust) + str(sys.version).replace("\n", " ") + "\n")
    out("Executable".ljust(ljust) + sys.executable + "\n")
    try:
        cpu_brand = _get_cpu_brand()
    except Exception:
        cpu_brand = "?"
    out("CPU".ljust(ljust) + f"{cpu_brand} ")
    out(f"({multiprocessing.cpu_count()} cores)\n")
    out("Memory".ljust(ljust))
    try:
        total_memory = _get_total_memory()
    except UnknownPlatformError:
        total_memory = "?"
    else:
        total_memory = f"{total_memory / 1024**3:.1f}"  # convert to GiB
    out(f"{total_memory} GiB\n")
    out("\n")
    ljust -= 3  # account for +/- symbols
    libs = _get_numpy_libs()
    unavailable = []
    use_mod_names = (
        "ipykernel",
        "jupyter",
        "jupyterlab",
        "matplotlib",
        "numpy",
        "pandas",
        "pillow",
        "pingouin",
        "plotly",
        "polars",
        "pooch",
        "scikit-image",
        "scipy",
        "seaborn",
        "sklearn",
        "statsmodels",
        "sympy",
        "",
    )
    try:
        unicode = sys.stdout.encoding.lower().startswith("utf")
    except Exception:  # in case someone overrides sys.stdout in an unsafe way
        unicode = False

    for mi, mod_name in enumerate(use_mod_names):
        # upcoming break
        if mod_name == "":  # break
            if unavailable:
                out("└☐ " if unicode else " - ")
                out("unavailable".ljust(ljust))
                out(f"{', '.join(unavailable)}\n")
                unavailable = []
            if mi != len(use_mod_names) - 1:
                out("\n")
            continue
        elif mod_name.startswith("# "):  # header
            mod_name = mod_name.replace("# ", "")
            out(f"{mod_name}\n")
            continue
        pre = "├"
        last = use_mod_names[mi + 1] == "" and not unavailable
        if last:
            pre = "└"
        try:
            mod = import_module(mod_name.replace("-", "_"))
        except Exception:
            unavailable.append(mod_name)
        else:
            mark = "☑" if unicode else "+"

            out(f"{pre}{mark} " if unicode else f" {mark} ")
            out(f"{mod_name}".ljust(ljust))
            out(mod.__version__.lstrip("v"))
            if mod_name == "numpy":
                out(f" ({libs})")
            elif mod_name == "matplotlib":
                out(f" (backend={mod.get_backend()})")

    webbrowser.open(f"file://{fid.name}", new=2)


if __name__ == "__main__":
    main()
