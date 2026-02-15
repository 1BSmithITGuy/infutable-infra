# BSUS103PX01 - Proxmox VE Host

## Overview

Proxmox VE hypervisor deployed to evaluate as alternative to XCP-ng. Running multi-hypervisor environment to assess platform options.

## Hardware

| Component | Specification |
|-----------|---------------|
| Model | Lenovo P520 |
| CPU | Intel Xeon W-2135 (6C/12T) |
| RAM | 48 GB |
| Boot/VM Storage | 2x 500GB NVMe (ZFS mirror) |
| Data Storage | 1TB SATA (planned TrueNAS passthrough) |

## Storage

ZFS mirror on NVMe drives with 4.6GB ARC cache. ZFS RAID1 is first-class in Proxmox, avoiding the need for hardware RAID or FakeRAID licensing.

## Networking

| Interface | Purpose |
|-----------|---------|
| nic0 | Trunked VLANs (10, 15, 20, 30) |
| nic1 | Trunked VLANs (10, 15, 20, 30) |
| nic4 | Management - VLAN 200 |

| 10GbE | Point-to-point link to XCP-ng host |

VLANs configured as needed. Management VLAN operational, others added on demand.

# Installation

### 1.  Install Proxmox (Use ZFS mirror RAID1)

### 2.  Create an active/standby bond in Proxmox, and then create a bridge to use the bond

Edit `/etc/network/interfaces`:

1. Add `auto` above the existing `iface` lines for each NIC you want in the bond:

```
auto nic0
iface nic0 inet manual

auto nic1
iface nic1 inet manual
```

2. Add the bond and bridge blocks (these can go anywhere in the file, but keep them before the `source` line at the bottom, and after the NIC definitions they reference):

```
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

![alt text](<./images/Pasted image 20260214200023.png>)