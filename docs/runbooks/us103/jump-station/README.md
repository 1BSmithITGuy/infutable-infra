Author:  Bryan Smith  
Date:  01/27/2026

# Jump Station

> Architecture and setup documentation for `bsus103jump02`, the Ubuntu jump station and its integrated workstation workflow.

**Background:** I previously used RDP from a Windows laptop to access a Linux jump station. After finding myself working exclusively in the Linux environment for infrastructure tasks, I migrated to a native Linux workstation/laptop with a jump station as the backend; the laptop is essentially just the interface, and the data is on the jump station (virtual machine on a Proxmox host). Ubuntu Desktop 24.04 LTS was chosen as the jump station instead of Ubuntu Server so I can retain the option of RDP/GUI, which allows for a fallback if the laptop/workstation crashes as well as fallback access from my Windows laptop when needed (e.g., video conferencing demos).

## NOTES:
* This workflow is designed for a personal lab environment to demonstrate architecture patterns, operational discipline, and automation techniques.

* In a production environment, this design would be adapted to include centralized identity management, managed secrets, formal monitoring and alerting, immutable backups, and change-control processes. The core patterns remain the same; the controls and tooling would differ.

* The notes are detailed to provide a map for future automation.

---

## Setup Guides

| Component | Description |
|-----------|-------------|
| [Server Setup](server-setup/) | Jump station VM configuration (Proxmox, Ubuntu, software, kubectl, SSH) |
| [Base workstation configuration](workstation-setup/base-setup.md) | Post Ubuntu installation steps |
| [Jumpstation client (workstation) configuration](workstation-setup/README.md) | Workstation integration with Jump station

---

## Architecture Overview

**Purpose:** Centralize infrastructure work, backups, and notes on the jump station while using a laptop as the primary interface.

**Design goals:**
- Avoid RDP for daily work, but retain the option
- Keep important credentials, files, and backups centralized on the jump station

---

## High-Level Architecture

```
Laptop (UI + editing)
├── VS Code (Remote SSH) → SSH (bryan) → Jump station
├── Terminal (ssh) → SSH (bryan) → Jump station
├── rsync (scheduled) → SSH (ltubbackup) → backup directories
└── Obsidian vault (Syncthing) ⇄ Jump station vault

Jump Station (server)
├── /srv/repos/infutable-infra (active infrastructure work)
├── ~/Documents/LTUB1234_backup/
├── ~/Pictures/LTUB1234_backup/
├── ~/Desktop/LTUB1234_backup/
├── /srv/repos/obsidian (private notes vault)
└── Git snapshots pushed from here
    ├── Passphrase for infutable-infra repo
    └── No passphrase for obsidian repo (notes backup)
```

---

## Design Principles

- Laptop is practically a thin client; files are stored on jump station
- Jump station is the source of truth:
  - Infrastructure repositories
  - Workstation backups
  - Private notes vault copy
  - Git snapshot source
- Least-privilege automation:
  - `bryan` for interactive admin
  - `ltubbackup` for rsync only
  -  Production git repo (infutable-infra) requires passphrase
- Each tool has one job:
  - SSH: access and control
  - rsync: one-way workstation backup
  - Syncthing: live notes/Obsidian transport
  - Git: off-site, versioned archive

---

## Component Summary

### Workstation Backups (rsync)

Push-based backup of laptop directories to jump station. Runs daily at noon from the laptop. Service account `ltubbackup` has write access only to backup directories.

**Source (Laptop):** `~/Documents/`, `~/Pictures/`, `~/Desktop/`

**Destination (Jump Station):** `~/Documents/LTUB1234_backup/`, etc.

### VS Code Remote SSH

VS Code runs locally on the laptop, connects via SSH to the jump station. All file operations and terminal commands execute on the jump station filesystem.

### Obsidian Vault + Syncthing

Obsidian runs locally on the laptop for performance. Syncthing replicates the vault (bidirectional sync, file versioning). Git metadata stays on the jump station only.

### Git Snapshots

Daily automated commits and pushes from the jump station. Captures whatever state exists at runtime. Provides off-site versioned history without Git on the laptop.

### Login Status Banner

Ubuntu dynamic MOTD displays health status on SSH login:
- **Workstation docs, pictures, desktop (rsync):** OK if within 72 hours
- **Syncthing status:** OK if heartbeat within 24 hours
- **Obsidian git repo push status:** OK/FAIL Within 72 hours

![alt text](workstation-setup/images/SS-login-banner.png)

---

## Setup Timeline

| Date       | Event                                           |
|------------|-------------------------------------------------|
| 01-24-2026 | Ubuntu installed on test laptop, disk layout configured        |
| 01-24-2026 | Bootstrap script run, base software installed   |
| 01-24-2026 | SSH keys configured, kubectl/ArgoCD migrated    |
| 01-24-2026 | GitHub SSH key created, infra repo cloned       |
| 01-25-2026 | Continued with workstation integration setup    |
| 01-26-2026 | Continued with workstation integration setup    |
| 02-02-2026 | setup T490 production laptop - dual boot windows/Ubuntu |
| 02-02-2026 | Configured T490 to access the jump station |
