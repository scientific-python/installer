#!/usr/bin/env python3
""" Show system information as web page.

This will be invoked by the System Information menu entry
"""

import multiprocessing
import platform
import subprocess
import sys
import tempfile
import webbrowser

from importlib import import_module
from importlib.metadata import metadata
from xml.etree import ElementTree


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
    rename = dict(openblas="OpenBLAS", mkl="MKL")
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
    # initialize output file
    outfile = tempfile.NamedTemporaryFile(
        mode="w", prefix="SP_sys_info", suffix=".html", delete=False
    )
    out = list()

    # Platform / Python / Executable
    pyversion = str(sys.version).replace("\n", " ")
    out.append(f"Platform: {platform.platform()}")
    out.append(f"Python: {pyversion}")
    out.append(f"Executable: {sys.executable}")

    # CPU
    try:
        cpu_brand = _get_cpu_brand()
    except Exception:
        cpu_brand = "?"
    out.append(f"CPU: {cpu_brand} ({multiprocessing.cpu_count()} cores)")

    # Memory
    try:
        total_memory = _get_total_memory()
    except UnknownPlatformError:
        total_memory = "?"
    else:
        total_memory = f"{total_memory / 1024**3:.1f}"  # convert to GiB
    out.append(f"Memory: {total_memory} GiB")

    # Packages
    out.append("Key Packages:")
    mod_names = (
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
        "scikit-learn",
        "scipy",
        "seaborn",
        "statsmodels",
        "sympy",
    )
    lookup = {"pillow": "PIL", "scikit-learn": "sklearn", "scikit-image": "skimage"}
    for mod_name in mod_names:
        try:
            mod = import_module(mod_name.replace("-", "_"))
        except Exception:
            mod = import_module(lookup[mod_name])
        line = f"{mod_name} {metadata(mod_name).get('version')}"
        if mod_name == "numpy":
            line += f" ({_get_numpy_libs()})"
        elif mod_name == "matplotlib":
            line += f" (backend={mod.get_backend()})"
        out.append(line)

    if len(sys.argv) > 1 and sys.argv[1] == "nohtml":
        print("\n".join(out), file=sys.stdout)
        return

    # build the output tree
    html = ElementTree.Element("html")
    body = ElementTree.Element("body", attrib={"style": "font-size: x-large;"})
    div = ElementTree.Element("div")
    ul = ElementTree.Element("ul")
    html.append(body)
    body.append(div)
    body.append(ul)
    for line in out:
        is_mod = line.split(" ", maxsplit=1)[0] in mod_names
        node = ElementTree.Element("li" if is_mod else "p")
        node.text = line
        parent = ul if is_mod else div
        parent.append(node)

    ElementTree.ElementTree(html).write(outfile.name, encoding="unicode", method="html")
    webbrowser.open(f"file://{outfile.name}", new=2)


if __name__ == "__main__":
    main()
