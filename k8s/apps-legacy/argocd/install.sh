#!/bin/bash
#----------------------------------------------------------------------------------------------------------------
#  Bryan Smith
#  BSmithITGuy@gmail.com
#  Last Update:  08/20/2025
#
#  DESCRIPTION:
#    Installs ArgoCD, adds repo, and adds k3s cluster.
#
#  PREREQUISITES:
#    -  Kubectl is installed and in the correct context.  
#    -  SSH key is setup in github and in the correct directory (see README.md)
#----------------------------------------------------------------------------------------------------------------

# Configuration
SSH_KEY_PATH="/srv/ssh-keys/automation/argocd/repos/infutable-infra/id_ed25519_github-deploy-infutable-infra-us103"
GITHUB_REPO="git@github.com:1BSmithITGuy/infutable-infra.git"

echo "==================================="
echo "Installing ArgoCD..."
echo "==================================="

# Verify SSH key exists
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "ERROR: SSH key not found at $SSH_KEY_PATH"
    echo "Please ensure the deploy key is created and placed at the correct location."
    echo "See README.md for instructions on creating deploy keys."
    exit 1
fi

echo "✓ SSH deploy key found at $SSH_KEY_PATH"

# Create namespace
echo "Creating namespace..."
kubectl apply -f namespace.yaml

# Install base ArgoCD
echo "Installing base ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for base installation to settle
echo "Waiting for base installation to settle..."
sleep 10

# Create repository secret from local SSH key
echo "Setting up GitHub repository access with local SSH key..."
kubectl create secret generic repo-infutable \
  --namespace=argocd \
  --from-literal=type=git \
  --from-literal=url="$GITHUB_REPO" \
  --from-literal=project=default \
  --from-file=sshPrivateKey="$SSH_KEY_PATH" \
  --dry-run=client -o yaml | \
  kubectl label -f - --dry-run=client -o yaml --local \
    argocd.argoproj.io/secret-type=repository | \
  kubectl apply -f -

echo "Adding K3s cluster configuration..."
kubectl apply -f cluster-us103-k3s01.yaml

echo "Configuring ingress..."
kubectl apply -f ingress.yaml

# Configure ArgoCD for insecure mode and dark theme
echo "Configuring ArgoCD settings..."
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge \
  -p '{"data":{"server.insecure":"true"}}'

kubectl patch configmap argocd-cm -n argocd --type merge \
  -p '{"data":{"url":"https://argocd.infutable.com","ui.theme":"dark"}}'

# Patch the service to use port 80
echo "Patching service ports..."
kubectl patch svc argocd-server -n argocd --type='json' \
  -p='[{"op": "replace", "path": "/spec/ports/0/port", "value": 80},
       {"op": "replace", "path": "/spec/ports/0/targetPort", "value": 8080}]'

# Restart ArgoCD server to pick up all changes
echo "Restarting ArgoCD server..."
kubectl -n argocd rollout restart deployment/argocd-server

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl -n argocd rollout status deployment/argocd-server

# Get the initial admin password
echo ""
echo "==================================="
echo "ArgoCD Installation Complete!"
echo "==================================="
echo ""
echo "Access ArgoCD at: https://argocd.infutable.com"
echo "Username: admin"
echo -n "Password: "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "No initial password found - check if already changed"
echo ""
echo ""
echo "✓ Dark theme enabled"
echo "✓ GitHub repository configured: $GITHUB_REPO"
echo "✓ K3s cluster added: us103-k3s01"
echo "✓ SSH key loaded from: $SSH_KEY_PATH"
echo ""
echo "To change the admin password after login:"
echo "  argocd account update-password"
echo "==================================="