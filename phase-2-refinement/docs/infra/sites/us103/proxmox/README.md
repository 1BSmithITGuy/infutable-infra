# BSUS103PX01 — Proxmox VE Host

Author: Bryan Smith  
Created: 2026-01-27  
Last Updated: 2026-02-17

| Date | Change |
|------|--------|
| 2026-01-27 | Initial creation |
| 2026-02-17 | Updated to phase 2 standards, added Terraform setup reference |

## Overview

Proxmox VE hypervisor config and setup. 

## Hardware

| Component | Specification |
|-----------|---------------|
| Model | Lenovo P520 |
| CPU | Intel Xeon W-2135 |
| RAM | 48 GB |
| Boot/VM Storage | 2x 500GB NVMe (ZFS mirror) |
| Data Storage | 1TB SATA (planned TrueNAS passthrough) |

## Storage

ZFS mirror on NVMe drives with 4.6GB ARC cache. 

## Networking

| Interface | Purpose |
|-----------|---------|
| nic0 | Trunked VLANs (10, 15, 20, 30) |
| nic1 | Trunked VLANs (10, 15, 20, 30) |
| nic4 | Management — VLAN 200 |
| 10GbE | Point-to-point link to XCP-ng host |

## Relevant Logs

```bash
# ZFS pool status
zpool status
```

## Installation

### 1. Install Proxmox (Use ZFS mirror RAID1)

### 2. Create an active/standby bond in Proxmox, and then create a bridge to use the bond

Edit `/etc/network/interfaces`:

1. Add `auto` above the existing `iface` lines for each NIC you want in the bond:

```text
auto nic0
iface nic0 inet manual

auto nic1
iface nic1 inet manual
```

2. Add the bond and bridge blocks (these can go anywhere in the file, but keep them before the `source` line at the bottom, and after the NIC definitions they reference):

```text
auto bond0
iface bond0 inet manual
        bond-slaves nic0 nic1
        bond-mode active-backup
        bond-miimon 100
        bond-primary nic0

auto vmbr1
iface vmbr1 inet manual
        bridge-ports bond0
        bridge-stp off
        bridge-fd 0
```

3. Apply the configuration:

```bash
ifreload -a
```

4. Verify the bond is working:

```bash
cat /proc/net/bonding/bond0
```

You should now see the bond and bridge in the GUI, and the active status set to yes:

![Bond and bridge status in Proxmox GUI](<./images/Pasted image 20260214200023.png>)

## See Also

- [Terraform Setup](terraform-setup.md) — API token and role for Terraform automation

## References

- [Proxmox VE Administration Guide](https://pve.proxmox.com/pve-docs/pve-admin-guide.html)
- [Proxmox ZFS on Linux](https://pve.proxmox.com/wiki/ZFS_on_Linux)
- [Proxmox Network Configuration](https://pve.proxmox.com/wiki/Network_Configuration)
