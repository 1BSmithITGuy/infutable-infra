# Network Switches

## Overview

| Hostname | Model | Role | IP Address | Location |
|----------|-------|------|------------|----------|
| BSUS103SW0801 | TP-Link TL-SG108PE | Collapsed Core / Edge Switch | 10.0.0.60 | Telco Rack |
| BSUS103SW1601 | TP-Link TL-SG1016DE | Access Switch | 10.0.0.59 | Server Rack |

Both switches are managed via web interface on VLAN 200 (MGT).

## VLAN Reference

| VLAN ID | Name | Purpose |
|---------|------|---------|
| 1 | Default | Unused/fallback |
| 6 | User-IOT | Home/IoT devices (not part of lab) |
| 10 | ServerADDC | Active Directory Domain Controllers |
| 15 | ServerADSV | AD-connected services |
| 20 | ServerApp | Kubernetes node management (east-west) |
| 30 | k8s_bgp | Kubernetes BGP peering (north-south) |
| 200 | MGT | Infrastructure management |

---

## BSUS103SW0801 - Collapsed Core / Edge Switch

**Model:** TP-Link TL-SG108PE (8-port managed PoE)
**Firmware:** 1.0.0 Build 20210819
**IP:** 10.0.0.60
**Location:** Telco Rack

This switch serves as the aggregation point between the firewall and the rest of the network.

### Physical Connections

| Port | Connection | Notes |
|------|------------|-------|
| 2 | BSUS103WAP01 (EAP610) | PoE enabled |
| 3 | Home security DVR | Not part of lab |
| 7 | BSUS103SW1601 (Uplink) | Trunk to access switch |
| 8 | BSUS103VM01 (Firewall Host) | Trunk to XCP-ng host |

### VLAN Configuration

| VLAN ID | Name | Member Ports | Tagged | Untagged |
|---------|------|--------------|--------|----------|
| 1 | Default | 1, 3-4, 6 | - | 1, 3-4, 6 |
| 6 | User-IOT | 2, 7-8 | 2, 7-8 | - |
| 10 | ServerADDC | 7-8 | 7-8 | - |
| 15 | ServerADSV | 7-8 | 7-8 | - |
| 20 | ServerApp | 7-8 | 7-8 | - |
| 30 | k8s_bgp | 7-8 | 7-8 | - |
| 200 | MGT | 2-3, 5, 7-8 | 2, 7-8 | 3, 5 |

---

## BSUS103SW1601 - Access Switch

**Model:** TP-Link TL-SG1016DE (16-port managed)
**Firmware:** 1.0.1 Build 20240628
**IP:** 10.0.0.59
**Location:** Server Rack

This switch provides connectivity to hypervisors and wired clients.

### Physical Connections

| Port | Connection | Notes |
|------|------------|-------|
| 1-8 | Wired clients | Home network, not part of lab |
| 2 | BSUS103SW0801 (Uplink) | Trunk to core switch |
| 9 | (Available) | - |
| 10 | (Available) | - |
| 11-12 | Hypervisor management NICs | Untagged VLAN 200 |
| 13-16 | Hypervisor trunk NICs | Multi-VLAN trunk (quad NIC cards) |

### VLAN Configuration

| VLAN ID | Name | Member Ports | Tagged | Untagged |
|---------|------|--------------|--------|----------|
| 1 | Default | 2, 10-16 | - | 2, 10-16 |
| 6 | User-IOT | 1-8, 10 | 2 | 1, 3-8, 10 |
| 10 | ServerADDC | 2, 13-16 | 2, 13-16 | - |
| 15 | ServerADSV | 2, 13-16 | 2, 13-16 | - |
| 20 | ServerApp | 2, 13-16 | 2, 13-16 | - |
| 30 | k8s_bgp | 2, 13-16 | 2, 13-16 | - |
| 200 | MGT | 2, 9, 11-12 | 2 | 9, 11-12 |
