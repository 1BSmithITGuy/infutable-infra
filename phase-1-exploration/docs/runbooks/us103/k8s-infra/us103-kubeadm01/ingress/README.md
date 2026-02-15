# Kubeadm Ingress Setup (NGINX + cert-manager)

**Purpose**  
Install and configure NGINX ingress controller on a kubeadm-based cluster and cert-manager for TLS.

**Status**  
- Last updated: 2025-08-13  
- Ownership: Bryan Smith (BSmithITGuy@gmail.com)

---

## 1) Install NGINX Ingress Controller

Install using Helm:
```bash
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx   --namespace ingress-nginx --create-namespace   --set controller.kind=DaemonSet   --set controller.hostPort.enabled=true   --set controller.publishService.enabled=false   --set controller.service.type=ClusterIP
```

> **Notes:**  
> - `controller.kind=DaemonSet` — runs ingress on every node.  
> - `controller.hostPort.enabled=true` — allows direct port binding on nodes (avoids needing a LoadBalancer in lab environments).  
> - `controller.publishService.enabled=false` — disables service-based IP publishing (simplifies hostPort setups).  
> - `controller.service.type=ClusterIP` — internal-only Service type.

---

## 2) Install cert-manager (Optional, TLS support)

Add the Jetstack Helm repo:
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

Install cert-manager with CRDs:
```bash
helm upgrade --install cert-manager jetstack/cert-manager   --namespace cert-manager --create-namespace   --set crds.enabled=true
```

