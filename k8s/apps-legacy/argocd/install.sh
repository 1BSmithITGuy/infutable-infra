#!/bin/bash
#----------------------------------------------------------------------------------------------------------------
#  Bryan Smith
#  BSmithITGuy@gmail.com
#  Last Update:  08/21/2025
#
#  DESCRIPTION:
#    Installs ArgoCD, adds repo, and adds k3s cluster.
#
#  PREREQUISITES:
#    -  Kubectl is installed and in the correct context.  
#    -  SSH key is setup in github and in the correct directory (see README.md)
#    -  Cluster certificates are stored in /srv/secrets/clusters/us103-k3s01/
#    -  Required files:   
#       ├── namespace.yaml                # ArgoCD namespace
#       ├── ingress.yaml                  # NGINX ingress configuration  
#       ├── cluster-us103-k3s01.yaml      # Cluster metadata (no secrets)
#----------------------------------------------------------------------------------------------------------------

# Configuration
SECRETS_BASE="/srv/secrets"
SSH_KEY_PATH="$SECRETS_BASE/ssh-keys/automation/argocd/github-deploy-infutable-infra-us103"
CLUSTER_CERTS_PATH="$SECRETS_BASE/clusters/us103-k3s01"
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

# Verify cluster certificates exist
if [ ! -f "$CLUSTER_CERTS_PATH/ca.crt" ] || [ ! -f "$CLUSTER_CERTS_PATH/client.crt" ] || [ ! -f "$CLUSTER_CERTS_PATH/client.key" ]; then
    echo "ERROR: Cluster certificates not found at $CLUSTER_CERTS_PATH"
    echo "Please ensure the following files exist:"
    echo "  - $CLUSTER_CERTS_PATH/ca.crt"
    echo "  - $CLUSTER_CERTS_PATH/client.crt"
    echo "  - $CLUSTER_CERTS_PATH/client.key"
    exit 1
fi

echo "✓ Cluster certificates found at $CLUSTER_CERTS_PATH"

# Create namespace
echo "Creating namespace..."
kubectl apply -f namespace.yaml

# Install base ArgoCD
echo "Installing base ArgoCD..."
# Use local manifest file if it exists, otherwise download from stable
if [ -f "argocd-install.yaml" ]; then
    echo "Using local argocd-install.yaml"
    kubectl apply -n argocd -f argocd-install.yaml
else
    echo "WARNING: No local argocd-install.yaml found, downloading from stable branch"
    echo "Run ./download-argocd-manifests.sh to download a specific version"
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
fi

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

# Create cluster secret with certificates from local files
echo "Adding K3s cluster configuration with local certificates..."

# Read certificates (no sudo needed with group permissions)
CA_CERT=$(base64 -w0 < "$CLUSTER_CERTS_PATH/ca.crt")
CLIENT_CERT=$(base64 -w0 < "$CLUSTER_CERTS_PATH/client.crt")
CLIENT_KEY=$(base64 -w0 < "$CLUSTER_CERTS_PATH/client.key")

# Create the cluster config JSON (NO base64 encoding here)
CLUSTER_CONFIG=$(cat <<EOF
{
  "bearerToken": "",
  "tlsClientConfig": {
    "insecure": false,
    "caData": "$CA_CERT",
    "certData": "$CLIENT_CERT",
    "keyData": "$CLIENT_KEY"
  }
}
EOF
)

# Create the cluster secret (kubectl will base64 encode it automatically)
kubectl create secret generic cluster-us103-k3s01 \
  --namespace=argocd \
  --from-literal=name="us103-k3s01" \
  --from-literal=server="https://BSUS103KM01:6443" \
  --from-literal=config="$CLUSTER_CONFIG" \
  --dry-run=client -o yaml | \
  kubectl label -f - --dry-run=client -o yaml --local \
    argocd.argoproj.io/secret-type=cluster | \
  kubectl apply -f -

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
echo "✓ Cluster certificates loaded from: $CLUSTER_CERTS_PATH"
echo ""
echo "To change the admin password after login:"
echo "  argocd account update-password"
echo "==================================="