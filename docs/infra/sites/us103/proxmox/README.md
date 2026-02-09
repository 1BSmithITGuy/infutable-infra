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

## Current State

- Base install complete
- Management network configured
- Jump station VM deployed (bsus103jump02)
- Additional VLANs pending as workloads require them

## Planned

- TrueNAS VM with SATA controller passthrough
- Replication to existing TrueNAS on XCP-ng cluster

## configuration

After installation:

### set NICs as up:

ssh in and run:

``` bash
#  Bring up NICs
ip link set nic0 up
ip link set nic1 up

# Verify - look for "Link detected: Yes"
ethtool nic0
ethtool nic1

```

---

*Deployed: 2026-01-21 – 2026-01-22*
