# ArgoCD Installation

Running install.sh will: 

1. Verify the SSH deploy key exists at the expected location
2. Install ArgoCD with all manifests
3. Configure repository access using the local SSH key
4. Add the K3s cluster configuration
5. Display the auto-generated admin password


## Overview

This installation provides:
- **Non-HA ArgoCD deployment** suitable for homelab/development environments
- **Secure secret management** - SSH keys stored on server, not in repository
- **NGINX Ingress integration** with TLS termination at ingress level
- **Pre-configured cluster access** for K3s and vanilla Kubernetes
- **GitHub repository integration** using read-only deploy keys

## Security Best Practices

This installation follows security best practices:
- ✅ **No secrets in Git** - SSH keys are stored on the server filesystem
- ✅ **Read-only deploy keys** - Repository access is limited to read operations
- ✅ **Ingress-level TLS** - HTTPS termination at NGINX, ArgoCD runs HTTP internally
    - Note:  plan to implement proper TLS in the future
- ✅ **Principle of least privilege** - Deploy keys have minimal required permissions

## Prerequisites

### 1. SSH Deploy Key Setup
- Store in the directory /srv/ssh-keys/automation/argocd/repos/infutable-infra
- Naming convention: id_ed25519_github-deploy-{repo}-{site}

```bash
sudo ssh-keygen -t ed25519 -C "deploy-infutable-infra-us103" \
  -f id_ed25519_github-deploy-infutable-infra-us103 -N ""

# Set permissions
sudo chmod 644 id_ed25519_github-deploy-infutable-infra-us103
sudo chmod 644 id_ed25519_github-deploy-infutable-infra-us103.pub
```

### 2. Add Deploy Key to GitHub

1. Navigate to your GitHub repository: `https://github.com/1BSmithITGuy/infutable-infra`
2. Go to **Settings** → **Deploy keys**
3. Click **Add deploy key**
4. Title: `US103-ArgoCD`
5. Key: Paste the contents of the `.pub` file
6. **Leave "Allow write access" UNCHECKED** (read-only)
7. Click **Add key**

### 3. Kubernetes Cluster Requirements

- Kubernetes 1.19+ or K3s
- NGINX Ingress Controller installed
- DNS configured for `argocd.infutable.com` pointing to your ingress

### Manual Installation

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
  --from-file=sshPrivateKey=/srv/ssh-keys/automation/argocd/repos/infutable-infra/id_ed25519_github-deploy-infutable-infra-us103 \
  --dry-run=client -o yaml | \
  kubectl label -f - --dry-run=client -o yaml --local \
    argocd.argoproj.io/secret-type=repository | \
  kubectl apply -f -

# 4. Apply remaining configurations
kubectl apply -f cluster-us103-k3s01.yaml
kubectl apply -f ingress.yaml

# 5. Configure ArgoCD settings
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge \
  -p '{"data":{"server.insecure":"true"}}'
kubectl patch configmap argocd-cm -n argocd --type merge \
  -p '{"data":{"url":"https://argocd.infutable.com","ui.theme":"dark"}}'

# 6. Fix service ports
kubectl patch svc argocd-server -n argocd --type='json' \
  -p='[{"op": "replace", "path": "/spec/ports/0/port", "value": 80}]'

# 7. Restart ArgoCD
kubectl -n argocd rollout restart deployment/argocd-server
```

## File Structure

```
argocd/
├── install.sh                    # Automated installation script
├── namespace.yaml                # ArgoCD namespace
├── ingress.yaml                  # NGINX ingress configuration  
├── cluster-us103-k3s01.yaml      # K3s cluster credentials
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
ls -la /srv/ssh-keys/automation/argocd/repos/infutable-infra/

# Test GitHub connectivity
ssh -T git@github.com -i /srv/ssh-keys/automation/argocd/repos/infutable-infra/id_ed25519_github-deploy-infutable-infra-us103
```

### ArgoCD Connection Issues
```bash
# Check if repository is connected
kubectl -n argocd get secret repo-infutable -o yaml

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

## Future Improvements

Potential enhancements for production:
- Implement HashiCorp Vault for centralized secret management
- Add high availability with multiple replicas
- Configure SSO/OIDC authentication
- Implement RBAC for multi-tenant access
- Add Prometheus monitoring and alerting
- Use cert-manager for automatic TLS certificate management