#!/usr/bin/env bash

# Runs packer init and packer build for the Windows Server 2022 template.
#
# Usage:
#   ./build.sh -force    # replaces existing template if present
#   ./build.sh           # build (will error if template exists)
#
# Logs:
#   /srv/logs/packer/windows-server-2022-core/YYYY-MM-DD_HHMM_build.log


set -euo pipefail

LOG_DIR="/srv/logs/packer/windows-server-2022-core"
TS="$(date +%F_%H%M)"
VARFILE="windows-server-2022-core.pkrvars.hcl"

mkdir -p "$LOG_DIR"

{
  packer init . &&
  packer build "$@" -var-file="$VARFILE" .
} 2>&1 | tee "${LOG_DIR}/${TS}_build.log"
