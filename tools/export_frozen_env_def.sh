#!/bin/bash

set -eo pipefail

source "${PKG_ACTIVATE}"
conda list --json > ${PKG_INSTALLER_NAME}.env.json
cat ${PKG_INSTALLER_NAME}.env.json
