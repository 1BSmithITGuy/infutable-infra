#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="/srv/syncthing/obsidian/vault"
STAMP_FILE="$VAULT_DIR/.syncstamp"

date -Is > "$STAMP_FILE"
