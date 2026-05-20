#!/usr/bin/env bash
# 
# Base setup for Packer ubuntu template
# 
# This script:
#   -  Installs updates, packages, custom MOTD banner
#   -  Disables ubuntu MOTD banner
#   -  Copies dotfiles
#   -  Change journald retention
#
#  Prerequisites:
#   -  Env vars used/required (defined in Packer pkr.hcl):
#           DEBIAN_FRONTEND=noninteractive   # no prompts
#           NEEDRESTART_MODE=a               # restart if needed after updating daemon
#           AUTOMATION_USERNAME              # specified in packer

set -euo pipefail

USER_NAME="$AUTOMATION_USERNAME"
USER_HOME="/home/$USER_NAME"
SRC="/tmp/packer-files"

#  Updates and packages:

apt-get update && apt-get upgrade -y
apt-get install -y vim dnsutils jq htop lsof curl unzip

# Disable Ubuntu MOTD news:

systemctl disable --now motd-news.timer || true

# Install dotfiles into /etc/skel and user home:

install -m 0644 -o root -g root "${SRC}/bashrc" /etc/skel/.bashrc
install -m 0644 -o root -g root "${SRC}/vimrc"  /etc/skel/.vimrc

install -m 0644 -o "$USER_NAME" -g "$USER_NAME" "${SRC}/bashrc" "${USER_HOME}/.bashrc"
install -m 0644 -o "$USER_NAME" -g "$USER_NAME" "${SRC}/vimrc"  "${USER_HOME}/.vimrc"

# MOTD banner:

install -m 0755 -o root -g root "${SRC}/motd-banner" /etc/update-motd.d/01-banner

# journald retention:

install -d -m 0755 /etc/systemd/journald.conf.d
install -m 0644 -o root -g root "${SRC}/journald-retention.conf" /etc/systemd/journald.conf.d/00-retention.conf
# verify config:
systemctl restart systemd-journald
