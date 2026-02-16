#!/usr/bin/env bash
set -euo pipefail

# Jump Station Setup - Ubuntu 24.04 LTS

K8S_MINOR="v1.31"
ARGOCD_VERSION="v2.13.3"
KUSTOMIZE_VERSION="v5.5.0"
HELM_VERSION="v3.16.3"
OBSIDIAN_VERSION="1.7.7"

# --- Base packages ---
sudo apt update
sudo apt install -y \
  gnupg lsb-release \
  tree git curl wget jq unzip zip htop tmux \
  build-essential libfuse2t64 \
  openssh-client openssh-server rsync \
  dnsutils iputils-ping traceroute mtr-tiny netcat-openbsd tcpdump nmap \
  lsof vim \
  remmina xclip wl-clipboard

sudo systemctl enable --now ssh

# --- APT repos ---
# VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg >/dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

# kubectl
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

# Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/hashicorp.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null

sudo apt update
sudo apt install -y code kubectl terraform nodejs npm

# --- Binaries ---
curl -fsSL -o /tmp/helm.tar.gz "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz"
tar -xzf /tmp/helm.tar.gz -C /tmp
sudo install -m 555 /tmp/linux-amd64/helm /usr/local/bin/helm

curl -fsSL -o /tmp/argocd "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64"
sudo install -m 555 /tmp/argocd /usr/local/bin/argocd

curl -fsSL -o /tmp/kustomize.tgz "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz"
tar -xzf /tmp/kustomize.tgz -C /tmp
sudo install -m 555 /tmp/kustomize /usr/local/bin/kustomize

sudo npm install -g xo-cli

# --- Desktop apps ---
wget -q -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y /tmp/chrome.deb

mkdir -p ~/apps ~/.local/bin ~/.local/share/applications
wget -q -O ~/apps/Obsidian.AppImage "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/Obsidian-${OBSIDIAN_VERSION}.AppImage"
chmod +x ~/apps/Obsidian.AppImage
ln -sf ~/apps/Obsidian.AppImage ~/.local/bin/obsidian
cat > ~/.local/share/applications/obsidian.desktop << 'EOF'
[Desktop Entry]
Name=Obsidian
Exec=obsidian
Icon=obsidian
Type=Application
Categories=Office;
EOF

# --- Homebrew ---
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc

brew install siderolabs/tap/talosctl

echo "Done. Copy your .vimrc, .bashrc, SSH keys, and set up /srv."
