# ArgoCD Multi-Cluster Deployment

**Author:** Bryan Smith (BSmithITGuy@gmail.com)  
**Cluster:** us103-kubeadm01  
**Purpose:** GitOps-based multi-cluster Kubernetes management  
**Date:** 11/07/2025  

## Overview

This deployment provides a production-style ArgoCD setup for managing multiple Kubernetes clusters:

- **Management Cluster:** us103-kubeadm01 (where ArgoCD runs)
- **Managed Clusters:**
  - us103-kubeadm01 (in-cluster / self-managed, Kubeadm)
  - us103-talos01 (remote Talos cluster with Cilium CNI + MetalLB BGP)
  - us103-k3s01 (remote K3s lightweight cluster)

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│ us103-kubeadm01 (Management Cluster)                   │
│                                                         │
│  ┌─────────────────────────────────────────┐           │
│  │ ArgoCD                                  │           │
│  │  - Server                               │           │
│  │  - Repo Server                          │           │
│  │  - Application Controller               │           │
│  │  - ApplicationSet Controller            │           │
│  │  - Ingress: argocd.infra.infutable.com  │           │
│  └─────────────────────────────────────────┘           │
│                                                         │
│  Manages:                                               │
│  ├── Self (in-cluster apps)                            │
│  └── Remote clusters via kubectl context               │
└─────────────────────────────────────────────────────────┘
                          │
                          │ Manages
                          ▼
┌─────────────────────────────────────────────────────────┐
│ us103-talos01 (Managed Cluster)                        │
│                                                         │
│  ┌─────────────────────────────────────────┐           │
│  │ Netbox (IPAM/DCIM)                      │           │
│  │  - Deployed via ArgoCD                  │           │
│  │  - Helm chart from Git                  │           │
│  │  - MetalLB BGP LoadBalancer             │           │
│  │  - Ingress: netbox.infra.infutable.com  │           │
│  └─────────────────────────────────────────┘           │
│                                                         │
│  Infrastructure:                                        │
│  ├── CNI: Cilium                                       │
│  ├── LoadBalancer: MetalLB (BGP mode)                 │
│  │   ├── public-infra-bgp-pool: 172.25.200.0/27       │
│  │   └── public-app-bgp-pool: 172.25.250.0/27         │
│  └── Ingress: NGINX                                    │
└─────────────────────────────────────────────────────────┘
```

## Prerequisites
- Helm 3.x
- kubectl 1.19+


### SSH Deploy Key Setup

Generate SSH key for Git repository access:

```bash
# Create secrets directory
sudo mkdir -p /srv/secrets/ssh-keys/automation/argocd

# Generate SSH key
ssh-keygen -t ed25519 -C "argocd-infutable-infra" \
  -f /srv/secrets/ssh-keys/automation/argocd/argocd-infutable-infra -N ""

# Set appropriate permissions
sudo chown $USER:$USER /srv/secrets/ssh-keys/automation/argocd/argocd-infutable-infra*
chmod 600 /srv/secrets/ssh-keys/automation/argocd/argocd-infutable-infra
```

Add the **public key** (`/srv/secrets/ssh-keys/automation/argocd/argocd-infutable-infra.pub`) to GitHub:

1. Go to: https://github.com/1BSmithITGuy/infutable-infra/settings/keys
2. Click "Add deploy key"
3. Title: `US103-ArgoCD`
4. Paste public key contents
5. **Leave "Allow write access" UNCHECKED** (read-only)
6. Click "Add key"

### kubectl Context Setup

Ensure both clusters are configured in kubectl:

```bash
kubectl config get-contexts

# Should show:
# us103-kubeadm01
# us103-talos01
```

## Deployment

### Quick Start

```bash
cd platform/argocd
./deploy.sh
```

The script will:
1. Verify prerequisites
2. Remove old ArgoCD installation (if exists)
3. Install ArgoCD via Helm
4. Create Git repository secret
5. Register Talos cluster
6. Deploy applications (Netbox)
7. Display access credentials

### Manual Deployment

If you prefer step-by-step deployment:

```bash
# 1. Set kubectl context
kubectl config use-context us103-kubeadm01

# 2. Add Helm repo
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# 3. Install ArgoCD
helm install argocd argo/argo-cd \
  --create-namespace \
  --namespace argocd \
  --values helm-values.yaml \
  --wait

# 4. Create repository secret
kubectl create secret generic repo-infutable-infra \
  --namespace=argocd \
  --from-literal=type=git \
  --from-literal=url=git@github.com:1BSmithITGuy/infutable-infra.git \
  --from-file=sshPrivateKey=/srv/secrets/ssh-keys/automation/argocd/argocd-infutable-infra \
  --dry-run=client -o yaml | \
  kubectl label -f - --dry-run=client -o yaml --local \
    argocd.argoproj.io/secret-type=repository | \
  kubectl apply -f -

# 5. Register Talos cluster
# See "Adding New Clusters" section below for detailed steps

# 6. Deploy applications
kubectl apply -f applications/
```

## Access Information

### ArgoCD UI

- **URL:** https://argocd.infra.infutable.com
- **Username:** `admin`
- **Password:** Get initial password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

**Change the default password after first login:**

```bash
argocd account update-password
```

### Deployed Applications

- **Netbox:** https://netbox.infra.infutable.com
  - Username: `admin`
  - Password: See `k8s/apps/netbox/base/values.yaml` (superuser section)

## File Structure

```
k8s/
├── platform/argocd/                    # ArgoCD deployment and management
│   ├── README.md                       # This file
│   ├── deploy.sh                       # Automated deployment script
│   ├── helm-values.yaml                # ArgoCD Helm chart configuration
│   ├── applications/                   # ArgoCD Application manifests (GitOps pointers)
│   │   └── netbox-us103-talos01.yaml  # Points to apps/netbox for deployment
│   └── scripts/                        # Helper scripts
│       └── (future utilities)
│
├── apps/netbox/                        # Netbox application configuration
│   ├── base/                           # Base config (common to all clusters)
│   │   ├── Chart.yaml                  # Helm chart wrapper
│   │   └── values.yaml                 # Base Netbox configuration
│   └── overlays/                       # Cluster-specific overrides
│       ├── us103-kubeadm01/
│       │   └── values.yaml             # Kubeadm-specific settings
│       └── us103-talos01/
│           └── values.yaml             # Talos-specific settings
│
└── platform/clusters/us103-talos01/    # Cluster platform configs
    └── config/metallb/
        └── metallb-config.yaml         # MetalLB BGP pools
```

**Pattern:**
- **ArgoCD Application manifests** → `k8s/platform/argocd/applications/`
  - These tell ArgoCD *what* to deploy and *where*
- **Application configurations** → `k8s/apps/<app-name>/`
  - These contain the actual app configs that get deployed

## Adding New Applications

### Create Application Manifest

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app-clustername
  namespace: argocd
spec:
  project: default
  source:
    repoURL: git@github.com:1BSmithITGuy/infutable-infra.git
    targetRevision: main
    path: k8s/apps/my-app
  destination:
    name: clustername  # or server: https://...
    namespace: my-namespace
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Apply the manifest:

```bash
kubectl apply -f applications/my-app.yaml
```

## Adding New Clusters

### Register Cluster with ArgoCD

```bash
# Get cluster credentials from kubeconfig
CLUSTER_NAME="my-cluster"
CLUSTER_SERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name=='$CLUSTER_NAME')].cluster.server}")
CLUSTER_CA=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name=='$CLUSTER_NAME')].cluster.certificate-authority-data}")
CLIENT_CERT=$(kubectl config view --raw -o jsonpath="{.users[?(@.name=='admin@$CLUSTER_NAME')].user.client-certificate-data}")
CLIENT_KEY=$(kubectl config view --raw -o jsonpath="{.users[?(@.name=='admin@$CLUSTER_NAME')].user.client-key-data}")

# Create cluster config
CLUSTER_CONFIG=$(cat <<EOF
{
  "bearerToken": "",
  "tlsClientConfig": {
    "insecure": false,
    "caData": "$CLUSTER_CA",
    "certData": "$CLIENT_CERT",
    "keyData": "$CLIENT_KEY"
  }
}
EOF
)

# Create cluster secret
kubectl create secret generic cluster-$CLUSTER_NAME \
  --namespace=argocd \
  --from-literal=name="$CLUSTER_NAME" \
  --from-literal=server="$CLUSTER_SERVER" \
  --from-literal=config="$CLUSTER_CONFIG" \
  --dry-run=client -o yaml | \
  kubectl label -f - --dry-run=client -o yaml --local \
    argocd.argoproj.io/secret-type=cluster | \
  kubectl apply -f -
```

Verify cluster registration in ArgoCD UI under **Settings → Clusters**.

## Troubleshooting

### ArgoCD Won't Start

```bash
# Check pod status
kubectl -n argocd get pods

# Check logs
kubectl -n argocd logs deployment/argocd-server
kubectl -n argocd logs deployment/argocd-application-controller
```

### Repository Connection Failed

```bash
# Verify secret exists
kubectl -n argocd get secret repo-infutable-infra

# Test SSH key
ssh -T git@github.com -i /srv/secrets/ssh-keys/automation/argocd/argocd-infutable-infra

# Check ArgoCD repo server logs
kubectl -n argocd logs deployment/argocd-repo-server
```

### Application Sync Issues

```bash
# Check application status
kubectl -n argocd get applications

# View application details
kubectl -n argocd describe application netbox-us103-talos01

# Force sync via UI or CLI
argocd app sync netbox-us103-talos01
```

### Cluster Connection Issues

```bash
# List registered clusters
kubectl -n argocd get secrets -l argocd.argoproj.io/secret-type=cluster

# Verify cluster connectivity from ArgoCD pod
kubectl -n argocd exec -it deployment/argocd-server -- \
  kubectl --kubeconfig /var/run/secrets/kubernetes.io/serviceaccount/token \
  --server=https://talos-api:6443 get nodes
```

### Access Control

- Default RBAC: Read-only for non-admin users
- Admin role required for cluster/repo management

## Future Enhancements

- [ ] Implement Sealed Secrets for application credential management
- [ ] Add ApplicationSet for templated app deployment across clusters
- [ ] Configure Prometheus monitoring for ArgoCD
- [ ] Implement ArgoCD notifications (Slack/email)
- [ ] Configure SSO
- [ ] Add AWS/Azure cluster examples

## References

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD Helm Chart](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd)

