Author:  Bryan Smith
Date:  01/25/2026

# Server Setup

> Configuration steps for `bsus103jump02`, the Ubuntu jump station VM.

## NOTE:
* This workflow is designed for a personal lab environment to demonstrate architecture patterns, operational discipline, and automation techniques.

* In a production environment, this design would be adapted to include centralized identity management, managed secrets, formal monitoring and alerting, immutable backups, and change-control processes. The core patterns remain the same; the controls and tooling would differ.

* The notes are detailed to provide a map for future automation.

---

## Base Installation

- **Ubuntu Version:** Ubuntu 24.04.3 LTS Desktop
- **Install Method:** Proxmox VM, manual install via ISO
- **Hostname:** `bsus103jump02`
- **Username:** `bryan`

### Disk Layout

| Disk | Mount Point | Size  | FS   | Notes                        |
|------|-------------|-------|------|------------------------------|
| sda  | `/`         | 45 GB | ext4 | OS root                      |
| sdb  | `/home`     | 16 GB | ext4 | Separate user home directory |
| sdc  | `/srv`      | 16 GB | ext4 | Git repositories and secrets |

---

## Post-Installation Configuration

<details>
<summary><strong>Proxmox Guest Agent</strong></summary>

```bash
sudo apt update
sudo apt install qemu-guest-agent
sudo apt upgrade
sudo reboot
```
</details>

<details>
<summary><strong>Hostname Configuration</strong></summary>

```bash
sudo hostnamectl set-hostname bsus103jump02
```

Update `/etc/hosts` to include the FQDN:
```
127.0.1.1    bsus103jump02.infra.infutable.com bsus103jump02
```
</details>

<details>
<summary><strong>Disk Setup - /home Migration</strong></summary>

Partition and format the new home disk:
```bash
sudo parted /dev/sdb --script mklabel gpt
sudo parted /dev/sdb --script mkpart primary ext4 0% 100%
sudo mkfs.ext4 -L home /dev/sdb1
```

Migrate existing home directory:
```bash
sudo mkdir /mnt/newhome
sudo mount /dev/sdb1 /mnt/newhome
sudo rsync -aAXv /home/ /mnt/newhome/
sudo mv /home /home.old
sudo mkdir /home
```

Add to `/etc/fstab` (use your actual UUID from `blkid`):
```
UUID="<uuid-from-blkid>" /home ext4 defaults 0 2
```

Mount and verify:
```bash
sudo mount -a
df -h | grep home
```
</details>

<details>
<summary><strong>Disk Setup - /srv</strong></summary>

```bash
sudo parted /dev/sdc --script mklabel gpt
sudo parted /dev/sdc --script mkpart primary ext4 0% 100%
sudo mkfs.ext4 -L srv /dev/sdc1
```

Add to `/etc/fstab`:
```
UUID="<uuid-from-blkid>" /srv ext4 defaults 0 2
```
</details>

<details>
<summary><strong>Desktop Tweaks</strong></summary>

```bash
gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.desktop.session idle-delay 600
gsettings set org.gnome.desktop.screensaver lock-delay 0
```

Remove unnecessary applications:
```bash
sudo apt purge -y thunderbird aisleriot gnome-mahjongg gnome-mines gnome-sudoku
sudo apt autoremove -y
```
</details>

---

## Software Installation

Software was installed via bootstrap script ([bootstrap-ubuntu-jump-station.sh](bootstrap-ubuntu-jump-station.sh)):

```bash
./bootstrap-ubuntu-jump-station.sh
```

### Packages Installed

**Base utilities:**
- tree, git, curl, wget, jq, unzip, zip, htop, vim, lsof, tmux
- build-essential, libfuse2t64

**Network tools:**
- dnsutils, iputils-ping, traceroute, mtr-tiny, netcat-openbsd, tcpdump, nmap

**Remote access:**
- openssh-client, openssh-server, rsync, remmina

**Kubernetes & IaC:**
- kubectl (v1.31)
- helm (v3.16.3)
- argocd CLI (v2.13.3)
- kustomize (v5.5.0)
- terraform
- talosctl (via Homebrew)

**Development:**
- VS Code
- nodejs, npm
- xo-cli

**Desktop applications:**
- Google Chrome
- Obsidian (AppImage)

**Package managers:**
- Homebrew (Linux)

---

## Group and Directory Setup

```bash
sudo groupadd gitadmins
sudo usermod -aG gitadmins bryan
```

---

## Data Migration from Previous Jump Station

Sync secrets directory from old jump station:
```bash
sudo rsync -avh --numeric-ids --progress \
  --rsync-path="sudo rsync" \
  bryan@10.0.0.10:/srv/secrets/ /srv/secrets/
```

Copy user configuration:
```bash
rsync -avh --progress bryan@10.0.0.10:/home/bryan/.bashrc ~/
```

---

## Kubernetes Configuration

Sync kubectl configuration from old jump station:
```bash
rsync -avh --progress --exclude "cache/" bryan@10.0.0.10:/home/bryan/.kube/ ~/.kube/
```

Verify contexts:
```bash
kubectl config get-contexts
```

---

## SSH Configuration

<details>
<summary><strong>Migration from Old Jump Station</strong></summary>

```bash
rsync -avh --progress bryan@10.0.0.10:/home/bryan/.ssh/ ~/.ssh/
```
</details>

<details>
<summary><strong>GitHub SSH Key</strong></summary>

Generate a new ED25519 key for this jump station:
```bash
ssh-keygen -t ed25519 -a 64 -f ~/.ssh/github_jump -C "bsus103jump02"
```

Add key to agent:
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github_jump
```

Add the public key to GitHub, then test:
```bash
ssh -T git@github.com
```
</details>

---

## ArgoCD Configuration

Sync ArgoCD CLI config from old jump station:
```bash
rsync -avh --progress bryan@10.0.0.10:/home/bryan/.config/argocd/ ~/.config/argocd/
```

---

## Git Repository Setup

Configure `/srv/repos` with group-based permissions:
```bash
sudo mkdir /srv/repos
sudo chown root:gitadmins /srv/repos
sudo chmod 2770 /srv/repos
```

Clone infrastructure repository:
```bash
cd /srv/repos
git clone git@github.com:1BSmithITGuy/infutable-infra.git
```

---

## vim setup

Copy .vimrc ([.vimrc](.vimrc)) and run:

```bash
mkdir -p ~/.vim/autoload
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  vim +PlugInstall +qall
```


## TODO

- [ ] Deploy SSH keys to infrastructure nodes
- [x] Copy .vimrc configuration
- [ ] Update /etc/hosts with infrastructure nodes
- [x] ~~Set up SSH keys and configure GitHub~~
- [x] ~~Clone Git repositories to /srv/repos~~
- [x] ~~Configure kubectl contexts for clusters~~
- [x] ~~Set up /srv/repos directory structure with proper permissions~~
