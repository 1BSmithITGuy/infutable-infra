#!/usr/bin/env bash
# Set UFW to default deny incomingexcept SSH from jump host, and allow outgoing

set -euo pipefail

JUMP="$JUMP_HOST_IP"

ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow from "$JUMP" to any port 22 proto tcp comment "ssh from jump host"
ufw --force enable

ufw status verbose
