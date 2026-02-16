# Jump Station

Author: Bryan Smith  
Created: 2026-01-27  
Last Updated: 2026-02-15  

## Revision History

| Date       | Author | Change Summary                                    |
|------------|--------|---------------------------------------------------|
| 2026-01-27 | Bryan  | Initial document                                  |
| 2026-02-02 | Bryan  | Added T490 production laptop setup                |
| 2026-02-15 | Bryan  | Migrated to phase 2 documentation standards       |

---

## Purpose

Architecture and setup documentation for `bsus103jump02`, the Ubuntu jump station and its integrated workstation workflow.

**Background:** After working exclusively in the Linux environment for infrastructure tasks, the workflow migrated from RDP to a native Linux workstation/laptop with the jump station as the backend. The laptop is the interface; data lives on the jump station (VM on Proxmox host BSUS103PX01). Ubuntu Desktop 24.04 LTS was chosen for the jump station to retain the option of RDP/GUI as a fallback.

## Prerequisites

- Proxmox host (BSUS103PX01) operational
- Network access on VLAN 200 (management)
- SSH key authentication configured

> **Note:** This workflow is designed for a personal lab environment to demonstrate architecture patterns, operational discipline, and automation techniques. In a production environment, this design would include centralized identity management, managed secrets, formal monitoring and alerting, immutable backups, and change-control processes. The core patterns remain the same; the controls and tooling would differ.

---

## Setup Guides

| Component | Description |
|-----------|-------------|
| [Server Setup](server-setup/) | Jump station VM configuration (Proxmox, Ubuntu, software, kubectl, SSH) |
| [Base workstation configuration](workstation-setup/base-setup.md) | Post Ubuntu installation steps |
| [Workstation client configuration](workstation-setup/README.md) | Workstation integration with jump station |

---

## Architecture Overview

**Design goals:**
- Avoid RDP for daily work, but retain the option
- Keep credentials, files, and backups centralized on the jump station
- Laptop acts as a thin client; jump station is the source of truth

```
Laptop (UI + editing)
├── VS Code (Remote SSH) → SSH (bryan) → Jump station
├── Terminal (ssh) → SSH (bryan) → Jump station
├── rsync (scheduled) → SSH (ltubbackup) → backup directories
└── Obsidian vault (Syncthing) ⇄ Jump station vault

Jump Station (server)
├── /srv/repos/infutable-infra (active infrastructure work)
├── ~/Documents/<hostname>_backup/
├── ~/Pictures/<hostname>_backup/
├── ~/Desktop/<hostname>_backup/
├── /srv/repos/obsidian (private notes vault)
└── Git snapshots pushed from here
    ├── Passphrase for infutable-infra repo
    └── No passphrase for obsidian repo (notes backup)
```

---

## Design Principles

- Jump station is the source of truth: infrastructure repositories, workstation backups, private notes, Git snapshot source
- Least-privilege automation:
  - `bryan` for interactive admin
  - `ltubbackup` for rsync only
  - Production git repo (infutable-infra) requires passphrase
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
**Destination (Jump Station):** `~/Documents/<hostname>_backup/`, etc.

### VS Code Remote SSH

VS Code runs locally on the laptop, connects via SSH to the jump station. All file operations and terminal commands execute on the jump station filesystem.

### Obsidian Vault + Syncthing

Obsidian runs locally on the laptop for performance. Syncthing replicates the vault bidirectionally with file versioning. Git metadata stays on the jump station only.

### Git Snapshots

Daily automated commits and pushes from the jump station. Captures state at runtime. Provides off-site versioned history without Git on the laptop.

### Login Status Banner

Ubuntu dynamic MOTD displays health status on SSH login:
- **Workstation backup (rsync):** OK if within 72 hours
- **Syncthing status:** OK if heartbeat within 24 hours
- **Obsidian git repo push:** OK/FAIL within 72 hours

![Login status banner](workstation-setup/images/SS-login-banner.png)

---

## Setup Timeline

| Date       | Event                                                    |
|------------|----------------------------------------------------------|
| 2026-01-24 | Ubuntu installed on test laptop, disk layout configured  |
| 2026-01-24 | Bootstrap script run, base software installed            |
| 2026-01-24 | SSH keys configured, kubectl/ArgoCD migrated             |
| 2026-01-24 | GitHub SSH key created, infra repo cloned                |
| 2026-01-25 | Continued with workstation integration setup             |
| 2026-01-26 | Continued with workstation integration setup             |
| 2026-02-02 | Setup T490 production laptop — dual boot Windows/Ubuntu  |
| 2026-02-02 | Configured T490 to access the jump station               |
