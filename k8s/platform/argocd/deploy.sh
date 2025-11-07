#!/bin/bash
# -----------------------------------------------------------------------------
# ArgoCD Deployment Script
#
# Bryan Smith
# BSmithITGuy@gmail.com
#
# Purpose: Deploy ArgoCD via Helm for multi-cluster management
# Prerequisites:
#   - Helm 3
#   - SSH key: /srv/secrets/ssh-keys/automation/argocd/argocd-infutable-infra
#   - GitHub deploy key added to repository
# -----------------------------------------------------------------------------

set -e  # Exit on error

# Configuration
ARGOCD_NAMESPACE="argocd"
ARGOCD_RELEASE="argocd"
HELM_CHART_REPO="https://argoproj.github.io/argo-helm"
HELM_CHART_NAME="argo-cd"
HELM_VALUES_FILE="helm-values.yaml"
SSH_KEY_PATH="/srv/secrets/ssh-keys/automation/argocd/argocd-infutable-infra"
GIT_REPO="git@github.com:1BSmithITGuy/infutable-infra.git"

# Cluster contexts
CONTROL_PLANE_CONTEXT="us103-kubeadm01"
TALOS_CONTEXT="us103-talos01"
K3S_CONTEXT="us103-k3s01"

echo "==============================================="
echo "ArgoCD Deployment - Multi-Cluster Setup"
echo "==============================================="
echo ""

# Verify prerequisites
echo "[1/9] Verifying prerequisites..."

if ! command -v helm &> /dev/null; then
    echo "ERROR: Helm is not installed"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl is not installed"
    exit 1
fi

if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "ERROR: SSH key not found at $SSH_KEY_PATH"
    echo "Please ensure the deploy key exists. Run:"
    echo "  ssh-keygen -t ed25519 -C 'argocd-infutable-infra' -f /srv/secrets/ssh-keys/automation/argocd/argocd-infutable-infra -N ''"
    exit 1
fi

echo "✓ Prerequisites verified"

# Set kubectl context
echo ""
echo "[2/9] Setting kubectl context to $CONTROL_PLANE_CONTEXT..."
kubectl config use-context "$CONTROL_PLANE_CONTEXT"

# Remove old ArgoCD if it exists
echo ""
echo "[3/9] Checking for existing ArgoCD installation..."
if kubectl get namespace "$ARGOCD_NAMESPACE" &> /dev/null; then
    read -p "ArgoCD namespace exists. Remove it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing ArgoCD installation..."
        # Try Helm uninstall first
        helm uninstall "$ARGOCD_RELEASE" -n "$ARGOCD_NAMESPACE" 2>/dev/null || true
        # Clean up with raw manifests if Helm didn't work
        kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml 2>/dev/null || true
        kubectl delete namespace "$ARGOCD_NAMESPACE" 2>/dev/null || true
        echo "Waiting for namespace to be deleted..."
        kubectl wait --for=delete namespace/"$ARGOCD_NAMESPACE" --timeout=120s 2>/dev/null || true
        echo "✓ Old installation removed"
    else
        echo "Exiting. Please remove old installation manually."
        exit 1
    fi
else
    echo "✓ No existing installation found"
fi

# Add ArgoCD Helm repository
echo ""
echo "[4/9] Adding ArgoCD Helm repository..."
helm repo add argo "$HELM_CHART_REPO" &> /dev/null || true
helm repo update > /dev/null
echo "✓ Helm repository added and updated"

# Install ArgoCD via Helm
echo ""
echo "[5/9] Installing ArgoCD via Helm..."
helm install "$ARGOCD_RELEASE" argo/"$HELM_CHART_NAME" \
  --create-namespace \
  --namespace "$ARGOCD_NAMESPACE" \
  --values "$HELM_VALUES_FILE" \
  --wait \
  --timeout 5m

echo "✓ ArgoCD installed"

# Wait for ArgoCD to be ready
echo ""
echo "[6/9] Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s \
  deployment/argocd-server -n "$ARGOCD_NAMESPACE"
echo "✓ ArgoCD is ready"

# Create repository secret
echo ""
echo "[7/9] Creating Git repository secret..."
kubectl create secret generic repo-infutable-infra \
  --namespace="$ARGOCD_NAMESPACE" \
  --from-literal=type=git \
  --from-literal=url="$GIT_REPO" \
  --from-file=sshPrivateKey="$SSH_KEY_PATH" \
  --dry-run=client -o yaml | \
  kubectl label -f - --dry-run=client -o yaml --local \
    argocd.argoproj.io/secret-type=repository | \
  kubectl apply -f -

echo "✓ Repository secret created"

# Register managed clusters
echo ""
echo "[8/10] Registering managed clusters..."

# Register Talos cluster
echo "  Registering us103-talos01 (Talos)..."
TALOS_SERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name=='us103-talos01_cluster')].cluster.server}")
TALOS_CA=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name=='us103-talos01_cluster')].cluster.certificate-authority-data}")
TALOS_CERT=$(kubectl config view --raw -o jsonpath="{.users[?(@.name=='us103-talos01-admin')].user.client-certificate-data}")
TALOS_KEY=$(kubectl config view --raw -o jsonpath="{.users[?(@.name=='us103-talos01-admin')].user.client-key-data}")

TALOS_CONFIG=$(cat <<EOF
{
  "bearerToken": "",
  "tlsClientConfig": {
    "insecure": false,
    "caData": "$TALOS_CA",
    "certData": "$TALOS_CERT",
    "keyData": "$TALOS_KEY"
  }
}
EOF
)

kubectl create secret generic cluster-us103-talos01 \
  --namespace="$ARGOCD_NAMESPACE" \
  --from-literal=name="us103-talos01" \
  --from-literal=server="$TALOS_SERVER" \
  --from-literal=config="$TALOS_CONFIG" \
  --dry-run=client -o yaml | \
  kubectl label -f - --dry-run=client -o yaml --local \
    argocd.argoproj.io/secret-type=cluster | \
  kubectl apply -f -

echo "  ✓ us103-talos01 registered"

# Register K3s cluster
echo "  Registering us103-k3s01 (K3s)..."
K3S_SERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name=='us103-k3s01_cluster')].cluster.server}")
K3S_CA=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name=='us103-k3s01_cluster')].cluster.certificate-authority-data}")
K3S_CERT=$(kubectl config view --raw -o jsonpath="{.users[?(@.name=='us103k3s01-admin')].user.client-certificate-data}")
K3S_KEY=$(kubectl config view --raw -o jsonpath="{.users[?(@.name=='us103k3s01-admin')].user.client-key-data}")

K3S_CONFIG=$(cat <<EOF
{
  "bearerToken": "",
  "tlsClientConfig": {
    "insecure": false,
    "caData": "$K3S_CA",
    "certData": "$K3S_CERT",
    "keyData": "$K3S_KEY"
  }
}
EOF
)

kubectl create secret generic cluster-us103-k3s01 \
  --namespace="$ARGOCD_NAMESPACE" \
  --from-literal=name="us103-k3s01" \
  --from-literal=server="$K3S_SERVER" \
  --from-literal=config="$K3S_CONFIG" \
  --dry-run=client -o yaml | \
  kubectl label -f - --dry-run=client -o yaml --local \
    argocd.argoproj.io/secret-type=cluster | \
  kubectl apply -f -

echo "  ✓ us103-k3s01 registered"
echo "✓ All managed clusters registered"

# Deploy ArgoCD Applications
echo ""
echo "[9/10] Deploying ArgoCD Applications..."
kubectl apply -f applications/
echo "✓ Applications deployed"

# Verify cluster registration
echo ""
echo "[10/10] Verifying cluster registration..."
sleep 3  # Give ArgoCD a moment to process
CLUSTER_COUNT=$(kubectl -n "$ARGOCD_NAMESPACE" get secrets -l argocd.argoproj.io/secret-type=cluster --no-headers 2>/dev/null | wc -l)
echo "✓ $CLUSTER_COUNT managed clusters registered"

# Get admin password
echo ""
echo "==============================================="
echo "ArgoCD Deployment Complete!"
echo "==============================================="
echo ""
echo "Access Information:"
echo "  URL:      https://argocd.infra.infutable.com"
echo "  Username: admin"
echo -n "  Password: "
kubectl -n "$ARGOCD_NAMESPACE" get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "Not available"
echo ""
echo ""
echo "Registered Clusters:"
echo "  - us103-kubeadm01 (in-cluster, Kubeadm)"
echo "  - us103-talos01   (Talos + Cilium CNI)"
echo "  - us103-k3s01     (K3s lightweight)"
echo ""
echo "Deployed Applications:"
echo "  - netbox-us103-talos01 (Netbox on Talos cluster)"
echo ""
echo "Next Steps:"
echo "  1. Log in to ArgoCD UI and verify clusters appear in Settings → Clusters"
echo "  2. Change admin password: Settings → Accounts → admin"
echo "  3. Monitor application sync status in Applications view"
echo "  4. Verify Netbox deployment: kubectl --context us103-talos01 get pods -n netbox"
echo ""
echo "To change admin password via CLI:"
echo "  argocd account update-password --current-password <current> --new-password <new>"
echo ""
echo "To verify cluster connectivity:"
echo "  kubectl -n argocd get secrets -l argocd.argoproj.io/secret-type=cluster"
echo "==============================================="
