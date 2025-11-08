
# updated 10/29/2025: Added NIC to BGP VLAN, installed metallb (see files in platform directory), 



helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx --version 4.13.0 \
  --set controller.kind=Deployment \
  --set controller.hostPort.enabled=false \
  --set controller.service.type=LoadBalancer \
  --set controller.service.loadBalancerIP=172.25.250.32 \
  --set controller.service.annotations."metallb\.universe\.tf/address-pool"=app-pool \
  --set controller.ingressClassResource.default=true \
  --set controller.admissionWebhooks.enabled=true


```bash
  # Disable ServiceLB in k3s
sudo mkdir -p /etc/rancher/k3s
sudo bash -c 'cat >> /etc/rancher/k3s/config.yaml <<EOF
disable:
  - servicelb
  - traefik
EOF'
sudo systemctl restart k3s
```



#  Old config (prior to 10/29/2025) - do not use (hostport config)

# K3s Ingress Setup (NGINX, Traefik Disabled)


**Purpose**  
Replace the default Traefik ingress controller in K3s with NGINX, and install cert-manager for TLS.

**Status**  
- Last updated: 2025-08-13  
- Ownership: Bryan Smith (BSmithITGuy@gmail.com)

---

## 1) Disable and Remove Traefik

Create or edit the K3s config file:
```yaml
# /etc/rancher/k3s/config.yaml
disable:
  - traefik
```

Reload and restart K3s:
```bash
sudo systemctl daemon-reload
sudo systemctl restart k3s
```

Remove existing Traefik resources:
```bash
kubectl -n kube-system delete helmcharts.helm.cattle.io traefik traefik-crd

kubectl -n kube-system delete deploy,svc,sa,cm,clusterrole,clusterrolebinding   -l app.kubernetes.io/name=traefik

kubectl -n kube-system delete pod -l app=svclb-traefik --force --grace-period=0
```

---

## 2) Install NGINX Ingress Controller

Add and update Helm repo:
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

Install with Helm:
```bash
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx   --namespace ingress-nginx   --set controller.kind=DaemonSet   --set controller.hostPort.enabled=true   --set controller.publishService.enabled=false   --set controller.service.type=ClusterIP
```

> **Notes:**  
> - `controller.kind=DaemonSet` ensures ingress runs on all nodes.  
> - HostPorts are enabled for direct node access (no external LoadBalancer).  
> - `publishService.enabled=false` avoids relying on a Service for external IP.

---

## 3) Install cert-manager

This was also run on the kubeadm cluster.

Add Jetstack repo:
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

Install cert-manager:
```bash
helm upgrade --install cert-manager jetstack/cert-manager   --namespace cert-manager --create-namespace   --set crds.enabled=true
```
