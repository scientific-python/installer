#!/bin/bash

set -eo pipefail

shopt -s nullglob  # Fail if the following pattern yields no results
echo "Finding matches"
matches=(${PROJECT_NAME}-*-*.*)
echo "Extracting fname"
installer_fname="${matches[0]}"
echo "Found name: ${installer_fname}"
echo "Want name:  ${PKG_INSTALLER_NAME}"
test "$installer_fname" == "$PKG_INSTALLER_NAME"
hash_fname="${PKG_INSTALLER_NAME}.sha256.txt"
shasum -a 256 "$PKG_INSTALLER_NAME" > "$hash_fname"
cat "$hash_fname"
