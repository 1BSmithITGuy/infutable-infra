# Windows Server 2022 Core Template (Packer Build)

Author: Bryan Smith  
Created: 2026-03-07  
Last Updated: 2026-03-12

## Revision History

| Date       | Author | Change Summary              |
|------------|--------|-----------------------------|
| 2026-03-07 | Bryan  | Initial document            |

---

## Overview

Fully automated Windows Server 2022 Core template built with Packer.

Unlike traditional “golden images” that are patched and reused for long periods, this pipeline rebuilds a fresh template from a trusted Microsoft ISO on each run. The build also:

* Installs required drivers, hypervisor guest agent, and Windows updates.
* Configures WinRM for Ansible, and also firewalls off WinRM to a specific IP (my jump station) for security.
* Enables RDP with NLA.
* Syspreps the image for cloning.

The template can be rebuilt on demand or scheduled (for example after Patch Tuesday) to keep the base image current. It can also serve as the first stage of an update testing pipeline before changes are deployed to development or production servers.

> **With minor adjustments, the same workflow can be adapted to other platforms (AWS, Azure, GCP, VMware, etc.) and to different Windows versions.**

## Build Pipeline Overview

```
Microsoft Server 2022 ISO
        │
        ▼
 Packer Build (Proxmox)
        │
        ├─ Install VirtIO drivers
        ├─ Install QEMU guest agent
        ├─ Bootstrap CU from build-tools ISO
        ├─ Windows Update (remaining updates)
        ├─ Configure WinRM for Ansible
        └─ Cleanup and Sysprep
        │
        ▼
 VM Template
        │
        ▼
Terraform (VM Clone)
        │
        ▼
Ansible Provisioning
        │
        ▼
Domain Join / Configuration
```

## Relevant Logs

- Packer: tee and output to `/srv/logs/packer/windows-server-2022-core`
- WinRM config (VM): `winrm get winrm/config`

> **Example output:**  [examples/packer-build-output.md](examples/packer-build-output.md)

## How to Run

```bash
./build.sh -force
```
- `-force` overwrites the existing template (VM 9000)

## What's in the Template

| Component | Details |
|-----------|---------|
| OS | Windows Server 2022 Datacenter Evaluation (Server Core) |
| Drivers | VirtIO SCSI, NetKVM, Balloon, VioSerial, VioStor |
| Guest Agent | QEMU Guest Agent |
| Updates | Latest offered by Windows Update at build time |
| WinRM | HTTP (5985) and HTTPS (5986) enabled, CredSSP authentication, firewall restricted to jump station (10.0.0.15) |
| RDP | Enabled with NLA |
| Network | DHCP (temporary static build IP removed during sysprep) |

## Provisioner Order

Provisioners run in the following order during the Packer build:

1. `install-virtio-ga.ps1` - VirtIO drivers, QEMU guest agent
2. `bootstrap-ssu.ps1` - Bootstrap Windows Update by installing a recent CU from the build tools ISO
3. `windows-restart` - Reboot for first CU
4. `windows-update` (rgl packer plugin) - Installs remaining updates
5. `configure-ansible.ps1` - WinRM HTTPS and CredSSP via Ansible script, firewall lockdown to jump host
6. `sysprep.ps1` - Cleanup, reset network to DHCP, configure RDP/NLA, generate sysprep unattend,and run sysprep via scheduled ta

## Build Tools ISO

The build uses a custom ISO (`ws2022-build-tools.iso`, volume label `BUILD-TOOLS`) that is mounted during the Packer build.

This ISO contains:

• VirtIO drivers  
• `autounattend.xml` for unattended installation  
• a recent cumulative update (CU) used to bootstrap Windows Update

The Windows Server 2022 evaluation ISO ships with an outdated servicing stack, which can prevent Windows Update from discovering newer updates during the build. Installing a recent CU first ensures the update catalog functions correctly so the remaining updates can be installed automatically.

After this bootstrap step, the template installs all remaining updates via the Packer Windows Update plugin.

### Repacking the ISO (maintenance task)

Run this when `autounattend.xml` changes or a newer CU needs to be updated:
> **Future improvement:** automate update sourcing (e.g., via WSUS or an internal update share) so the template build can pull the latest CU without repacking the ISO; this could also be used to trigger "./build.sh -force" and trigger a template refresh.

```bash
# working directories
mkdir -p /tmp/build-tools-repack /tmp/virtio-mount

# Download the latest stable VirtIO ISO
# https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/
wget -O /tmp/virtio-win.iso https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

# Mount and copy
sudo mount -o loop /tmp/virtio-win.iso /tmp/virtio-mount
cp -a /tmp/virtio-mount/* /tmp/build-tools-repack/
sudo umount /tmp/virtio-mount

# Add autounattend.xml and CU
cp autounattend.xml /tmp/build-tools-repack/
mkdir -p /tmp/build-tools-repack/updates
cp /path/to/<latest-CU>.msu /tmp/build-tools-repack/updates/

# Repack
xorriso -as mkisofs -J -R -o /tmp/ws2022-build-tools.iso -V BUILD-TOOLS /tmp/build-tools-repack/

# Upload to Proxmox
scp /tmp/ws2022-build-tools.iso root@BSUS103PX01:/var/lib/vz/template/iso/

# Cleanup
sudo rm -rf /tmp/build-tools-repack /tmp/virtio-mount /tmp/virtio-win.iso /tmp/ws2022-build-tools.iso
```

### Autounattend.xml Setup

`autounattend.xml` is used for unattended Windows installation during the Packer build.  
The file is embedded in the build tools ISO and therefore is not committed to the repository.

To configure it:

1. Copy `autounattend.xml.example` to `autounattend.xml`
2. Replace `<CHANGE_ME>` with the build-time Administrator password  
   (this must match `admin_password` in `windows-server-2022-core.pkrvars.hcl`)
3. Repack the build tools ISO (see above)

`autounattend.xml` is generated with Windows SIM.

## Network During Build

The build VM uses a temporary static IP so Packer can reliably connect via WinRM during provisioning.

| Setting | Value |
|---------|-------|
| Bridge | vmbr1 (VLAN 15) |
| Static IP | 10.0.1.190/26 |
| Gateway/DNS | 10.0.1.129 |

The static IP is configured in `autounattend.xml` and removed during sysprep.  
Cloned VMs boot with DHCP.

## Files

| File | Purpose |
|------|---------|
| `build.sh` | Wrapper script that runs `packer init` and `packer build` with logging |
| `windows-server-2022-core.pkr.hcl` | Packer build definition |
| `variables.pkr.hcl` | Packer variable declarations |
| `windows-server-2022-core.pkrvars.hcl` | Local variable values (gitignored) |
| `windows-server-2022-core.pkrvars.hcl.example` | Example variable values |
| `autounattend.xml` | Windows unattended install configuration (gitignored, embedded in build tools ISO) |
| `autounattend.xml.example` | Example unattended configuration |
| `scripts/install-virtio-ga.ps1` | Installs VirtIO drivers and QEMU guest agent |
| `scripts/bootstrap-ssu.ps1` | Installs bootstrap cumulative update from build tools ISO |
| `scripts/configure-ansible.ps1` | Configures WinRM for Ansible and restricts firewall access |
| `scripts/sysprep.ps1` | Cleans the system, enables RDP, sets DHCP, and runs sysprep |

## Secrets

Sensitive values are stored in gitignored files and are not committed to the repository.

| File | Contents |
|------|----------|
| `windows-server-2022-core.pkrvars.hcl` | Proxmox API token and build-time Administrator password |
| `autounattend.xml` | Same Administrator password used during unattended installation |

> **Future improvement:** integrate with a secrets management system (HashiCorp Vault?) so credentials are injected at build time rather than stored locally.

## Cloning (Terraform)

VMs are cloned from this template using the `proxmox-windows-vm` Terraform module. Each VM gets its own directory under `terraform/us103/`:

```bash
cd /srv/repos/infutable-infra/terraform/us103/<vm-name>
terraform apply -target=module.<vm-name>
```

The module does a full clone from template 9000, sets hostname and static IP, then hands off to Ansible for role-specific configuration (domain join, DC promotion, CA setup, etc).

## Future Improvements

- Restrict WinRM to a domain service account after domain join (currently uses local Administrator)
- Integrate secrets management (HashiCorp Vault?) for  build credentials
- Integrate WSUS or an internal update source to automate bootstrap CU updates
- Scheduled monthly rebuilds
- Checksums verified

## References

- [Packer Proxmox Builder](https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox)
- [rgl/packer-plugin-windows-update](https://github.com/rgl/packer-plugin-windows-update)
- [Ansible WinRM Setup Script](https://docs.ansible.com/projects/ansible/latest/os_guide/windows_winrm.html#windows-winrm)
- [Microsoft Sysprep Reference](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep-command-line-options)
- [Windows ADK (WSIM)](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install)
