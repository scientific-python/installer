#!/bin/bash

set -eo pipefail

if [[ "$GITHUB_EVENT_NAME" != "pull_request" ]]; then
    pkgutil --check-signature ${PKG_INSTALLER_NAME} || exit 1
fi
# Now extract the package and check that the _conda binary is
# properly signed as well
pkgutil --expand-full ${PKG_INSTALLER_NAME} ./sp-extracted
DIR="./sp-extracted/prepare_installation.pkg/Payload/.scientific-python"
echo "Checking ${DIR} exists"
test -d "$DIR"
ls -al "$DIR"
BINARY="${DIR}/_conda"
echo "Checking ${BINARY} exists"
test -e "${BINARY}"
# TODO - we need to restore code signing.
# echo "Checking ${BINARY} is signed"
# codesign -vd "${BINARY}"
# echo "Checking entitlements of ${BINARY}"
# codesign --display --entitlements - "${BINARY}"
rm -rf ./sp-extracted
