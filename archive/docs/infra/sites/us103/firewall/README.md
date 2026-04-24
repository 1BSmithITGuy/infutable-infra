# Firewall - BSUS103FW01

OPNsense firewall running as a VM on XCP-ng host BSUS103VM01.

## System Information

| Property | Value |
|----------|-------|
| Hostname | BSUS103FW01 |
| OS | OPNsense (FreeBSD 14.2) |
| Management IP | 10.0.0.1 |
| Hypervisor | BSUS103VM01 (XCP-ng) |

## Interfaces

The firewall handles routing between all VLANs and provides the default gateway for each subnet.

| VLAN | Interface | Gateway IP | Subnet |
|------|-----------|------------|--------|
| - | WAN | (ISP assigned) | Internet uplink |
| 6 | User-IOT | 10.0.100.1 | 10.0.100.0/24 |
| 10 | Srv-ADC | 10.0.1.1 | 10.0.1.0/29 |
| 15 | Srv-ADS | 10.0.1.41 | 10.0.1.40/29 |
| 20 | k8s-mgt | 10.0.2.1 | 10.0.2.0/27 |
| 30 | k8s-bgp | 10.250.3.1 | 10.250.3.0/27 |
| 200 | MGT | 10.0.0.1 | 10.0.0.0/26 |

## BGP Configuration

The firewall runs FRR (Free Range Routing) to peer with Kubernetes clusters. Each cluster advertises its service VIPs via BGP, allowing external access to LoadBalancer services.

### Peering Summary

| Cluster | ASN | Neighbors | VIP Ranges |
|---------|-----|-----------|------------|
| us103-talos01 | 65001 | 10.250.3.3, 10.250.3.4 | 172.25.200.0/27 (infra), 172.25.250.0/27 (apps) |
| us103-k3s01 | 65002 | 10.250.3.5 | 172.25.250.32/27 (apps) |
| us103-kubeadm01 | 65003 | 10.250.3.22, 10.250.3.23 | 172.25.200.96/27 (infra), 172.25.250.96/27 (apps) |

Firewall ASN: **65000**

## Design Notes

- **Prefix filtering**: Each cluster can only advertise its designated VIP ranges. Route-maps with prefix-lists prevent clusters from injecting unauthorized routes.
- **BFD**: Bidirectional Forwarding Detection enables sub-second failover when a BGP peer goes down.
- **Separate ASNs**: Each cluster has its own ASN, allowing for clear traffic attribution and independent routing policies.
