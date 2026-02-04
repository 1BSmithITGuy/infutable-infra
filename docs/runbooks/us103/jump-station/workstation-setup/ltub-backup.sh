#!/usr/bin/env bash
set -euo pipefail

HOST="$(hostname)"
KEY="$HOME/.ssh/ltubbackup_${HOST}_ed25519"
DEST_HOST="${DEST_HOST:-infutable-jump}"

LOGDIR="$HOME/log/rsync"
DATE="$(date +%F)"
mkdir -p "$LOGDIR"

REMOTE_LOGDIR="/home/bryan/log/rsync"
REMOTE_STATUS_FILE="${REMOTE_LOGDIR}/${HOST}-backup-status.txt"

ssh -i "$KEY" -o IdentitiesOnly=yes "ltubbackup@${DEST_HOST}"   "mkdir -p '${REMOTE_LOGDIR}' && echo "$(date -Is) FAIL" > '${REMOTE_STATUS_FILE}'"

backup_dir () {
  local SRC="$1"
  local DEST="$2"
  local NAME="$3"

  rsync -avh --delete --numeric-ids     --chmod=Du=rwx,Dg=rwx,Do=,Fu=rw,Fg=rw,Fo=     -e "ssh -i $KEY -o IdentitiesOnly=yes"     "$SRC/"     "ltubbackup@${DEST_HOST}:${DEST}/"     >> "${LOGDIR}/${HOST}-${NAME}-${DATE}.log" 2>&1
}

backup_dir "$HOME/Documents" "/home/bryan/Documents/${HOST}_backup" "documents"
backup_dir "$HOME/Pictures"  "/home/bryan/Pictures/${HOST}_backup"  "pictures"
backup_dir "$HOME/Desktop"   "/home/bryan/Desktop/${HOST}_backup"   "desktop"

ssh -i "$KEY" -o IdentitiesOnly=yes "ltubbackup@${DEST_HOST}"   "echo "$(date -Is) OK" > '${REMOTE_STATUS_FILE}'"
