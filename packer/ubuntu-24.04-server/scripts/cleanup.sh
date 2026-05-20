#!/usr/bin/env bash
# Remove state so the template is generic.
#   -  clear: cloud-init, logs, history, apt cache, Packer build files, 
#           SSH host keys, machine-id
#   -  fstrim
# On first boot, a clone from this template will:
#   - get a fresh machine-id
#   - regenerate SSH host keys

set -euo pipefail

# cloud-init:

cloud-init clean --logs --machine-id --seed
rm -f /etc/netplan/50-cloud-init.yaml

# machine-id:

truncate -s 0 /etc/machine-id

# Remove SSH keys (host keypair and automation account authorized keys):

rm -f /etc/ssh/ssh_host_*
rm -f "/home/${AUTOMATION_USERNAME}/.ssh/authorized_keys"

# Apt cache:
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*

# Packer files:
rm -rf /tmp/packer-files

# Clear Logs/history:
journalctl --rotate
journalctl --vacuum-time=1s

cat /dev/null > /root/.bash_history 2>/dev/null || true
cat /dev/null > "/home/${AUTOMATION_USERNAME}/.bash_history" 2>/dev/null || true
history -c 2>/dev/null || true

# Fstrim (marks blocks as unused):

fstrim -av || true