#!/bin/bash

# This script must be marked +x to work correctly with the installer!

set -eo pipefail

logger -p 'install.info' "ℹ️ Running the custom Scientific Python post-install script."

# This doesn't appear to be working: even when the installer is run through
# sudo, SUDO_USER is unset. Leave it here for reference:
# # If we're running through sudo, get user name of the user who invoked sudo
# [ $SUDO_USER ] && USER=$SUDO_USER

# ☠️ This is ugly and bound to break, but seems to do the job for now. ☠️
# Don't name the variable USER, as this one is already set.
USER_FROM_HOMEDIR=`basename $HOME`
SPI_VERSION=`basename "$(dirname $PREFIX)"`
logger -p 'install.info' "📓 USER_FROM_HOMEDIR=$USER_FROM_HOMEDIR"
logger -p 'install.info' "📓 DSTROOT=$DSTROOT"
logger -p 'install.info' "📓 PREFIX=$PREFIX"
logger -p 'install.info' "📓 SPI_VERSION=$SPI_VERSION"

# Guess whether it's a system-wide or only-me install
if [[ "$PREFIX" == "/Applications/"* ]]; then
    APP_DIR=/Applications
    PERMS="sudo"
else
    APP_DIR="$HOME"/Applications
    PERMS=""
fi
SPI_APP_DIR="${APP_DIR}/Scientific-Python"
logger -p 'install.info' "📓 SPI_APP_DIR=$SPI_APP_DIR"

logger -p 'install.info' "ℹ️ Moving root SP .app bundles from $APP_DIR to $SPI_APP_DIR."
$PERMS mv "$APP_DIR"/Scientific\ Python\ *.app "$SPI_APP_DIR"/

logger -p 'install.info' "ℹ️ Fixing permissions of SP .app bundles in $SPI_APP_DIR: new owner will be ${USER_FROM_HOMEDIR}."
$PERMS chown -R "$USER_FROM_HOMEDIR" "$SPI_APP_DIR"

SPI_ICON_PATH="${PREFIX}/Menu/spi_mac_folder_icon.png"
logger -p 'install.info' "ℹ️ Setting custom folder icon for $SPI_APP_DIR and $SPI_APP_DIR_ROOT to $SPI_ICON_PATH."
for destPath in "$SPI_APP_DIR" "$SPI_APP_DIR_ROOT"; do
    logger -p 'install.info' "ℹ️ Setting custom folder icon for $destPath to $SPI_ICON_PATH."
    osascript \
        -e 'set destPath to "'"${destPath}"'"' \
        -e 'set iconPath to "'"${SPI_ICON_PATH}"'"' \
        -e 'use framework "Foundation"' \
        -e 'use framework "AppKit"' \
        -e "set imageData to (current application's NSImage's alloc()'s initWithContentsOfFile:iconPath)" \
        -e "(current application's NSWorkspace's sharedWorkspace()'s setIcon:imageData forFile:destPath options: 0)"
done

# Use Intel packages if the Python binary is x84_64, i.e. not native Apple Silicon
# (This also applies to an Intel binary running on Apple Silicon through Rosetta)
# https://conda-forge.org/docs/user/tipsandtricks.html#installing-apple-intel-packages-on-apple-silicon
DSTBIN=${PREFIX}/bin
PYTHON_PLATFORM=$(${DSTBIN}/conda run python -c "import platform; print(platform.machine())")
PYSHORT=$($DSTBIN/conda run python -c "import sys; print('.'.join(map(str, sys.version_info[:2])))")
if [ "${PYTHON_PLATFORM}" == "x86_64" ]; then
    logger -p 'install.info' "ℹ️ Configuring conda to only use Intel packages"
    ${PREFIX}/bin/conda env config vars set CONDA_SUBDIR=osx-64
fi

logger -p 'install.info' "ℹ️ Configuring Python to ignore user-installed local packages."
${DSTBIN}/conda env config vars set PYTHONNOUSERSITE=1

logger -p 'install.info' "ℹ️ Disabling mamba package manager banner."
${DSTBIN}/conda env config vars set MAMBA_NO_BANNER=1

logger -p 'install.info' "ℹ️ Pinning BLAS implementation to OpenBLAS."
echo "libblas=*=*openblas" >> ${PREFIX}/conda-meta/pinned

logger -p 'install.info' "ℹ️ Fixing permissions of entire conda environment for user=${USER_FROM_HOMEDIR}."
chown -R "$USER_FROM_HOMEDIR" "${PREFIX}"

logger -p 'install.info' "ℹ️ Running spi_sys_info."
${DSTBIN}/conda run -p ${PREFIX} ${PREFIX}/Menu/spi_sys_info.py || true

logger -p 'install.info' "ℹ️ Opening in Finder ${SPI_APP_DIR}/."
open -R "${SPI_APP_DIR}/"
