#!/usr/bin/env bash
set -euo pipefail

KEY="$HOME/.ssh/ltubbackup_ed25519"
DEST_HOST="infutable-jump"
LOGDIR="$HOME/log/rsync"
DATE="$(date +%F)"

STATUS_FILE="/home/bryan/log/rsync/backup-status.txt"

mkdir -p "$LOGDIR"

# pessimistic default
ssh -i "$KEY" ltubbackup@$DEST_HOST \
  "mkdir -p /home/bryan/log/rsync && date -Is | sed 's/$/ FAIL/' > $STATUS_FILE"

backup_dir () {
  local SRC="$1"
  local DEST="$2"
  local NAME="$3"

  rsync -avh --delete --numeric-ids \
    --chmod=Du=rwx,Dg=rwx,Do=,Fu=rw,Fg=rw,Fo= \
    -e "ssh -i $KEY -o IdentitiesOnly=yes" \
    "$SRC/" \
    "ltubbackup@$DEST_HOST:$DEST/" \
    >> "$LOGDIR/${NAME}-${DATE}.log" 2>&1
}

backup_dir "$HOME/Documents" "/home/bryan/Documents/LTUB1234_backup" "documents"
backup_dir "$HOME/Pictures"  "/home/bryan/Pictures/LTUB1234_backup"  "pictures"
backup_dir "$HOME/Desktop"   "/home/bryan/Desktop/LTUB1234_backup"   "desktop"

# mark success
ssh -i "$KEY" ltubbackup@$DEST_HOST \
  "date -Is | sed 's/$/ OK/' > $STATUS_FILE"
