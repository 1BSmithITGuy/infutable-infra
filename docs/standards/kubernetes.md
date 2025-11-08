# Infutable Kubernetes Standards

## DNS Naming Conventions

### Cluster Ingress Endpoints (A Records)

Each nginx ingress LoadBalancer service gets an A record pointing to its IP address:

| Hostname                                          | IP            | Network Type | MetalLB Pool           |
|---------------------------------------------------|---------------|--------------|------------------------|
| us103-talos01-nginx-bgp-01.infra.infutable.com    | 172.25.200.1  | BGP Infra    | public-infra-bgp-pool  |
| us103-talos01-nginx-bgp-01.apps.infutable.com     | 172.25.250.1  | BGP App      | public-app-bgp-pool    |
| us103-kubeadm01-nginx-l2-01.infra.infutable.com   | 10.0.0.16     | L2 Private   | private-infra-l2-pool  |
| us103-kubeadm01-nginx-l2-01.apps.infutable.com    | 10.0.0.17     | L2 Public    | public-l2-pool         |

### Service Endpoints (CNAMEs)

Application and infrastructure services use CNAMEs pointing to cluster ingress endpoints:

| Service CNAME                        | Target A Record                                    | Rationale                    |
|--------------------------------------|----------------------------------------------------|------------------------------|
| netbox.infra.infutable.com           | us103-talos01-nginx-bgp-01.infra.infutable.com     | Single production instance   |
| hubble-talos01.infra.infutable.com   | us103-talos01-nginx-bgp-01.infra.infutable.com     | Cluster-specific service     |
| hubble-kubeadm01.infra.infutable.com | us103-kubeadm01-nginx-l2-01.infra.infutable.com    | Cluster-specific service     |

**Service Naming Rules:**
- **Omit cluster name** for services with a single production instance (e.g., `netbox.infra.infutable.com`)
- **Include cluster name** for cluster-specific services (e.g., `hubble-talos01.infra.infutable.com`)

**DNS Zone Usage:**
- `.infra.infutable.com` - Infrastructure services (less exposed, internal-focused)
- `.apps.infutable.com` - Application services (more public-facing)

## IngressClass Standards

Standardized across all clusters for application portability:

| IngressClass     | Network Type | Load Balancer Implementation | Clusters            |
|------------------|--------------|------------------------------|---------------------|
| `nginx-public`   | BGP          | MetalLB BGP                  | us103-talos01       |
| `nginx-public`   | L2 Public    | Cilium L2 Announcement       | us103-kubeadm01     |
| `nginx-infra`    | L2 Private   | Cilium L2 Announcement       | us103-kubeadm01     |

## LoadBalancer Service Naming

Pattern: `nginx-<network>-<type>-lb`

| Service Name           | Namespace      | IngressClass   | IP Pool                | Cluster         |
|------------------------|----------------|----------------|------------------------|-----------------|
| nginx-public-app-lb    | ingress-nginx  | nginx-public   | public-app-bgp-pool    | us103-talos01   |
| nginx-public-infra-lb  | ingress-nginx  | nginx-public   | public-infra-bgp-pool  | us103-talos01   |
| nginx-public-lb        | ingress-nginx  | nginx-public   | public-l2-pool         | us103-kubeadm01 |
| nginx-infra-lb         | ingress-nginx  | nginx-infra    | private-infra-l2-pool  | us103-kubeadm01 |

## ArgoCD Deployment Pattern

### Application Structure

Use base + overlay pattern for maximum reusability:

```
k8s/apps/<app-name>/
├── base/
│   ├── kustomization.yaml
│   └── <common-manifests>.yaml
└── overlays/
    ├── <cluster-name>/
    │   ├── kustomization.yaml
    │   └── <cluster-specific-patches>.yaml
    └── <another-cluster>/
        ├── kustomization.yaml
        └── <cluster-specific-patches>.yaml
```

**When to use base/:**
- Common resource definitions (Deployments, Services, ConfigMaps)
- Shared across multiple clusters
- Keep minimal - only what's truly common

**When to use overlays/:**
- Cluster-specific values (hostnames, IngressClass, StorageClass)
- Environment-specific configuration
- Resource limits/requests that differ by cluster

### ArgoCD Application Manifest

Location: `k8s/platform/argocd/applications/<cluster-name>/<app-name>.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <app-name>-<cluster-name>
  namespace: argocd
  labels:
    site: <site-id>                           # e.g., us103
    cluster: <cluster-name>                   # e.g., us103-talos01
    cluster-type: <type>                      # talos, kubeadm, k3s
    app.kubernetes.io/name: <app-name>
    app.kubernetes.io/component: <component>  # ingress, database, cache, etc.
    app.kubernetes.io/part-of: <category>     # platform, infrastructure, application
    managed-by: argocd
    environment: production
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: git@github.com:1BSmithITGuy/infutable-infra.git
    targetRevision: main
    path: k8s/apps/<app-name>/overlays/<cluster-name>
  destination:
    # For Talos/K3s (remote clusters):
    name: <cluster-name>
    # For Kubeadm (in-cluster):
    server: https://kubernetes.default.svc
    namespace: <target-namespace>
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
```

### Helm-Based Applications

For Helm charts, use `values.yaml` in overlay:

```
k8s/apps/<app-name>/
├── base/
│   ├── kustomization.yaml
│   └── <app-name>.yaml          # ArgoCD Application manifest
└── overlays/
    └── <cluster-name>/
        ├── kustomization.yaml
        └── values.yaml          # Cluster-specific Helm values
```

**ArgoCD Application spec.source for Helm:**

```yaml
source:
  repoURL: https://charts.example.com
  chart: <chart-name>
  targetRevision: <version>
  helm:
    releaseName: <app-name>
    valueFiles:
      - values.yaml
```

## Storage Standards

| StorageClass  | Provisioner              | Default | Clusters            |
|---------------|--------------------------|---------|---------------------|
| `local-path`  | rancher.io/local-path    | Yes     | All clusters        |

**Important:** The `local-path-storage` namespace requires privileged PSA labels on Talos clusters:

```yaml
pod-security.kubernetes.io/enforce: privileged
pod-security.kubernetes.io/audit: privileged
pod-security.kubernetes.io/warn: privileged
```

## Secrets Management

**Location:** `/srv/secrets/` on jump station/server

**Directory Structure:**

```
/srv/secrets/
├── clusters/
│   └── <cluster-name>/              # Cluster certificates and kubeconfigs
│       ├── ca.crt
│       ├── client.crt
│       ├── client.key
│       ├── kubeconfig               # Kubernetes config
│       └── talosconfig              # Talos-specific config (Talos only)
├── ssh-keys/
│   ├── automation/
│   │   ├── argocd/
│   │   │   ├── argocd-infutable-infra     # SSH private key for Git access
│   │   │   └── argocd-infutable-infra.pub # SSH public key
│   │   └── terraform/
│   ├── human/
│   │   └── <username>/
│   │       ├── github
│   │       └── infra
│   └── known_hosts
└── <app-name>/                      # Application-specific secrets
    └── *.yaml                       # Kubernetes Secret manifests
```

**Notes:**
- ArgoCD SSH key is used for Git repository access to `git@github.com:1BSmithITGuy/infutable-infra.git`
- Secrets are manually managed and not stored in Git
- Cluster certificates are generated during cluster bootstrap

### Application Secrets Pattern

**DO NOT commit application secrets to Git.** Instead, store them in `/srv/secrets/<app-name>/` and reference them using `existingSecret`.

**Example: Netbox PostgreSQL credentials**

1. **Create secret manifest** in `/srv/secrets/netbox/postgresql-passwords.yaml`:
   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: netbox-postgresql-credentials
     namespace: netbox
   type: Opaque
   stringData:
     postgres-password: "YourSecurePassword"
     password: "YourSecurePassword"
   ```

2. **Apply manually to cluster:**
   ```bash
   kubectl --context <cluster> apply -f /srv/secrets/netbox/postgresql-passwords.yaml
   ```

3. **Reference in Helm values.yaml** (stored in Git):
   ```yaml
   postgresql:
     auth:
       existingSecret: netbox-postgresql-credentials
       secretKeys:
         adminPasswordKey: postgres-password
         userPasswordKey: password
   ```

**Benefits:**
- Secrets stay out of Git history
- ArgoCD won't delete manually-created secrets
- Easy migration path to Vault later

**Future:** Migrate to HashiCorp Vault for centralized secret management

## Cluster Architecture

### us103-talos01
- **CNI:** Cilium (eBPF-based)
- **Load Balancer:** MetalLB (BGP mode)
- **Ingress Controller:** ingress-nginx
- **Storage:** local-path-provisioner
- **Pod Security:** Enforced (some namespaces require privileged label)

### us103-kubeadm01
- **CNI:** Cilium (eBPF-based)
- **Load Balancer:** Cilium L2 Announcement (Layer 2 mode)
- **Ingress Controller:** ingress-nginx
- **Storage:** local-path-provisioner
- **ArgoCD Control Plane:** Manages all clusters

### us103-k3s01
- **CNI:** Cilium (eBPF-based)
- **Load Balancer:** Cilium L2 Announcement
- **Ingress Controller:** ingress-nginx (standard)
- **Storage:** local-path-provisioner

## MetalLB IP Address Pools (us103-talos01)

| Pool Name               | CIDR             | Purpose                     | BGP Advertised |
|-------------------------|------------------|-----------------------------|----------------|
| public-infra-bgp-pool   | 172.25.200.0/27  | Infrastructure services     | Yes            |
| public-app-bgp-pool     | 172.25.250.0/27  | Application services        | Yes            |

## Cilium L2 Pools (us103-kubeadm01)

| Pool Name               | IP Range        | Purpose                     |
|-------------------------|-----------------|-----------------------------|
| private-infra-l2-pool   | 10.0.0.16/32    | Private infrastructure      |
| public-l2-pool          | 10.0.0.17/32    | Public-facing services      |
