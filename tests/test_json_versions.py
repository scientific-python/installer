# Read the JSON and YAML and make sure the version + build match

import fnmatch
import json
import os
import pathlib
import platform
import sys
import yaml

dir_ = pathlib.Path(__file__).parent.parent

match sys.platform:
    case "linux":
        sys_name = "Linux"
        sys_ext = ".sh"
    case "win32":
        sys_name = "Windows"
        sys_ext = ".exe"
    case "darwin":
        sys_ext = ".pkg"
        if platform.machine() == "x86_64":
            sys_name = "macOS_Intel"
        else:
            assert platform.machine() == "arm64"
            sys_name = "macOS_M1"
    case _:
        raise ValueError(f"Platform not recognized: {sys.platform}")

recipe_dir = pathlib.Path(__file__).parents[1] / "recipes" / "scientific-python"
construct_yaml_path = recipe_dir / "construct.yaml"
params = yaml.safe_load(construct_yaml_path.read_text(encoding="utf-8"))
installer_version = params["version"]
project_name = params["name"]
specs = params["specs"]
menu_pkg_name = params['menu_packages'][0]
del params

# Want versions apply to versions specific to this installer.
want_versions = {}
for spec in specs:
    if " =" not in spec or menu_pkg_name not in spec:
        continue
    package_name, package_version_and_build = spec.split(" ")
    print('pkg name', package_name)
    package_version = package_version_and_build.split("=")[1]
    want_versions[package_name] = {"version": package_version}
assert menu_pkg_name in want_versions, \
        f"{menu_pkg_name} missing from want_versions (build str error)"
assert len(want_versions) == 1, len(want_versions)  # more than just the one above

# Extract versions from created environment
fname = dir_ / f"{project_name}-{installer_version}-{sys_name}{sys_ext}.env.json"
assert fname.is_file(), (fname, os.listdir(os.getcwd()))
env_json = json.loads(fname.read_text(encoding="utf-8"))
got_versions = dict()
for package in env_json:
    got_versions[package["name"]] = {
        "version": str(package["version"]),
        "build_string": str(package["build_string"]),
    }

# check versions
for package_name, want in want_versions.items():
    got = got_versions[package_name]
    msg = f"{package_name}: got {repr(got)} != want {repr(want)}"
    assert got["version"] == want["version"], msg
