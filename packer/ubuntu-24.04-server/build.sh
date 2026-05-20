#!/usr/bin/env bash

# Runs packer init and packer build for the Ubuntu 24.04 Server template.
#
# Usage:
#   ./build.sh -force    # replaces existing template if present
#   ./build.sh           # build (will error if template exists)
#
# Logs:
#   /srv/logs/packer/ubuntu-24.04-server/YYYY-MM-DD_HHMM_build.log

set -euo pipefail

LOG_DIR="/srv/logs/packer/ubuntu-24.04-server"
TS="$(date +%F_%H%M)"
VARFILE="ubuntu-24.04-server.pkrvars.hcl"

mkdir -p "$LOG_DIR"

{
  packer init . &&
  packer build "$@" -var-file="$VARFILE" .
} 2>&1 | tee "${LOG_DIR}/${TS}_build.log"
