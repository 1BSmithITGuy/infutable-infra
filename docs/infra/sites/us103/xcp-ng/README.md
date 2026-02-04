# XCP-ng Environment - US103

## Overview

Two XCP-ng hosts running as separate single-host pools. Multi-hypervisor environment alongside Proxmox VE for platform evaluation.

Xen Orchestra (BSUS103XO01) provides centralized management at 10.0.0.50.

---

## Hosts

### BSUS103VM01

| Component | Specification |
|-----------|---------------|
| Model | HCAR5000-MI (Mini PC) |
| CPU | AMD Ryzen 5 5500U (4C/4T) |
| RAM | 32 GB |
| Role | Firewall host, lightweight VMs |

### BSUS103VM02

| Component | Specification |
|-----------|---------------|
| Model | Lenovo P520 (30BECTO1WW) |
| CPU | Intel Xeon W-2135 (6C/12T @ 3.70GHz) |
| RAM | 48 GB |
| Pool | BSUS103POOL01 |
| Role | Primary workload host |

10GbE point-to-point link to Proxmox host.

---

## Critical Infrastructure: BSUS103FW01

OPNsense/pfSense firewall running on FreeBSD 14.2.

| Spec | Value |
|------|-------|
| vCPUs | 3 |
| RAM | 4 GB |
| Host | BSUS103VM01 |

### Network Interfaces

| Device | Network | Gateway IP |
|--------|---------|------------|
| 0 | VLAN200: MGT | 10.0.0.1 |
| 1 | WAN | 64.121.163.88 |
| 2 | VLAN10: Srv-ADC | 10.0.1.1 |
| 3 | VLAN15: Srv-ADS | 10.0.1.41 |
| 4 | VLAN20: k8s-mgt | 10.0.2.1 |
| 5 | VLAN06: User-IOT | 10.0.100.1 |
| 6 | VLAN30: k8s-bgp | 10.250.3.1 |

---

## VLANs

| VLAN | Name | Purpose |
|------|------|---------|
| 6 | User-IOT | IoT devices |
| 10 | Srv-ADC | AD Domain controllers |
| 15 | Srv-ADS | AD Services |
| 20 | k8s-mgt | Kubernetes management |
| 30 | k8s-bgp | Kubernetes BGP peering |
| 200 | MGT | Infrastructure management |
| 300 | BU | Backup |
