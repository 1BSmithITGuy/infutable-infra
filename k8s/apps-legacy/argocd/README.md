# ArgoCD Installation

Running install.sh will: 

1. Verify the SSH deploy key exists at the expected location
2. Verify cluster certificates exist at the expected location
3. Install ArgoCD with all manifests
4. Configure repository access using the local SSH key
5. Configure cluster access using the local certificates
6. Display the auto-generated admin password

  **NOTE:** To uninstall, run Remove-argocd.sh

## Overview

This installation provides:
- **Non-HA ArgoCD deployment** suitable for homelab/development environments
- **Secure secret management** - SSH keys and certificates stored on server, not in repository
- **NGINX Ingress integration** with TLS termination at ingress level
- **Pre-configured cluster access** for K3s and vanilla Kubernetes
- **GitHub repository integration** using read-only deploy keys

## Security Best Practices

This installation follows security best practices:
- ✅ **No secrets in Git** - SSH keys and cluster certificates are stored on the server filesystem
- ✅ **Read-only deploy keys** - Repository access is limited to read operations
- ✅ **Ingress-level TLS** - HTTPS termination at NGINX, ArgoCD runs HTTP internally
    - Note: plan to implement proper TLS in the future
- ✅ **Principle of least privilege** - Deploy keys have minimal required permissions

## Prerequisites

### 1. Directory Setup
Ensure the `/srv/secrets` directory structure exists:
```bash
sudo mkdir -p /srv/secrets/{ssh-keys,clusters}
```

### 2. SSH Deploy Key Setup
Store in `/srv/secrets/ssh-keys/automation/argocd/`

```bash
cd /srv/secrets/ssh-keys/automation/argocd/
sudo ssh-keygen -t ed25519 -C "deploy-infutable-infra-us103" \
  -f github-deploy-infutable-infra-us103 -N ""

# Set permissions
sudo chmod 644 github-deploy-infutable-infra-us103
sudo chmod 644 github-deploy-infutable-infra-us103.pub
```

### 3. Add Deploy Key to GitHub

1. Navigate to your GitHub repository: `https://github.com/1BSmithITGuy/infutable-infra`
2. Go to **Settings** → **Deploy keys**
3. Click **Add deploy key**
4. Title: `US103-ArgoCD`
5. Key: Paste the contents of the `.pub` file
6. **Leave "Allow write access" UNCHECKED** (read-only)
7. Click **Add key**

### 4. Extract Cluster Certificates

Use the helper script to extract certificates from your current kubeconfig:
```bash
./extract-cluster-certs.sh us103-k3s01
```

Or manually extract and save to `/srv/secrets/clusters/us103-k3s01/`:
- `ca.crt` - Cluster CA certificate
- `client.crt` - Client certificate
- `client.key` - Client private key

### 5. Kubernetes Cluster Requirements

- Kubernetes 1.19+ or K3s
- NGINX Ingress Controller installed
- DNS configured for `argocd.infutable.com` pointing to your ingress

## Manual Installation

If you prefer to install manually or the script fails:

```bash
# 1. Create namespace
kubectl apply -f namespace.yaml

# 2. Install ArgoCD base
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. Create repository secret from SSH key
kubectl create secret generic repo-infutable \
  --namespace=argocd \
  --from-literal=type=git \
  --from-literal=url=git@github.com:1BSmithITGuy/infutable-infra.git \
  --from-literal=project=default \
  --from-file=sshPrivateKey=/srv/secrets/ssh-keys/automation/argocd/github-deploy-infutable-infra-us103 \
  --dry-run=client -o yaml | \
  kubectl label -f - --dry-run=client -o yaml --local \
    argocd.argoproj.io/secret-type=repository | \
  kubectl apply -f -

# 4. Create cluster secret with certificates
# (See install.sh for the full cluster secret creation logic)

# 5. Apply remaining configurations
kubectl apply -f ingress.yaml

# 6. Configure ArgoCD settings
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge \
  -p '{"data":{"server.insecure":"true"}}'
kubectl patch configmap argocd-cm -n argocd --type merge \
  -p '{"data":{"url":"https://argocd.infutable.com","ui.theme":"dark"}}'

# 7. Fix service ports
kubectl patch svc argocd-server -n argocd --type='json' \
  -p='[{"op": "replace", "path": "/spec/ports/0/port", "value": 80}]'

# 8. Restart ArgoCD
kubectl -n argocd rollout restart deployment/argocd-server
```

## File Structure

```
argocd/
├── install.sh                    # Automated installation script
├── extract-cluster-certs.sh      # Helper to extract cluster certificates
├── namespace.yaml                # ArgoCD namespace
├── ingress.yaml                  # NGINX ingress configuration  
├── cluster-us103-k3s01.yaml      # Cluster metadata (no secrets)
├── Remove-argocd.sh              # Remove ArgoCD
└── README.md                     # This file
```

## Access Information

After installation:
- **URL**: https://argocd.infutable.com
- **Username**: admin
- **Password**: Check installation output or run:
  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d
  ```

## Troubleshooting

### SSH Key Issues
```bash
# Verify key exists and has correct permissions
ls -la /srv/secrets/ssh-keys/automation/argocd/

# Test GitHub connectivity
ssh -T git@github.com -i /srv/secrets/ssh-keys/automation/argocd/github-deploy-infutable-infra-us103
```

### Cluster Certificate Issues
```bash
# Verify certificates exist
ls -la /srv/secrets/clusters/us103-k3s01/

# Test cluster connectivity
kubectl --kubeconfig=/path/to/kubeconfig get nodes
```

### ArgoCD Connection Issues
```bash
# Check if repository is connected
kubectl -n argocd get secret repo-infutable -o yaml

# Check if cluster is connected
kubectl -n argocd get secret cluster-us103-k3s01 -o yaml

# View ArgoCD logs
kubectl -n argocd logs deployment/argocd-repo-server
```

### Ingress Issues
```bash
# Verify ingress is created
kubectl -n argocd get ingress

# Check NGINX ingress logs
kubectl -n ingress-nginx logs deployment/ingress-nginx-controller
```

### Check ArgoCD application controller logs for connection errors:

```bash
kubectl -n argocd logs deployment/argocd-application-controller | grep -E "(us103-k3s01|BSUS103KM01|error|failed)"
```


## Future Improvements

Potential enhancements for production:
- Implement HashiCorp Vault for centralized secret management
- Add high availability with multiple replicas
- Configure SSO/OIDC authentication
- Implement RBAC for multi-tenant access
- Add Prometheus monitoring and alerting
- Use cert-manager for automatic TLS certificate management