#!/usr/bin/env bash

# Invoked from higher level orchestration script (/scripts/us103/deploy-dc.sh); please use that script.

# Runs terraform init and terraform apply to create domain controllers.
#
# Usage:
#   ./apply.sh -target='module.dc["dc03"]'  # target a specific DC (do one at a time)
#
# Logs:
#   /srv/logs/terraform/us103/domain-controllers/YYYY-MM-DD_HHMMSS_apply.log

set -euo pipefail

LOG_DIR="/srv/logs/terraform/us103/domain-controllers"
TS="$(date +%F_%H%M%S)"

mkdir -p "$LOG_DIR"

#  NOTE:  no vars passed from root orchestration script
{
  terraform init -upgrade &&
    terraform apply "$@"
} 2>&1 | tee "${LOG_DIR}/${TS}_apply.log"
