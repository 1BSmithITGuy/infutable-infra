# Ubuntu 24.04 Server Template (Packer Build)

Author: Bryan Smith  
Created: 2026-04-30  
Last Updated: 2026-05-19

## Revision History

| Date       | Author | Change Summary              |
|------------|--------|-----------------------------|
| 2026-04-30 | Bryan  | Initial document            |
| 2026-05-19 | Bryan  | Updates |

---

## Overview

Fully automated Ubuntu 24.04 LTS Server template built with Packer.

The pipeline rebuilds a fresh template from a Canonical ISO on each run. The build also:

* Installs qemu-guest-agent, openssh-server, and base tools (vim, dnsutils, jq, htop, lsof, curl, unzip).
* Installs all updates.
* Locks UFW to SSH from the jump host only.
* Strips instance-specific state (machine-id, SSH host keys, cloud-init state, authorized_keys) so clones boot cleanly.

The template can be rebuilt on demand or scheduled to keep the base image current.

> **Clones from this template require cloud-init data on first boot otherwise they will be inaccessible.** 

> **With minor adjustments, the same workflow can be adapted to other Ubuntu versions and to other platforms (AWS, Azure, GCP, VMware).**

## Build Pipeline Overview

```
Ubuntu 24.04 Server ISO
        │
        ▼
 Packer Build (Proxmox)
        │
        ├─ Autoinstall via cloud-init NoCloud (HTTP)
        ├─ Install qemu-guest-agent, openssh-server
        ├─ Apply Ubuntu updates
        ├─ Baseline (packages, dotfiles, MOTD, journald)
        ├─ Hardening (UFW deny + jump host SSH allow)
        └─ Cleanup (cloud-init, host keys, machine-id, fstrim)
        │
        ▼
 VM Template
        │
        ▼
Terraform (clone)
        │
        ▼
Ansible Provisioning
        │
        ▼
Role-specific Configuration
```

## Logs

- Packer (on Jump Station/server): tee and output to `/srv/logs/packer/ubuntu-24.04-server`
- Cloud-init (in VM): `/var/log/cloud-init.log`, `/var/log/cloud-init-output.log`
- Cloud-init status (in VM): `cloud-init status --long`

> **Example output:**  [examples/packer-build-output.md](examples/packer-build-output.md)

## How to Run

```bash
./build.sh -force
```
- `-force` overwrites the existing template (VM 9001)

## What's in the Template

| Component | Details |
|-----------|---------|
| OS | Ubuntu 24.04 LTS Server, fully patched |
| Guest Agent | qemu-guest-agent |
| Baseline tooling | vim, dnsutils, jq, htop, lsof, curl, unzip |
| Dotfiles | bashrc + vimrc in `/etc/skel/` and `/home/bs-auto/` |
| MOTD | Custom banner (host/IP/kernel/uptime); Canonical news disabled |
| Logging | Journald max size = 500M |
| Firewall | UFW default deny + allow SSH from jump host IP |
| User | bs-auto (NOPASSWD sudo, password locked, key auth only) |
| Disk | Direct partition (no LVM); cloud-init will grow root on clones automatically if disk is resized |
| Network | DHCP at build time; cleaned out for template (no netplan config, SSH host keys, or inbound auth) |

## Provisioners and scripts

Provisioners/scripts run in the following order:

1. `shell` (inline) - Create `/tmp/packer-files` directory
2. `file` - Copy dotfiles and drop-in configs from `files/` into the build VM
3. `baseline.sh` - patches, baseline packages, copy dotfiles into `/etc/skel/` and `/home/bs-auto/`, disable `motd-news.timer`, install journald retention file
4. `hardening.sh` - UFW reset, default-deny inbound, allow SSH from jump host
5. `cleanup.sh` - cloud-init clean; truncate machine-id; remove SSH host keys and user authorized_keys; clear apt cache; journal vacuum; and fstrim

## User and SSH

The template bakes one account: **`bs-auto`** with NOPASSWD sudo, locked password, and key only SSH. 

A single SSH key (`/srv/secrets/ssh-keys/automation/bs-auto/bs-auto_ed25519`) authorizes Packer at build time and Terraform/Ansible at runtime. The pubkey is stripped by `cleanup.sh` and must be supplied again via cloud-init on each clone.

> **Future improvement:** SSH cert authority or Vault-managed dynamic credentials (this is a lab tradeoff). 

## Network During Build

The build VM uses DHCP on VLAN 15. Cleanup removes the netplan config.

| Setting | Value |
|---------|-------|
| Bridge | vmbr1 (VLAN 15) |
| Address | DHCP from VLAN 15 scope (10.0.1.150-175) |
| IP discovery | qemu-guest-agent (reports after first reboot into installed system) |

## Files

| File | Purpose |
|------|---------|
| `build.sh` | Wrapper script that runs `packer init` and `packer build` with logging |
| `ubuntu-24.04-server.pkr.hcl` | Packer build definition |
| `variables.pkr.hcl` | Packer variable declarations |
| `ubuntu-24.04-server.pkrvars.hcl` | Local variable values (gitignored) |
| `ubuntu-24.04-server.pkrvars.hcl.example` | Example variable values |
| `http/user-data.pkrtpl` | Cloud-init user-data (autoinstall) |
| `http/meta-data` | Cloud-init meta-data |
| `files/bashrc`, `files/vimrc` | bash and vim Dotfiles |
| `files/motd-banner` | `/etc/update-motd.d/01-banner` |
| `files/journald-retention.conf` | `/etc/systemd/journald.conf.d/00-retention.conf` |
| `scripts/baseline.sh` | Packages, dotfiles, MOTD, journald retention |
| `scripts/hardening.sh` | UFW default-deny + jump host SSH allow |
| `scripts/cleanup.sh` | Strip per-instance state |

## Secrets

Sensitive values are stored in gitignored files and are not committed to the repository.

| File | Contents |
|------|----------|
| `ubuntu-24.04-server.pkrvars.hcl` | Proxmox API token, automation pubkey, path to private key |
| `/srv/secrets/ssh-keys/automation/bs-auto/bs-auto_ed25519` | Private key for the automation account (build and runtime) |

> **Future improvement:** integrate with a secrets management system (HashiCorp Vault?) so credentials and SSH keys are issued at build time rather than stored locally.

## References

- [Packer Proxmox Builder](https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox)
- [Subiquity Autoinstall Reference](https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html)
- [cloud-init NoCloud Datasource](https://docs.cloud-init.io/en/latest/reference/datasources/nocloud.html)
- [Packer `templatefile` function](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions/file/templatefile)