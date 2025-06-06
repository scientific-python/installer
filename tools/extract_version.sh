#!/bin/bash -ef

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
export CONSTRUCT_YML=$(find ${SCRIPT_DIR}/../recipes -name construct.yaml)
export RECIPE_DIR=$(dirname $CONSTRUCT_YML)
export PKG_INSTALLER_VERSION=$(grep "^version: .*$" ${CONSTRUCT_YML} | cut -d' ' -f2)
export PROJECT_NAME=$(grep "^name: .*$" ${CONSTRUCT_YML} | cut -d' ' -f2)
export PYSHORT=$(python -c "import sys; print('.'.join(map(str, sys.version_info[:2])))")
UNAME="$(uname -s)"
if [[ "$1" != "" ]] && [[ "$1" != "--dry-run" ]]; then
    MACHINE="$1"
else
    case "${UNAME}" in
        Linux*)      MACHINE=Linux;;
        Darwin*)     MACHINE=macOS;;
        MINGW64_NT*) MACHINE=Windows;;
        MSYS_NT*)    MACHINE=Windows;;
        *)           MACHINE="UNKNOWN:${UNAME}"
    esac
fi
if [[ "$MACHINE" != "macOS" && "$MACHINE" != "Linux" && "$MACHINE" != "Windows" ]]; then
    echo "Unknown machine: ${MACHINE}"
    exit 1
fi
export MACHINE=$MACHINE  # Linux, macOS, Windows, as specified above
export PYMACHINE=$(python -c "import platform; print(platform.machine())")  # x86_64, AMD64, arm64, etc.

if [[ "$PYMACHINE" == "AMD64" ]]; then
    ARTIFACT_ID_SUFFIX="x86_64"
else
    ARTIFACT_ID_SUFFIX=$PYMACHINE
fi

# macOS artifact naming
if [[ "$MACHINE" == "macOS" && "$PYMACHINE" == "x86_64" ]]; then
    MACOS_ARCH="Intel"
elif [[ "$MACHINE" == "macOS" && "$PYMACHINE" == "arm64" ]]; then
    MACOS_ARCH="M1"
else
    MACOS_ARCH=""
fi
export MACOS_ARCH=$MACOS_ARCH

if [[ "$MACHINE" == "macOS" ]]; then
    PKG_INSTALL_PREFIX="/Applications/${PROJECT_NAME}/.scientific-python"
    PKG_INSTALLER_NAME="${PROJECT_NAME}-${PKG_INSTALLER_VERSION}-${MACHINE}_${MACOS_ARCH}.pkg"
    PKG_ACTIVATE="$PKG_INSTALL_PREFIX/bin/activate"
elif [[ "$MACHINE" == "Linux" ]]; then
    PKG_INSTALL_PREFIX="$HOME/${PROJECT_NAME}-Environment"
    PKG_INSTALLER_NAME="${PROJECT_NAME}-${PKG_INSTALLER_VERSION}-${MACHINE}.sh"
    PKG_ACTIVATE="$PKG_INSTALL_PREFIX/bin/activate"
else
    PKG_INSTALL_PREFIX="$HOME/${PROJECT_NAME}-Environment"
    PKG_INSTALLER_NAME="${PROJECT_NAME}-${PKG_INSTALLER_VERSION}-${MACHINE}.exe"
    PKG_ACTIVATE="$PKG_INSTALL_PREFIX/Scripts/activate"
fi

export PKG_INSTALL_PREFIX="$PKG_INSTALL_PREFIX"
export PKG_INSTALLER_NAME="${PKG_INSTALLER_NAME}"
export PKG_ACTIVATE="$PKG_ACTIVATE"
export PKG_INSTALLER_ARTIFACT_ID="${PROJECT_NAME}-${MACHINE}-${ARTIFACT_ID_SUFFIX}"
export PKG_MACHINE="$MACHINE"

echo "Version:       ${PKG_INSTALLER_VERSION}"
test "$PKG_INSTALLER_VERSION" != ""
echo "System Python: ${PYSHORT}"
test "$PYSHORT" != ""
test -d "$SCRIPT_DIR"
echo "Recipe:        ${RECIPE_DIR}"
test "$RECIPE_DIR" != ""
test -d "$RECIPE_DIR"
echo "Installer:     ${PKG_INSTALLER_NAME}"
test "$PKG_INSTALLER_NAME" != ""
echo "Artifact ID:   ${PKG_INSTALLER_ARTIFACT_ID}"
test "$PKG_INSTALLER_ARTIFACT_ID" != ""
echo "Prefix:        ${PKG_INSTALL_PREFIX}"
test "$PKG_INSTALL_PREFIX" != ""
echo "Activate:      ${PKG_ACTIVATE}"
test "$PKG_ACTIVATE" != ""
echo "Machine:       ${PKG_MACHINE}"
test "$PKG_MACHINE" != ""

if [[ "$GITHUB_ACTIONS" == "true" ]]; then
    echo "PKG_INSTALLER_VERSION=${PKG_INSTALLER_VERSION}" | tee -a $GITHUB_ENV
    echo "PKG_INSTALLER_NAME=${PKG_INSTALLER_NAME}" | tee -a $GITHUB_ENV
    echo "PKG_INSTALLER_ARTIFACT_ID=${PKG_INSTALLER_ARTIFACT_ID}" | tee -a $GITHUB_ENV
    echo "PKG_INSTALL_PREFIX=${PKG_INSTALL_PREFIX}" | tee -a $GITHUB_ENV
    echo "RECIPE_DIR=${RECIPE_DIR}" | tee -a $GITHUB_ENV
    echo "PKG_ACTIVATE=${PKG_ACTIVATE}" | tee -a $GITHUB_ENV
    echo "NSIS_SCRIPTS_RAISE_ERRORS=1" | tee -a $GITHUB_ENV
    echo "PKG_MACHINE=${PKG_MACHINE}" | tee -a $GITHUB_ENV
    echo "MACOS_ARCH=${MACOS_ARCH}" | tee -a $GITHUB_ENV
    if [[ "$GITHUB_EVENT_NAME" == "pull_request" ]]; then
        echo "ARTIFACT_RETENTION_DAYS=5" | tee -a $GITHUB_ENV
    else
        echo "ARTIFACT_RETENTION_DAYS=90" | tee -a $GITHUB_ENV
    fi
fi
