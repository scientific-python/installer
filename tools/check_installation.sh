#!/bin/bash

# https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#grouping-log-lines

set -eo pipefail
echo "Running tests for PKG_MACHINE=${PKG_MACHINE}"
source "${PKG_ACTIVATE}"

echo "::group::conda info"
conda info
echo "::endgroup::"

echo "::group::conda list"
conda list
echo "::endgroup::"

echo "::group::pip list"
pip list
echo "::endgroup::"

echo "::group::Platform specific tests"
if [[ "$PKG_MACHINE" == "macOS" ]]; then
    echo "Testing that file permissions are set correctly (owned by "$USER", not "root".)"
    # https://unix.stackexchange.com/a/7733
    APP_DIR=$(dirname $PKG_INSTALL_PREFIX)
    [ `ls -ld ${APP_DIR} | awk 'NR==1 {print $3}'` == "$USER" ] || exit 1

    echo "Checking that the installed Python is a binary for the correct CPU architecture"
    if [[ "$MACOS_ARCH" == "Intel" ]]; then
        python -c "import platform; assert platform.machine() == 'x86_64'" || exit 1
    elif [[ "$MACOS_ARCH" == "M1" ]]; then
        python -c "import platform; assert platform.machine() == 'arm64'" || exit 1
    fi

    echo "Checking we have all .app bundles in ${APP_DIR}:"
    ls -al $(dirname $APP_DIR)
    ls -al $(APP_DIR)
    echo "Checking that there are 5 directories"
    test `ls -d ${APP_DIR}/*.app | wc -l` -eq 5 || exit 1
    echo "Checking that the custom icon was set on the project folder in ${APP_DIR}"
    test -f ${APP_DIR}/Icon$'\r' || exit 1
    export SKIP_PKG_KIT_GUI_TESTS=1
elif [[ "$PKG_MACHINE" == "Linux" ]]; then
    echo "Checking that menu shortcuts were created …"
    pushd ~/.local/share/applications
    ls -l || exit 1
    echo "Checking for existence of .desktop files:"
    ls scientific-python*.desktop || exit 1
    test `ls scientific-python*.desktop | wc -l` -eq 5 || exit 1
    echo ""

    # … and patched to work around a bug in menuinst
    echo "Checking that incorrect Terminal entries have been removed"
    test `grep "Terminal=True"  scientific-python*.desktop | wc -l` -eq 0 || exit 1
    test `grep "Terminal=False" scientific-python*.desktop | wc -l` -eq 0 || exit 1
    echo ""

    echo "Checking that Terminal entries are correct…"
    # console, notebooks, sysinfo
    test `grep "Terminal=true"  scientific-python*.desktop | wc -l` -eq 2 || exit 1
    test `grep "Terminal=false" scientific-python*.desktop | wc -l` -eq 3 || exit 1
    # Display their contents
    for f in scientific-python*.desktop; do echo "📂 $f:"; cat "$f"; echo; done
    popd
fi
echo "::endgroup::"

echo "::group::Checking for pinned file..."
test -e "$PKG_INSTALL_PREFIX/conda-meta/pinned"
grep "openblas" "$PKG_INSTALL_PREFIX/conda-meta/pinned"
echo "::endgroup::"

echo "::group::Checking permissions"
OWNER=`ls -ld "$(which python)" | awk '{print $3}'`
echo "Got OWNER=$OWNER, should be $(whoami)"
test "$OWNER" == "$(whoami)"
echo "::endgroup::"

echo "::group::Checking the deployed environment variables were set correctly upon environment activation"
conda env config vars list
if [[ "$PKG_MACHINE" == "macOS" && "$MACOS_ARCH" == "Intel" ]]; then
    python -c "import os; x = os.getenv('CONDA_SUBDIR'); assert x == 'osx-64', f'CONDA_SUBDIR ({repr(x)}) != osx-64'" || exit 1
fi
# TODO: broken on Windows!
if [[ "$PKG_MACHINE" != "Windows" ]]; then
    python -c "import os; x = os.getenv('PYTHONNOUSERSITE'); assert x == '1', f'PYTHONNOUSERSITE ({repr(x)}) != 1'" || exit 1
    python -c "import os; x = os.getenv('MAMBA_NO_BANNER'); assert x == '1', f'MAMBA_NO_BANNER ({repr(x)}) != 1'" || exit 1
fi
echo "::endgroup::"

echo "::group::spi_sys_info"
python -u ${PKG_INSTALL_PREFIX}/Menu/spi_sys_info.py nohtml
echo "::endgroup::"

echo "::group::Trying to import SP and all additional packages included in the installer"
python -u tests/test_imports.py
python -u tests/test_gui.py
python -u tests/test_notebook.py
python -u tests/test_json_versions.py
echo "::endgroup::"
