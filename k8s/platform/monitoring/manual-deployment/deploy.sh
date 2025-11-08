#!/bin/bash

# Deploy monitoring stack to Kubernetes cluster
# Usage: ./deploy.sh [kubeadm|k3s|dry-run]

set -e

CLUSTER=${1:-kubeadm}
OVERLAY_PATH=""

case $CLUSTER in
  kubeadm)
    OVERLAY_PATH="overlays/us103-kubeadm01"
    echo "Deploying to us103-kubeadm01 cluster..."
    ;;
  k3s)
    echo "K3s overlay not yet implemented. Create overlays/us103-k3s01 first."
    exit 1
    ;;
  dry-run)
    OVERLAY_PATH="overlays/us103-kubeadm01"
    echo "Running dry-run for us103-kubeadm01..."
    ;;
  *)
    echo "Usage: $0 [kubeadm|k3s|dry-run]"
    exit 1
    ;;
esac

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed or not in PATH"
    exit 1
fi

# Check if kustomize is available
if ! command -v kustomize &> /dev/null; then
    echo "kustomize is not installed, using kubectl kustomize instead..."
    KUSTOMIZE_CMD="kubectl kustomize"
else
    KUSTOMIZE_CMD="kustomize build"
fi

# Build and apply the configuration
if [ "$CLUSTER" == "dry-run" ]; then
    echo "=== Dry Run - Generated YAML ==="
    $KUSTOMIZE_CMD "$OVERLAY_PATH"
else
    echo "Building kustomization from $OVERLAY_PATH..."
    $KUSTOMIZE_CMD "$OVERLAY_PATH" | kubectl apply -f -
    
    echo ""
    echo "=== Deployment Status ==="
    kubectl -n monitoring rollout status deployment/prometheus --timeout=300s
    kubectl -n monitoring rollout status deployment/grafana --timeout=300s
    
    echo ""
    echo "=== Access Information ==="
    echo "Grafana URL: http://grafana.infra.infutable.com"
    echo "Default credentials: admin / infutable-admin"
    echo ""
    echo "Prometheus URL (internal): http://prometheus.monitoring.svc.cluster.local:9090"
    echo ""
    echo "To access Prometheus UI locally:"
    echo "kubectl -n monitoring port-forward svc/prometheus 9090:9090"
    echo ""
    echo "=== Verify Deployment ==="
    kubectl -n monitoring get pods
    kubectl -n monitoring get pvc
    kubectl -n monitoring get ingress
fi