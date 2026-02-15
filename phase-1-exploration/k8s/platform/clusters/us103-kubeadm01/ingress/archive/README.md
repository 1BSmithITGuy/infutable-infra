#  Depricated - using dual NGINX controllers

**Author**:  Bryan Smith  
**Cluster**: us103-kubeadm01  
**Purpose**: NGINX config

### Final Stack
```
┌─────────────────────────────────────┐
│         Cilium v1.16.4              │
│  • CNI (pod networking)             │
│  • kube-proxy replacement           │
│  • BGP Control Plane                │
│  • L2 Announcements                 │
│  • LoadBalancer IPAM                │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│    NGINX Ingress (Deployment)       │
│  • LoadBalancer mode                │
│  • HTTP/HTTPS routing               │
│  • 3 VIPs (L2 + 2x BGP)             │
└─────────────────────────────────────┘
```
**Cilium handles Layer 3/4** (networking, routing, load balancing):
- Assigns IPs to LoadBalancer services
- Advertises routes via BGP
- Handles ARP for L2 VIPs
- Routes traffic to pods

**NGINX handles Layer 7** (application routing):
- HTTP/HTTPS path-based routing
- TLS termination
- Virtual hosting (multiple domains on one IP)


### For more information, see the following files:
- **Upgrade notes**: /srv/projects/upgrades/us103-kubeadm01_cilium_upgrade/
- **Cilium config**: /srv/repos/infutable-infra/k8s/platform/clusters/us103-kubeadm01/networking/cilium


### Installation:

```bash
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.replicaCount=2 \
  --set controller.service.enabled=false
```

**Key Settings Explained**:
- `controller.replicaCount=2`: 2 replicas for HA
- `controller.service.enabled=false`: We'll create custom LoadBalancer services

**K Apply the following files**:
- nginx-loadbalancer-services.yaml