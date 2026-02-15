# Netbox IPAM/DCIM Application

**Author:** Bryan Smith (BSmithITGuy@gmail.com)  
**Cluster:** us103-talos01  
**Purpose:** Network documentation, IP address management, and DCIM.  
**Date:** 11/07/2025

## Overview

Netbox is deployed via ArgoCD using the official Netbox Community Helm chart. The deployment uses a base configuration with cluster-specific overlays.

## Structure

```
netbox/
├── base/
│   ├── Chart.yaml          # Helm chart wrapper (points to netbox-community chart)
│   └── values.yaml         # Base configuration (common across all clusters)
└── overlays/
    ├── us103-kubeadm01/    # Kubeadm cluster-specific settings
    │   └── values.yaml     # Ingress, resources, etc.
    └── us103-talos01/      # Talos cluster-specific settings
        └── values.yaml     # Ingress, resources, etc.
```

## Deployment

Netbox is deployed via ArgoCD Application manifests located in `k8s/platform/argocd/applications/`.

**Current deployments:**
- **us103-talos01:** Primary Netbox instance for infrastructure documentation
  - URL: https://netbox.infra.infutable.com
  - Ingress: nginx (MetalLB BGP infra pool)
  - Storage: local-path provisioner

**Default credentials:** See `base/values.yaml` superuser section

## Chart Information

- **Upstream Chart Repository:** https://github.com/netbox-community/netbox-chart
- **Helm Chart:** `netbox-community/netbox` version 7.1.18
- **Add Helm Repo:** `helm repo add netbox-community https://netbox-community.github.io/netbox-chart/`
- **Chart Documentation:** https://github.com/netbox-community/netbox-chart/blob/main/README.md