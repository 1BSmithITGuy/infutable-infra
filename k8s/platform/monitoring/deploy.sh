#!/bin/bash
# Deploy monitoring stack using Helm

set -e

echo "=== Deploying Monitoring Stack ==="

# Check prerequisites
command -v helm >/dev/null 2>&1 || { echo "Helm required but not installed. Aborting." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl required but not installed. Aborting." >&2; exit 1; }

# Add Helm repo
echo "Adding prometheus-community Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Deploy
echo "Installing kube-prometheus-stack..."
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f prometheus-values.yaml \
  --wait --timeout 10m

echo ""
echo "=== Deployment Complete ==="
echo "Grafana URL: http://grafana.us103kubeadm01.infutable.com"
echo ""
echo "Retrieve admin password:"
echo "kubectl get secret -n monitoring monitoring-grafana -o jsonpath=\"{.data.admin-password}\" | base64 -d"
echo ""
echo "View pods:"
echo "kubectl get pods -n monitoring"