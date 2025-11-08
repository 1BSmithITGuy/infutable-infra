# Cluster-Specific Configurations

**Author:** Bryan Smith (BSmithITGuy@gmail.com)  
**Purpose:** Cluster-specific infrastructure configurations organized by site and cluster  
**Date:** 11/07/2025  

## Structure

```
clusters/
├── us103-kubeadm01/        # Kubeadm cluster
│   ├── ingress/           # Dual nginx controllers (nginx-infra, nginx-public)
│   └── networking/        # Cilium BGP pools, L2 policies
├── us103-k3s01/           # K3s cluster
│   ├── ingress/           # NGINX ingress controller
│   └── networking/        # MetalLB configuration
├── us103-talos01/         # Talos cluster
│   ├── bin/               # Helper scripts
│   ├── config/            # Talos machine configs, MetalLB, Hubble
│   └── docs/              # Cluster-specific documentation
└── rancher/               # Rancher management
```

## Cluster Overview

### us103-kubeadm01 (Management Cluster)
- **OS:** Ubuntu Server 24.04 LTS
- **Installer:** Kubeadm
- **CNI:** Cilium
- **Load Balancer:** Cilium L2 (management) + Cilium BGP (public)
- **Ingress:** Dual NGINX controllers
  - `nginx-infra`: Cilium L2 pool `infra-l2-pool` (10.0.0.16-20) - Management VLAN restricted
  - `nginx-public`: Cilium BGP pools - Public services
    - `public-infra-bgp-pool`: 172.25.200.96/27 (infrastructure consoles)
    - `public-app-bgp-pool`: 172.25.250.96/27 (user applications)

### us103-talos01 (Production Apps)
- **Distribution:** Talos Linux
- **CNI:** Cilium
- **Load Balancer:** MetalLB (BGP mode)
  - `public-infra-bgp-pool`: 172.25.200.0/27 (infrastructure services)
  - `public-app-bgp-pool`: 172.25.250.0/27 (user applications)
- **Ingress:** NGINX

### us103-k3s01 (Lightweight)
- **OS:** Ubuntu Server 24.04 LTS
- **Distribution:** K3s
- **Load Balancer:** MetalLB (BGP mode)
  - Pool configuration in `us103-k3s01/networking/metallb/metallb-config.yaml`
- **Ingress:** NGINX

## Adding New Clusters

Create a new directory following the naming pattern:
```
clusters/<site>-<type><number>/
```

Examples:
- `us104-azu-aks01/` - Azure AKS cluster
- `us104-aws-eks01/` - AWS EKS cluster
- `us104-kubeadm01/` - New site with onprem Kubeadm cluster
