#!/usr/bin/env bash

# Runs deploy-dc.yml with logging.
# Typically invoked from a higher level orchestration script (/scripts/us103/deploy-dc.sh).

# NOTE:  This is a lab; production deployments use tighter controls around credentials and promoting DCs.
#        Deploying vault for creds is a future project
# Usage:
#   cd /srv/repos/infutable-infra/ansible
#   scripts/deploy-dc.sh --limit INFUS103DC03 \
#     -e domain_admin_user='AD\Administrator' \
#     -e domain_admin_password='<password>' \
#     -e dsrm_password='<dsrm_password>'
#
# Logs:
#   /srv/logs/ansible/us103/<hostname>/YYYY-MM-DD_HHMMSS_playbook.log

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ANSIBLE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TS="$(date +%F_%H%M%S)"

#---------------------------------------------------------------
# This loop extracts the hostname from --limit (for log path):
HOST=""
prev=""
for i in "$@"; do
    if [[ "$prev" == "--limit" ]]; then
        HOST="$i"
        break
    fi
    prev="$i"
done

# -z checks that --limit was provided
if [[ -z "$HOST" ]]; then
    echo "Error: --limit <hostname> is required"
    exit 1
fi
#---------------------------------------------------------------

LOG_DIR="/srv/logs/ansible/us103/${HOST,,}"

mkdir -p "$LOG_DIR"

cd "$ANSIBLE_ROOT"

#  Asks for password (clear warning is above from calling script: /scripts/us103/deploy-dc.sh)
ansible-playbook playbooks/windows/deploy-dc.yml --ask-pass "$@" 2>&1 |
    tee "${LOG_DIR}/${TS}_playbook.log"
