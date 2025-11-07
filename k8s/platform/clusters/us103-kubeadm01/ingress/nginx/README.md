**Author**:  Bryan Smith  
**Cluster**: us103-kubeadm01  
**Purpose**: NGINX config

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

### 1.  Install nginx-infra Controller

**For restricted internal infrastructure (L2 only)**

```bash
helm install nginx-infra ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.ingressClassResource.name=nginx-infra \
  --set controller.ingressClassResource.controllerValue="k8s.io/nginx-infra" \
  --set controller.ingressClass=nginx-infra \
  --set controller.replicaCount=2 \
  --set controller.service.enabled=false \
  --set controller.electionID=nginx-infra-leader \
  --set controller.ingressClassByName=true
```

**Configuration explained**:
- `ingressClassResource.name=nginx-infra`: Creates IngressClass "nginx-infra"
- `service.enabled=false`: We'll create custom LoadBalancer service
- `electionID=nginx-infra-leader`: Unique leader election ID (prevents conflicts with other controller)
- `replicaCount=2`: HA with 2 replicas

### 2.  Install nginx-public Controller

**For public-facing services (BGP)**

```bash
helm install nginx-public ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.ingressClassResource.name=nginx-public \
  --set controller.ingressClassResource.controllerValue="k8s.io/nginx-public" \
  --set controller.ingressClass=nginx-public \
  --set controller.replicaCount=2 \
  --set controller.service.enabled=false \
  --set controller.electionID=nginx-public-leader \
  --set controller.ingressClassByName=true
```

### 3.  **K Apply the following files**:
- dual-nginx-loadbalancer-config.yaml

## How to Choose Which Controller

**Use nginx-infra for**:
- Internal management tools (Rancher, ArgoCD, Grafana dashboards)
- Sensitive infrastructure services
- Services that should ONLY be accessible on internal VLAN200
- Things you don't want exposed to BGP routing

**Use nginx-public for**:
- Public-facing applications
- APIs meant for external consumption
- Services that need to be reachable via BGP routes
- Customer-facing web applications

## For more information, see the following files:
- **Upgrade notes**: /srv/projects/upgrades/us103-kubeadm01_cilium_upgrade/
- **Cilium config**: /srv/repos/infutable-infra/k8s/platform/clusters/us103-kubeadm01/networking/cilium