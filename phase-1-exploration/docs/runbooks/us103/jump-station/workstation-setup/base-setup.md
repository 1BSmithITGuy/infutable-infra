Author:  Bryan Smith  
Date:  02/03/2026

# Base engineer laptop workstation setup

> Prerequisite:  Installation of Ubuntu 24.04



---

## Initial System Update

```bash
sudo apt update
sudo apt upgrade
```

---

## Disable Unnecessary Services

```bash
# Printing
sudo systemctl disable --now cups cups-browsed cups.socket cups.path

# Samba file sharing
sudo systemctl disable --now smbd nmbd

# Modem manager (no cellular modems)
sudo systemctl disable ModemManager

# SSH server (laptop is a client, not a server)
sudo systemctl disable ssh

# GNOME remote desktop
sudo systemctl disable gnome-remote-desktop

# Kernel oops reporter
sudo systemctl disable kerneloops
```

### Mask Tracker / Indexing Services

```bash
systemctl --user mask tracker-miner-fs.service
systemctl --user mask tracker-extract.service
systemctl --user mask tracker-miner-rss.service
systemctl --user mask tracker-miner-fs-3.service
tracker3 reset
```

---

## GNOME Desktop Settings

```bash
# Disable animations
gsettings set org.gnome.desktop.interface enable-animations false

# Dark theme
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'

# 12-hour clock
gsettings set org.gnome.desktop.interface clock-format '12h'

# Disable hot corners
gsettings set org.gnome.desktop.interface enable-hot-corners false

# Don't sleep on AC power
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# Wallpaper (copy your wallpaper to ~/Pictures/wallpaper/ first)
gsettings set org.gnome.desktop.background picture-uri 'file:///home/bryan/Pictures/wallpaper/wallhaven-76v2ke.jpg'
gsettings set org.gnome.desktop.background picture-uri-dark 'file:///home/bryan/Pictures/wallpaper/wallhaven-76v2ke.jpg'
gsettings set org.gnome.desktop.background picture-options 'zoom'
gsettings set org.gnome.desktop.background primary-color '#023c88'
```

### Disable Desktop Icons Extension

```bash
gnome-extensions disable ding@rastersoft.com
```

### XDG User Directories

Edit `~/.config/user-dirs.dirs` and redirect unused directories to `$HOME`:

```
XDG_DESKTOP_DIR="$HOME"
XDG_MUSIC_DIR="$HOME"
XDG_VIDEOS_DIR="$HOME"
```

Then apply:

```bash
xdg-user-dirs-update
```


---

## Install Packages

```bash
sudo apt install -y vim tmux htop curl wireguard xclip gimp remmina
```

---

## Install Applications

### Google Chrome

Download the `.deb` from [google.com/chrome](https://www.google.com/chrome/), then:

```bash
sudo apt install ./google-chrome-stable_current_amd64.deb
```

### Obsidian

```bash
wget -O obsidian.deb "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.11.5/obsidian_1.11.5_amd64.deb"
sudo apt install -y ./obsidian.deb
```

### VS Code

```bash
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg >/dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
sudo apt update
sudo apt install -y code
```

### Node.js

```bash
sudo apt install -y nodejs npm
```

---

## Shell Configuration

Copy [bashrc](bashrc) to `~/.bashrc`.

Highlights:
- Custom Parrot OS-style prompt (red box-drawing characters)
- `ll`, `la`, `l` aliases
- `bsj` alias for quick SSH to jump station
- `$HOME/.local/bin` on PATH

---

## Vim Setup

Copy [vimrc](vimrc) to `~/.vimrc`, then install vim-plug and plugins:

```bash
mkdir -p ~/.vim/autoload
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall
```

Plugins installed:
- `hashivim/vim-terraform` — Terraform syntax + auto-format on save
- `morhetz/gruvbox` — color theme

---

## Claude Code CLI

```bash
curl -fsSL https://claude.ai/install.sh | bash
```
