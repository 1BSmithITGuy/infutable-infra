# US103 Base Infrastructure

This document provides an overview of the physical infrastructure at site US103 (Easton, PA).

> **Note:** Network configuration data is planned for migration to Netbox for centralized IPAM/DCIM management.

## Physical Layout

The infrastructure is split across two racks:

- **Telco Rack** - Network equipment (firewall host, switches, REOlink NVR)
- **Server Rack** - Compute infrastructure (2xLenovo P520 servers, Cisco catalyst 3750x)
	**NOTE:** The Cisco 3750 Catalyst is not currently in use due to power consumption; the TP-Link switches provide sufficient  L2 functionality. If it gets too cold in my office, I'll brush up on Cisco :)

*(Rack photos: see `images/` subdirectory)*

## Hardware Summary

### Compute

| Hostname | Role | Hardware | CPU | RAM | Location |
|----------|------|----------|-----|-----|----------|
| BSUS103VM01 | XCP-ng Host (Firewall) | Mini PC | AMD Ryzen 5 5500U (4C/4T) | 32 GB | Telco Rack |
| BSUS103VM02 | XCP-ng Host (Workloads) | Lenovo P520 | Intel Xeon W-2135 (6C/12T) | 48 GB | Server Rack |
| BSUS103PX01 | Proxmox Host | Lenovo P520 | Intel Xeon W-2135 (6C/12T) | 48 GB | Server Rack |

### Network

| Hostname | Role | Hardware | IP Address | Location |
|----------|------|----------|------------|----------|
| BSUS103FW01 | Firewall/Router | OPNsense VM (FreeBSD 14.2) | 10.0.0.1 | BSUS103VM01 |
| BSUS103SW0801 | Core Switch | TP-Link TL-SG108PE | 10.0.0.60 | Telco Rack |
| BSUS103SW1601 | Access Switch | TP-Link TL-SG1016DE | 10.0.0.59 | Server Rack |
| BSUS103WAP01 | Wireless AP | TP-Link EAP610 | 10.0.0.61 | Telco Rack |

### Management

| Hostname | Role | Hardware | IP Address |
|----------|------|----------|------------|
| BSUS103XO01 | Xen Orchestra | VM on XCP-ng | 10.0.0.50 |
| bsus103jump02 | Jump Station | Ubuntu 24.04 VM | VLAN 200 |

## Network Architecture

```
                                    ┌─────────────────┐
                                    │    Internet     │
                                    └────────┬────────┘
                                             │
                                    ┌────────▼────────┐
                                    │   BSUS103FW01   │
                                    │    (OPNsense)   │
                                    │    10.0.0.1     │
                                    └────────┬────────┘
                                             │
                              ┌──────────────▼──────────────┐
                              │       BSUS103SW0801         │
                              │   Core Switch (TL-SG108PE)  │
                              │         10.0.0.60           │
                              └──────────────┬──────────────┘
                                             │
                    ┌────────────────────────┼────────────────────────┐
                    │                        │                        │
           ┌────────▼────────┐      ┌────────▼────────┐      ┌────────▼────────┐
           │  BSUS103WAP01   │      │  BSUS103SW1601  │      │   BSUS103VM01   │
           │   (EAP610)      │      │   Access Switch │      │(XCP-ng/firewall)│
           │   10.0.0.61     │      │    10.0.0.59    │      │    10.0.0.51    │
           └─────────────────┘      └────────┬────────┘      └─────────────────┘
                                             │
                              ┌──────────────┼──────────────┐
                              │              │              │
                     ┌────────▼───────┐ ┌────▼────┐ ┌───────▼────────┐
                     │  BSUS103VM02   │ │   ...   │ │  BSUS103PX01   │
                     │   (XCP-ng)     │ │ misc/IoT│ │   (Proxmox)    │
                     │   10.0.0.52    │ │         │ │   10.0.0.41    │
                     └────────────────┘ └─────────┘ └────────────────┘

```

## VLAN Architecture

| VLAN ID | Name | Subnet | Purpose |
|---------|------|--------|---------|
| 6 | User-IOT | 10.0.100.0/24 | Home/IoT devices (not part of lab) |
| 10 | Srv-ADC | 10.0.1.0/29 | Active Directory Domain Controllers |
| 15 | Srv-ADS | 10.0.1.40/29 | AD-connected services (WSUS, admin tools) |
| 20 | k8s-mgt | 10.0.2.0/27 | Kubernetes node management (east-west traffic) |
| 30 | k8s-bgp | 10.250.3.0/27 | Kubernetes BGP peering (north-south ingress) |
| 200 | MGT | 10.0.0.0/26 | Infrastructure management |

## BGP Overview

The firewall (BSUS103FW01) runs FRR and peers with Kubernetes clusters via BGP for service IP advertisement.

| Cluster | ASN | Peers | Advertised Prefixes |
|---------|-----|-------|---------------------|
| us103-talos01 | 65001 | 10.250.3.3, 10.250.3.4 | 172.25.200.0/27, 172.25.250.0/27 |
| us103-k3s01 | 65002 | 10.250.3.5 | 172.25.250.32/27 |
| us103-kubeadm01 | 65003 | 10.250.3.22, 10.250.3.23 | 172.25.200.96/27, 172.25.250.96/27 |

Firewall ASN: **65000**

BFD is enabled for fast failover detection.

See [firewall/README.md](firewall/README.md) for full BGP configuration.

## Address Plan - Supernets

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

### VLAN 200 - MGT (10.0.0.0/26)

| IP | Hostname | Role |
|----|----------|------|
| 10.0.0.1 | BSUS103FW01 | Firewall/Gateway |
| 10.0.0.2-10.0.0.3 | *(reserved)* | Talos cluster |
| 10.0.0.5 | *(reserved)* | K3s prod cluster |
| 10.0.0.10-10.0.0.15 | *(DHCP pool)* | Management DHCP |
| 10.0.0.16-10.0.0.20 | *(reserved)* | MetalLB (kubeadm01) |
| 10.0.0.22 | BSUS103K-8W01 | Kubeadm worker |
| 10.0.0.23 | BSUS103K-8W02 | Kubeadm worker |
| 10.0.0.30 | BSUS103NASV2 | Backup storage |
| 10.0.0.31 | BSUS103NASV3 | Backup storage |
| 10.0.0.41 | BSUS103PX01 | Proxmox host |
| 10.0.0.50 | BSUS103XO01 | Xen Orchestra |
| 10.0.0.59 | BSUS103SW1601 | Access switch |
| 10.0.0.60 | BSUS103SW0801 | Core switch |
| 10.0.0.61 | BSUS103WAP01 | Wireless AP |

### VLAN 10 - Srv-ADC (10.0.1.0/29)

| IP | Hostname | Role |
|----|----------|------|
| 10.0.1.1 | BSUS103FW01 | Gateway |
| 10.0.1.2 | INFUS103DC01 | Domain Controller |
| 10.0.1.3 | INFUS103DC02 | Domain Controller |
| 10.0.1.4-10.0.1.5 | *(available)* | |
| 10.0.1.6 | *(reserved)* | RDS admin server |

### VLAN 15 - Srv-ADS (10.0.1.40/29)

| IP | Hostname | Role |
|----|----------|------|
| 10.0.1.41 | BSUS103FW01 | Gateway |
| 10.0.1.42 | INFUS103CA01 | Certificate Authority |
| 10.0.1.43 | INFUS103WS01 | WSUS Server |
| 10.0.1.44-10.0.1.46 | *(available)* | |

### VLAN 20 - k8s-mgt (10.0.2.0/27)

| IP | Hostname | Role |
|----|----------|------|
| 10.0.2.1 | BSUS103FW01 | Gateway |
| 10.0.2.2 | bsus103tal-k8m01 | Talos master |
| 10.0.2.3 | bsus103tal-k8w01 | Talos worker |
| 10.0.2.4 | bsus103tal-k8w02 | Talos worker |
| 10.0.2.5 | BSUS103KM01 | K3s master |
| 10.0.2.6-10.0.2.9 | *(available)* | |
| 10.0.2.10-10.0.2.15 | *(DHCP pool)* | Management DHCP |
| 10.0.2.16-10.0.2.30 | *(available)* | |

### VLAN 30 - k8s-bgp (10.250.3.0/27)

| IP | Hostname | Role |
|----|----------|------|
| 10.250.3.1 | BSUS103FW01 | Gateway / BGP peer |
| 10.250.3.3 | bsus103tal-k8m01 | Talos BGP speaker |
| 10.250.3.4 | bsus103tal-k8w01 | Talos BGP speaker |
| 10.250.3.5 | BSUS103KM01 | K3s BGP speaker |
| 10.250.3.22 | bsus103k-8m01 | Kubeadm BGP speaker |
| 10.250.3.23 | bsus103k-8w01 | Kubeadm BGP speaker |

## Related Documentation

- [Firewall Configuration](firewall/README.md) - OPNsense and BGP details
- [Switches](switches/README.md) - VLAN port assignments
- [Wireless](wireless/README.md) - Access point and SSID configuration
- [Proxmox](proxmox/README.md) - Proxmox hypervisor setup
- [XCP-ng](xcp-ng/README.md) - XCP-ng hypervisor environment
- [Jump Station](../jump-station/README.md) - Management workstation
- [Kubernetes Infrastructure](../k8s-infra/README.md) - Cluster documentation
