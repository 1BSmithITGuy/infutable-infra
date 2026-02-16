# Base Workstation Setup

Author: Bryan Smith  
Created: 2026-02-03  
Last Updated: 2026-02-16  

## Revision History

| Date       | Author | Change Summary                              |
|------------|--------|---------------------------------------------|
| 2026-02-16 | Bryan  | Added tmux + vim session persistence        |
| 2026-02-16 | Bryan  | Migrated to phase 2 documentation standards |
| 2026-02-03 | Bryan  | Initial document                            |

---

## Purpose

Post-installation setup for Ubuntu 24.04 engineer workstation laptops. Covers system hardening, desktop preferences, core packages, and developer tooling.

## Prerequisites

- Fresh installation of Ubuntu 24.04

---

## Step 1: Initial System Update

```bash
sudo apt update
sudo apt upgrade
```

---

## Step 2: Disable Unnecessary Services

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

## Step 3: GNOME Desktop Settings

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

```text
XDG_DESKTOP_DIR="$HOME"
XDG_MUSIC_DIR="$HOME"
XDG_VIDEOS_DIR="$HOME"
```

Then apply:

```bash
xdg-user-dirs-update
```

---

## Step 4: Install Packages

```bash
sudo apt install -y vim tmux htop curl wireguard xclip gimp remmina
```

---

## Step 5: Install Applications

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

## Step 6: Shell Configuration

Copy [bashrc](bashrc) to `~/.bashrc`.

Highlights:
- Custom Parrot OS-style prompt (red box-drawing characters)
- `ll`, `la`, `l` aliases
- `bsj` alias for quick SSH to jump station
- `$HOME/.local/bin` on PATH

---

## Step 7: Vim Setup

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

## Step 8: Tmux + Vim Session Persistence

Tmux-resurrect saves and restores tmux pane layouts (and running programs) across reboots. Tmux-continuum automates the save/restore cycle.

### Install TPM (Tmux Plugin Manager)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### Configure Tmux

Copy [tmux.conf](tmux.conf) to `~/.tmux.conf`.

If tmux is already running, reload the config:

```bash
tmux source-file ~/.tmux.conf
```

Install plugins from inside tmux:

```text
Ctrl-b I
```

TPM will clone tmux-resurrect and tmux-continuum into `~/.tmux/plugins/`.

### Vim Session Commands

The `.vimrc` includes two custom commands for session persistence:

- `:SessionSave` — saves all open buffers/tabs to `~/.vim/sessions/default.vim`
- `:SessionLoad` — restores the saved session

Create the sessions directory:

```bash
mkdir -p ~/.vim/sessions
```

### Usage

**Save your workspace:**
1. In Vim, run `:SessionSave` to capture open files
2. In tmux, press `Ctrl-b Ctrl-s` to save the pane layout

**Restore after reboot:**
- With `@continuum-restore` enabled, starting tmux auto-restores the last saved layout
- In Vim, run `:SessionLoad` to reopen files

Resurrect data is stored in `~/.tmux/resurrect/`.

---

## Step 9: Claude Code CLI

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

---

## Validation

- Open a terminal and confirm the custom prompt renders correctly
- Run `vim` and confirm gruvbox theme loads with no errors
- Run `tmux` and confirm the status bar appears (plugins load on first `Ctrl-b I`)
- Run `code --version` to verify VS Code installed
- Open Chrome, Obsidian — confirm they launch
