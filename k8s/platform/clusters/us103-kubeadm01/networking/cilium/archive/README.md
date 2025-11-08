**Author**:  Bryan Smith  
**Cluster**: us103-kubeadm01  
**Purpose**: Cilium config


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
- **NGINX config**: /srv/repos/infutable-infra/k8s/platform/clusters/us103-kubeadm01/ingress/nginx


### Installation:

```bash
helm install cilium cilium/cilium \
  --version 1.16.4 \
  --namespace kube-system \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=bsus103k-8m01 \
  --set k8sServicePort=6443 \
  --set bgpControlPlane.enabled=true \
  --set ipam.mode=kubernetes \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set l2announcements.enabled=true \
  --set l2announcements.leaseDuration=3s \
  --set l2announcements.leaseRenewDeadline=1s \
  --set l2announcements.leaseRetryPeriod=500ms \
  --set externalIPs.enabled=true \
  --set nodePort.enabled=true \
  --set hostPort.enabled=true \
  --set bpf.masquerade=true \
  --set operator.replicas=1
```

**Key Settings Explained**:
- `kubeProxyReplacement=true`: Cilium replaces kube-proxy for better performance
- `k8sServiceHost=bsus103k-8m01`: Use SHORT hostname (certificate only has this, not FQDN)
- `bgpControlPlane.enabled=true`: Enable BGP for route advertisement
- `l2announcements.enabled=true`: Enable ARP announcements for local VLANs

**K Apply the following files**:
- cilium-bgp-peering.yaml
- cilium-bgp-pools.yaml
- cilium-l2-policy.yaml
- cilium-l2-pool.yaml


