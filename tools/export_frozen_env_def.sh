#!/bin/bash

set -eo pipefail

source "${SP_ACTIVATE}"
conda list --json > ${SP_INSTALLER_NAME}.env.json
cat ${SP_INSTALLER_NAME}.env.json
