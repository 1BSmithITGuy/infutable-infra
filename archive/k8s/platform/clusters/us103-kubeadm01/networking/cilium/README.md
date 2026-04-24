**Author**:  Bryan Smith  
**Cluster**: us103-kubeadm01  
**Purpose**: Cilium config

### Final Stack

```
┌─────────────────────────────────────────────────────────┐
│                    Cilium v1.16.4                       │
│  • CNI (pod networking)                                 │
│  • kube-proxy replacement                               │
│  • BGP Control Plane                                    │
│  • L2 Announcements                                     │
│  • LoadBalancer IPAM                                    │
└─────────────────────────────────────────────────────────┘
                           ↓
        ┌──────────────────┴──────────────────┐
        ↓                                      ↓
┌──────────────────────┐          ┌──────────────────────┐
│  NGINX Infra         │          │  NGINX Public        │
│  (nginx-infra)       │          │  (nginx-public)      │
│  • Deployment        │          │  • Deployment        │
│  • IngressClass      │          │  • IngressClass      │
│  • L2 VIP only       │          │  • BGP VIPs          │
│  • 10.0.0.16         │          │  • 172.25.200.96     │
│                      │          │  • 172.25.250.96     │
└──────────────────────┘          └──────────────────────┘
```

### Two NGINX Controllers:

**Security**:
- Prevents hostname-based attacks via hosts file manipulation
- True application-layer separation
- Each controller only knows about its assigned Ingresses

**Operational clarity**:
- Clear designation of internal vs public services
- Easy auditing (grep for `ingressClassName`)
- Explicit intent in configuration

**Flexibility**:
- Scale controllers independently
- Different monitoring/alerting per controller
- Different rate limiting or WAF policies per controller

### 1.  Install Cilium:

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

### 2.  **K Apply the following files**:
- cilium-bgp-peering.yaml
- cilium-ip-pools.yaml
- cilium-l2-policy.yaml

## For more information, see the following files:
- **Upgrade notes**: /srv/projects/upgrades/us103-kubeadm01_cilium_upgrade/
- **NGINX config**: /srv/repos/infutable-infra/k8s/platform/clusters/us103-kubeadm01/ingress/nginx