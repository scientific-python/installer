#!/bin/bash -ef

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
source ${SCRIPT_DIR}/extract_version.sh
echo "Building installer locally"
echo "--------------------------"
echo "Version:      ${PKG_INSTALLER_VERSION}"
echo "Recipe:       ${RECIPE_DIR}"
echo "OS:           ${MACHINE}"
echo "Machine:      ${PYMACHINE}"
${SCRIPT_DIR}/run_constructor.sh "$@"
