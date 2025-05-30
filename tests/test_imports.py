import argparse
import importlib
import platform
from pathlib import Path
import re

from tqdm import tqdm
import yaml

parser = argparse.ArgumentParser(prog="test_imports")
parser.add_argument("--ignore", nargs="*", help="Modules to ignore", default=[])
parsed = parser.parse_args()


def _import(mod):
    try:
        return importlib.import_module(mod.replace("-", "_"))
    except Exception:
        raise ImportError(f"Could not import {repr(mod)}")


def check_version_eq(package, ver):
    """Check a minimum version."""
    from packaging.version import parse

    if isinstance(package, str):
        package = _import(package)

    package_str = getattr(package, "__version__", getattr(package, "version", None))

    if package_str is None:
        raise ImportError(f"Could not get version for {package}")
    try:
        package_ver = parse(package_str)
    except ValueError:
        raise ImportError(f"Could not parse version {package_str} for {package}")

    assert package_ver >= parse(ver), f"{package}: got {package_ver}, wanted {ver}"


# All related software
construct_path = (
    Path(__file__).parents[1] / "recipes" / "scientific-python" / "construct.yaml"
)
constructs = yaml.load(construct_path.read_text(), Loader=yaml.SafeLoader)
specs = constructs["specs"]

# Now do the importing and version checking
# Conda packages that do not provide a Python importable module.
no_import = {
    "python",
    "mamba",
    "openblas",
    "libblas",
    "qt6-main",
    "uv",
    "git",
    "make",
    "libffi",
    "sp-installer-menu",
}

# PyPI name to import name map.
name_mod_map = {
    # for import test, need map from conda-forge line/name to importable name
    "scikit-learn": "sklearn",
    "scikit-image": "skimage",
    "pillow": "PIL",
    "matplotlib-base": "matplotlib",
    "pyside6": "PySide6",
    "pytest-timeout": "pytest_timeout",
    "pre-commit": "pre_commit",
    "sphinxcontrib-bibtex": "sphinxcontrib.bibtex",
    "sphinxcontrib-youtube": "sphinxcontrib.youtube",
    "pyobjc-core": "Foundation",
    "pyobjc-framework-Cocoa": "Foundation",
    "pyobjc-framework-FSEvents": "Foundation",
}

# Module imports where we cannot or should not check versions, but where we do
# want to check we can import.
bad_ver = {
    "wheelconda",
    "pip",
    "jupyter",
    "termcolor",
    "pytest_timeout",
    "pre_commit",
    "ruff",
    "Foundation",
}

ignore = no_import.union(parsed.ignore)
for spec in tqdm(specs, desc="Imports", unit="module"):
    pkg_name, version = re.split(r"[\s=]+", spec, maxsplit=1)
    mod_name = name_mod_map.get(pkg_name, pkg_name)
    if mod_name in ignore:
        continue
    py_mod = _import(mod_name)
    if mod_name not in bad_ver and "." not in mod_name:
        check_version_eq(py_mod, version)
