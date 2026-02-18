# US103 Site Infrastructure

Author: Bryan Smith  
Created: 2026-01-27  
Last Updated: 2026-02-18

## Revision History

| Date       | Author | Change Summary                                              |
|------------|--------|-------------------------------------------------------------|
| 2026-01-27 | Bryan  | Initial document (phase 1)                                  |
| 2026-02-18 | Bryan  | Migrated to phase 2 standards; updated VLAN 10/15 subnets   |

---

## Overview

Physical infrastructure at site US103 (Easton, PA). Two racks, multi-hypervisor environment (Proxmox + XCP-ng), OPNsense firewall.

> **Note:** Network configuration data is planned for migration to NetBox for centralized IPAM/DCIM management.

## Physical Layout

The infrastructure is split across two racks:

- **Telco Rack** — Network equipment (firewall host, switches, Reolink NVR)
![Telco rack](images/telco-rack.png)

- **Server Rack** — Compute infrastructure (2x Lenovo P520 servers, Cisco Catalyst 3750x)
  The Cisco 3750x is not currently in use due to power consumption; the TP-Link switches provide sufficient L2 functionality.
![Server rack](images/server-rack.png)

- **Overall Site View**
![Site view](images/site-view.png)

## Hardware Summary

### Compute

| Hostname | Role | Hardware | CPU | RAM | Location |
|----------|------|----------|-----|-----|----------|
| BSUS103VM01 | XCP-ng Host (firewall, lightweight VMs) | Mini PC | AMD Ryzen 5 5500U (4C/4T) | 32 GB | Telco Rack |
| BSUS103VM02 | XCP-ng Host (workloads) | Lenovo P520 | Intel Xeon W-2135 (6C/12T) | 48 GB | Server Rack |
| BSUS103PX01 | Proxmox Host | Lenovo P520 | Intel Xeon W-2135 (6C/12T) | 48 GB | Server Rack |

### Network

| Hostname | Role | Hardware | IP Address | Location |
|----------|------|----------|------------|----------|
| BSUS103FW01 | Firewall/Router | OPNsense VM (FreeBSD 14.2) | 10.0.0.1 | BSUS103VM01 |
| BSUS103SW0801 | Collapsed core/edge switch | TP-Link TL-SG108PE | 10.0.0.60 | Telco Rack |
| BSUS103SW1601 | Access switch | TP-Link TL-SG1016DE | 10.0.0.59 | Server Rack |
| BSUS103WAP01 | Wireless AP | TP-Link EAP610 | 10.0.0.61 | Telco Rack |

### Management

| Hostname | Role | Hardware | IP Address |
|----------|------|----------|------------|
| BSUS103XO01 | Xen Orchestra | VM on XCP-ng | 10.0.0.50 |
| bsus103jump02 | Jump Station | Ubuntu 24.04 VM | 10.0.0.15 |

## Network Architecture
**NOTE:**  This may not render properly on a mobile browser.

```
                                    ┌──────────────────┐
                                    │    Internet      │
                                    └────────┬─────────┘
                                             │
                                    ┌────────▼─────────┐
                                    │   BSUS103FW01    │
                                    │    (OPNsense)    │
                                    │    10.0.0.1      │
                                    └────────┬─────────┘
                                             │
                              ┌──────────────▼──────────────┐
                              │       BSUS103SW0801         │
                              │  Collapsed core/edge switch │
                              │         10.0.0.60           │
                              └──────────────┬──────────────┘
                                             │
                    ┌────────────────────────┼────────────────────────┐
                    │                        │                        │
           ┌────────▼────────┐      ┌────────▼────────┐      ┌────────▼────────┐
           │  BSUS103WAP01   │      │  BSUS103SW1601  │      │   BSUS103VM01   │
           │  (Wireless AP)  │      │   Access Switch │      │(XCP-ng/firewall)│
           │   10.0.0.61     │      │    10.0.0.59    │      │    10.0.0.51    │
           └─────────────────┘      └────────┬────────┘      └─────────────────┘
                                             │
                              ┌──────────────┼──────────────┐
                              │                             │
                     ┌────────▼────────┐            ┌───────▼────────┐
                     │  BSUS103VM02    │            │  BSUS103PX01   │
                     │   (XCP-ng)      │            │   (Proxmox)    │
                     │   10.0.0.52     │            │   10.0.0.41    │
                     └─────────────────┘            └────────────────┘
```

## VLAN Architecture

| VLAN ID | Name | Subnet | Purpose |
|---------|------|--------|---------|
| 6 | User-IOT | 10.0.100.0/24 | Home/IoT devices (not part of lab) |
| 10 | Srv-ADC | 10.0.1.0/26 | Active Directory Domain Controllers |
| 15 | Srv-ADS | 10.0.1.128/26 | AD-connected services (WSUS, CA, admin tools) |
| 20 | k8s-mgt | 10.0.2.0/27 | Kubernetes node management (east-west traffic) |
| 30 | k8s-bgp | 10.250.3.0/27 | Kubernetes BGP peering (north-south ingress) |
| 200 | MGT | 10.0.0.0/26 | Infrastructure management |

### Subnet Design Notes

VLANs 10 and 15 were expanded from /29 to /26 on 2026-02-18. The address plan leaves 10.0.1.64/26 unallocated between the two VLANs, allowing either to expand to a /25 without renumbering existing hosts.

## BGP Overview

The firewall (BSUS103FW01) runs FRR and peers with Kubernetes clusters via BGP for service IP advertisement.

| Cluster | ASN | Peers | Advertised Prefixes |
|---------|-----|-------|---------------------|
| us103-talos01 | 65001 | 10.250.3.3, 10.250.3.4 | 172.25.200.0/27, 172.25.250.0/27 |
| us103-k3s01 | 65002 | 10.250.3.5 | 172.25.250.32/27 |
| us103-kubeadm01 | 65003 | 10.250.3.22, 10.250.3.23 | 172.25.200.96/27, 172.25.250.96/27 |

Firewall ASN: **65000**

BFD is enabled for fast failover detection. See [firewall/README.md](firewall/README.md) for full BGP configuration.

> The BGP peers above reflect the phase 1 cluster deployments. These will be updated when the phase 2 cluster (us103-rockyk3s01) is deployed.

## Address Plan — Supernets

| Supernet | Scope | Description |
|----------|-------|-------------|
| 10.0.0.0/22 | Site | US103 aggregate (all internal addressing) |
| 10.0.0.0/24 | Backplane | Virtualization, switches, infrastructure management |
| 10.0.1.0/24 | Platform | Active Directory and platform services |
| 10.0.2.0/27 | Kubernetes | K8s node addressing (east-west) |
| 10.250.3.0/27 | BGP Peering | K8s BGP peering (north-south) |
| 172.25.200.0/26 | BGP VIPs | Infrastructure/management services |
| 172.25.250.0/26 | BGP VIPs | Application/user-facing services |

### BGP VIP Allocations

| Cluster | Infra VIPs | App VIPs |
|---------|------------|----------|
| us103-talos01 | 172.25.200.0/27 | 172.25.250.0/27 |
| us103-k3s01 | 172.25.200.32/27 | 172.25.250.32/27 |
| us103-kubeadm01 | 172.25.200.96/27 | 172.25.250.96/27 |

## Static IP Allocations

### VLAN 200 — MGT (10.0.0.0/26)

| IP | Hostname | Role |
|----|----------|------|
| 10.0.0.1 | BSUS103FW01 | Firewall/Gateway |
| 10.0.0.2–10.0.0.3 | *(reserved)* | Talos cluster |
| 10.0.0.5 | *(reserved)* | K3s prod cluster |
| 10.0.0.10–10.0.0.15 | *(DHCP pool)* | Management DHCP |
| 10.0.0.16–10.0.0.20 | *(reserved)* | MetalLB (kubeadm01) |
| 10.0.0.22 | BSUS103K-8W01 | Kubeadm worker |
| 10.0.0.23 | BSUS103K-8W02 | Kubeadm worker |
| 10.0.0.30 | BSUS103NASV2 | Backup storage |
| 10.0.0.31 | BSUS103NASV3 | Backup storage |
| 10.0.0.41 | BSUS103PX01 | Proxmox host |
| 10.0.0.50 | BSUS103XO01 | Xen Orchestra |
| 10.0.0.59 | BSUS103SW1601 | Access switch |
| 10.0.0.60 | BSUS103SW0801 | Collapsed core/edge switch |
| 10.0.0.61 | BSUS103WAP01 | Wireless AP |

### VLAN 10 — Srv-ADC (10.0.1.0/26)

| IP | Hostname | Role |
|----|----------|------|
| 10.0.1.1 | BSUS103FW01 | Gateway |
| 10.0.1.2 | *(decommissioned — was INFUS103DC01)* | |
| 10.0.1.3 | INFUS103DC02 | Domain Controller |
| 10.0.1.4 | INFUS103DC03 | Domain Controller (deploying) |
| 10.0.1.5–10.0.1.62 | *(available)* | |

### VLAN 15 — Srv-ADS (10.0.1.128/26)

| IP | Hostname | Role |
|----|----------|------|
| 10.0.1.129 | BSUS103FW01 | Gateway |
| 10.0.1.130 | INFUS103CA01 | Certificate Authority (planned) |
| 10.0.1.131 | INFUS103WS01 | WSUS Server |
| 10.0.1.132–10.0.1.190 | *(available)* | |

### VLAN 20 — k8s-mgt (10.0.2.0/27)

| IP | Hostname | Role |
|----|----------|------|
| 10.0.2.1 | BSUS103FW01 | Gateway |
| 10.0.2.2 | bsus103tal-k8m01 | Talos master |
| 10.0.2.3 | bsus103tal-k8w01 | Talos worker |
| 10.0.2.4 | bsus103tal-k8w02 | Talos worker |
| 10.0.2.5 | BSUS103KM01 | K3s master |
| 10.0.2.6–10.0.2.9 | *(available)* | |
| 10.0.2.10–10.0.2.15 | *(DHCP pool)* | Management DHCP |
| 10.0.2.16–10.0.2.30 | *(available)* | |

### VLAN 30 — k8s-bgp (10.250.3.0/27)

| IP | Hostname | Role |
|----|----------|------|
| 10.250.3.1 | BSUS103FW01 | Gateway / BGP peer |
| 10.250.3.3 | bsus103tal-k8m01 | Talos BGP speaker |
| 10.250.3.4 | bsus103tal-k8w01 | Talos BGP speaker |
| 10.250.3.5 | BSUS103KM01 | K3s BGP speaker |
| 10.250.3.22 | bsus103k-8m01 | Kubeadm BGP speaker |
| 10.250.3.23 | bsus103k-8w01 | Kubeadm BGP speaker |

## Related Documentation

- [Hypervisors](hypervisors/README.md) — XCP-ng and Proxmox hosts, firewall VM details
- [Firewall Configuration](firewall/README.md) — OPNsense and BGP details
- [Switches](switches/README.md) — VLAN port assignments
- [Wireless](wireless/README.md) — Access point and SSID configuration
- [Jump Station](../../../runbooks/us103/jump-station/README.md) — Management workstation
