Author:  Bryan Smith  
Date:  01/26/2026

# Workstation Setup

> Laptop client configuration for integration with the jump station. See the [parent README](../README.md) for architecture overview.

## NOTES:
* This workflow is designed for a personal lab environment to demonstrate architecture patterns, operational discipline, and automation techniques.

* In a production environment, this design would be adapted to include centralized identity management, managed secrets, formal monitoring and alerting, immutable backups, and change-control processes. The core patterns remain the same; the controls and tooling would differ.

* The notes are detailed to provide a map for future automation.
---

## Step 1 — Workstation Foundations

### Objectives
- Passwordless SSH access
- Stable VS Code Remote-SSH workflow
- Clear separation of identities and responsibilities

### SSH Configuration (Laptop)

**Key created (no passphrase):**
```
~/.ssh/infutable_jump_bryan_ed25519
```

**SSH config entry:**
```
Host infutable-jump
    HostName bsus103jump02
    User bryan
    IdentityFile ~/.ssh/infutable_jump_bryan_ed25519
    IdentitiesOnly yes
    PreferredAuthentications publickey
```

### VS Code
- Uses SSH host alias `infutable-jump`
- No password prompts
- Workspace stored remotely on jump station
- Material Icon Theme enabled

**Result:** Opening VS Code connects to jump station, ready to work.

---

## Step 2 — Laptop to Jump Station Backup Pipeline

### Design Principles
- Push-based backups (laptop initiates)
- Least-privilege service account
- Deterministic permissions
- Human-readable status signal
- No policy baked into backup scripts

---

### Service Account (Jump Station)

**Account:** `ltubbackup`

**Purpose:** Receive rsync backups only

**Group setup:**
```
group: backups
members: bryan, ltubbackup
```

Create the account:
```bash
sudo useradd -m -s /bin/bash ltubbackup
sudo groupadd backups
sudo usermod -aG backups bryan
sudo usermod -aG backups ltubbackup
```

---

### Backup Directories (Jump Station)

```
/home/bryan/Documents/LTUB1234_backup
/home/bryan/Pictures/LTUB1234_backup
/home/bryan/Desktop/LTUB1234_backup
```

**Permissions:**
- Owner: ltubbackup
- Group: backups
- Mode: 2770 (setgid, group-readable)

Create the directories:
```bash
sudo mkdir -p /home/bryan/Documents/LTUB1234_backup
sudo mkdir -p /home/bryan/Pictures/LTUB1234_backup
sudo mkdir -p /home/bryan/Desktop/LTUB1234_backup

sudo chown ltubbackup:backups /home/bryan/Documents/LTUB1234_backup
sudo chown ltubbackup:backups /home/bryan/Pictures/LTUB1234_backup
sudo chown ltubbackup:backups /home/bryan/Desktop/LTUB1234_backup

sudo chmod 2770 /home/bryan/Documents/LTUB1234_backup
sudo chmod 2770 /home/bryan/Pictures/LTUB1234_backup
sudo chmod 2770 /home/bryan/Desktop/LTUB1234_backup
```

Create log directory (writable by ltubbackup):
```bash
mkdir -p /home/bryan/log/rsync
sudo chown ltubbackup:backups /home/bryan/log/rsync
sudo chmod 2770 /home/bryan/log/rsync
```

---

### SSH Key for Backups (Laptop)

**Key:**
```
~/.ssh/ltubbackup_ed25519
```

Generate on the laptop:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/ltubbackup_ed25519 -N ""
```

Copy to jump station:
```bash
ssh-copy-id -i ~/.ssh/ltubbackup_ed25519.pub ltubbackup@bsus103jump02
```

Used explicitly by rsync (not via agent or config).

---

### Backup Script (Laptop)

**Location:** `~/bin/ltub-backup.sh`

See [ltub-backup.sh](ltub-backup.sh) for the full script.

**Behavior:**
- Sets FAIL status before starting
- Backs up Documents, Pictures, Desktop
- Marks OK only after all backups complete
- Logs to `~/log/rsync/`

---

### Backup Status File (Jump Station)

**Location:**
```
/home/bryan/log/rsync/backup-status.txt
```

**Format (single line):**
```
<ISO-8601 timestamp> <OK|FAIL>
```

Example:
```
2026-01-26T12:00:01-05:00 OK
```

This file represents ground truth for backup state.

---

### Cron Scheduling (Laptop)

**Crontab entry:**
```
0 12 * * * /home/bryan/bin/ltub-backup.sh
```

- Runs daily at noon
- No dependency on laptop uptime guarantees
- No cron policy logic

---

## Step 3 — Obsidian Vault Sync + Health Signal

### Objectives
- Keep Obsidian fast and local on the laptop
- Maintain a continuously updated copy on the jump station
- Avoid Git credentials or Git metadata on the laptop
- Provide a simple, inspectable sync health signal

---

### Vault Layout

**Laptop (Syncthing source):**
```
/srv/syncthing/obsidian/vault
```

**Jump Station (Syncthing target, inside Git repo):**
```
/srv/repos/obsidian/
└── vault/
```

Only the `vault/` directory is synchronized. Git metadata (`.git/`, `.gitignore`) is explicitly outside the sync boundary.

---

### Syncthing Configuration

- Advanced - Folder Type:  **Send & Receive**
- File Versioning: **Simple File Versioning**
    -  **Keep Versions:** 3
    -  **Clean out after:** 1 day
    -  **Ceanup interval:**  3600 seconds


Syncthing is used strictly for **live transport**, not backups.

---

### Sync Heartbeat Mechanism

A lightweight heartbeat file confirms laptop participation:

**File:**
```
vault/.syncstamp
```

**Writer:** Laptop cron job writes ISO-8601 timestamp only

**Reader:** Jump station login status script evaluates freshness (24-hour threshold)

This answers one question: "Has the laptop synced recently?"

---

### Laptop Heartbeat Script

**Location:** `~/bin/obsidian-syncstamp.sh`

See [obsidian-syncstamp.sh](obsidian-syncstamp.sh) for the full script.

**Behavior:**
- Writes timestamp to `vault/.syncstamp`
- No networking logic
- No error suppression

**Crontab entry:**
```
*/30 * * * * /home/bryan/bin/obsidian-syncstamp.sh
```

Scheduled every 30 minutes.

---

## Step 4 — Obsidian Git Snapshots

### Objectives
- Maintain off-site, versioned history of notes
- Decouple Git from live editing
- Avoid Git credentials on the laptop
- Accept partial or mid-edit snapshots

---

### Git Model

- Git repository exists only on the jump station:
  ```
  /srv/repos/obsidian
  ```
- Laptop never runs Git for this repo
- Jump station authenticates using a deploy key (no passphrase)

**.gitignore (on jump station):**

```bash 
# Obsidian workspace settings
.obsidian/workspace.json
.obsidian/workspace-mobile.json

# Cache
.obsidian/cache/
.obsidian/plugins/*/data.json

#  syncthing history
.stversions/
# Don't sync attachments if too large

```

**ssh config entry (on jump station):**
```
Host github-obsidian
  HostName github.com
  User git
  IdentityFile ~/.ssh/obsidian_deploy_ed25519
  IdentitiesOnly yes
```
* **Note**:  This is not the whole config file; just an entry.

---

### Snapshot Script (Jump Station)

**Location:** `~/bin/obsidian-git-snapshot.sh`

**Behavior:**
- `git add -A`
- Commit if changes exist
- Push to GitHub
- Write single-line status file

```bash
#!/usr/bin/env bash
set -euo pipefail

REPO="/srv/repos/obsidian"
STATUS_FILE="$HOME/log/obsidian-git/obsidian-git-status.txt"
LOGDIR="$HOME/log/obsidian-git"

mkdir -p "$LOGDIR"

cd "$REPO"

# Check for changes
if git diff --quiet && git diff --cached --quiet; then
    echo "$(date -Is) OK (no changes)" > "$STATUS_FILE"
    exit 0
fi

git add -A
git commit -m "Snapshot $(date +%F_%H%M)"
git push

echo "$(date -Is) OK" > "$STATUS_FILE"
```

**Crontab entry (Jump Station):**
```
0 13 * * * /home/bryan/bin/obsidian-git-snapshot.sh
```

---

### Snapshot Status File (Jump Station)

**Location:**
```
~/log/obsidian-git/obsidian-git-status.txt
```

**Format:**
```
<ISO-8601 timestamp> <OK|FAIL>
```

Used exclusively by the login status banner.

---

## Login Status Banner

### Purpose
Provide immediate, human-readable operational status on login. 

![alt text](images/SS-login-banner.png)

### Implementation
Ubuntu dynamic MOTD script:

```
/etc/update-motd.d/50-infutable-status
```

### Displayed Signals

- Workstation backup (rsync)
- Obsidian sync heartbeat (Syncthing)
- Obsidian Git snapshot status

### Design Properties

- Read-only
- Timestamp-based
