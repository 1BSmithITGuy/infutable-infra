# Hypervisors — US103

Author: Bryan Smith  
Created: 2026-01-27  
Last Updated: 2026-02-18

## Revision History

| Date       | Author | Change Summary                                                     |
|------------|--------|--------------------------------------------------------------------|
| 2026-01-27 | Bryan  | Initial XCP-ng and Proxmox docs (phase 1, separate documents)      |
| 2026-02-18 | Bryan  | Combined into single hypervisors doc; migrated to phase 2 standards |

---

## Overview

Multi-hypervisor environment: two XCP-ng hosts running production workloads and a Proxmox VE host being stood up for phase 2 infrastructure. The plan is to consolidate onto Proxmox.

| Hostname | Platform | Hardware | Role | IP |
|----------|----------|----------|------|----|
| BSUS103VM01 | XCP-ng | Mini PC (AMD Ryzen 5 5500U, 32 GB) | Firewall host | 10.0.0.51 |
| BSUS103VM02 | XCP-ng | Lenovo P520 (Xeon W-2135, 48 GB) | Workloads, Xen Orchestra | 10.0.0.52 |
| BSUS103PX01 | Proxmox VE | Lenovo P520 (Xeon W-2135, 48 GB) | Phase 2 platform | 10.0.0.41 |

10GbE point-to-point link between BSUS103VM02 and BSUS103PX01.

---

## XCP-ng

Two hosts running as separate single-host pools. Xen Orchestra (BSUS103XO01) provides centralized management at 10.0.0.50, hosted on BSUS103VM02.

### BSUS103VM01

| Component | Specification |
|-----------|---------------|
| Model | Kamrui (Mini PC) |
| CPU | AMD Ryzen 5 5500U (4C/4T) |
| RAM | 32 GB |
| Role | Firewall host |

Networking: 2 NICs total. One is dedicated WAN (passed through to OPNsense), the other is a single trunk carrying all VLANs including management.

### BSUS103VM02

| Component | Specification |
|-----------|---------------|
| Model | Lenovo P520 |
| CPU | Intel Xeon W-2135 (6C/12T) |
| RAM | 48 GB |
| Pool | BSUS103POOL01 |
| Role | Workloads, Xen Orchestra |

Same physical NIC layout as BSUS103PX01 (quad NIC card + onboard). Onboard NIC on access port for VLAN 200 management, add-in NICs trunk VM VLANs. XCP-ng interface names may differ from the Proxmox labels documented below.

### BSUS103FW01 (Firewall VM)

The OPNsense firewall is the most critical VM in the environment. It runs on BSUS103VM01.

| Spec | Value |
|------|-------|
| OS | OPNsense (FreeBSD 14.2) |
| vCPUs | 3 |
| RAM | 4 GB |
| Host | BSUS103VM01 |

Network interfaces:

| Device | Network | Gateway IP |
|--------|---------|------------|
| 0 | VLAN200: MGT | 10.0.0.1 |
| 1 | WAN | (ISP assigned) |
| 2 | VLAN10: Srv-ADC | 10.0.1.1 |
| 3 | VLAN15: Srv-ADS | 10.0.1.129 |
| 4 | VLAN20: k8s-mgt | 10.0.2.1 |
| 5 | VLAN06: User-IOT | 10.0.100.1 |
| 6 | VLAN30: k8s-bgp | 10.250.3.1 |

### Xen Orchestra (BSUS103XO01)

| Property | Value |
|----------|-------|
| IP | 10.0.0.50 |
| Host | BSUS103VM02 |
| VLAN | 200 (MGT) |

Provides web-based management for both XCP-ng hosts.

---

## Proxmox VE

### BSUS103PX01

| Component | Specification |
|-----------|---------------|
| Model | Lenovo P520 |
| CPU | Intel Xeon W-2135 (6C/12T) |
| RAM | 48 GB |
| Boot/VM Storage | 2x 500GB NVMe (ZFS mirror) |
| Data Storage | 1TB SATA (planned TrueNAS passthrough) |

### Storage

ZFS mirror on NVMe drives with 4.6GB ARC cache.

### Networking

| Interface | Type | Purpose |
|-----------|------|---------|
| nic0 | Trunk | VLANs 10, 15, 20, 30 |
| nic1 | Trunk | VLANs 10, 15, 20, 30 |
| nic4 (onboard) | Access | VLAN 200 — Management |
| 10GbE | — | Point-to-point link to BSUS103VM02 |

Management traffic is physically separated from VM traffic — nic4 is on an untagged access port (VLAN 200) while nic0/nic1 carry tagged VM VLANs. NIC0 and NIC1 are bonded (active/standby) behind bridge vmbr1. See [proxmox-setup.md](proxmox-setup.md) for configuration details.

### Relevant Logs

```bash
# ZFS pool status
zpool status

# Bond status
cat /proc/net/bonding/bond0
```

### Setup Documentation

- [proxmox-setup.md](proxmox-setup.md) — Installation, NIC bonding, bridge configuration
- [terraform-setup.md](terraform-setup.md) — API token and role for Terraform automation

---

## References

- [XCP-ng Documentation](https://docs.xcp-ng.org/)
- [Xen Orchestra Documentation](https://xen-orchestra.com/docs/)
- [Proxmox VE Administration Guide](https://pve.proxmox.com/pve-docs/pve-admin-guide.html)
- [Proxmox ZFS on Linux](https://pve.proxmox.com/wiki/ZFS_on_Linux)
