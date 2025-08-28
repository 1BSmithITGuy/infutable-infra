#!/bin/bash
# k8s/platform/rancher/self-managed/deploy.sh
# Deployment script for Rancher on kubeadm cluster

set -e

# Configuration
RANCHER_NAMESPACE="cattle-system"
RANCHER_CHART_VERSION="2.12.0"  # Latest version that supports K8s v1.33
HELM_REPO_NAME="rancher-latest"
HELM_REPO_URL="https://releases.rancher.com/server-charts/latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

echo_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

echo_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    echo_info "Checking prerequisites..."
    
    # Check if kubectl is working
    if ! kubectl cluster-info > /dev/null 2>&1; then
        echo_error "kubectl is not configured or cluster is not accessible"
        exit 1
    fi
    
    # Check if helm is installed
    if ! command -v helm &> /dev/null; then
        echo_error "Helm is not installed. Please install Helm first."
        exit 1
    fi
    
    # Check if cert-manager is running
    if ! kubectl get pods -n cert-manager | grep -q "cert-manager.*Running"; then
        echo_error "cert-manager is not running. Rancher requires cert-manager."
        exit 1
    fi
    
    echo_success "Prerequisites check passed!"
}

# Function to add Helm repository
add_helm_repo() {
    echo_info "Adding Rancher Helm repository..."
    
    if helm repo list | grep -q "^${HELM_REPO_NAME}"; then
        echo_info "Rancher repository already exists, updating..."
        helm repo update ${HELM_REPO_NAME}
    else
        echo_info "Adding Rancher repository..."
        helm repo add ${HELM_REPO_NAME} ${HELM_REPO_URL}
        helm repo update
    fi
    
    echo_success "Helm repository configured!"
}

# Function to create namespace
create_namespace() {
    echo_info "Creating ${RANCHER_NAMESPACE} namespace..."
    
    if kubectl get namespace ${RANCHER_NAMESPACE} > /dev/null 2>&1; then
        echo_info "Namespace ${RANCHER_NAMESPACE} already exists"
    else
        kubectl create namespace ${RANCHER_NAMESPACE}
        echo_success "Namespace ${RANCHER_NAMESPACE} created!"
    fi
}

# Function to deploy Rancher
deploy_rancher() {
    echo_info "Deploying Rancher..."
    
    # Get the directory of this script
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    VALUES_FILE="${SCRIPT_DIR}/helm-values.yaml"
    
    if [[ ! -f "$VALUES_FILE" ]]; then
        echo_error "Values file not found at $VALUES_FILE"
        exit 1
    fi
    
    # Deploy or upgrade Rancher
    helm upgrade --install rancher ${HELM_REPO_NAME}/rancher \
        --namespace ${RANCHER_NAMESPACE} \
        --version ${RANCHER_CHART_VERSION} \
        --values ${VALUES_FILE} \
        --set ingress.ingressClassName=nginx \
        --wait \
        --timeout 20m
    
    echo_success "Rancher deployment completed!"
}

# Function to check deployment status
check_deployment() {
    echo_info "Checking Rancher deployment status..."
    
    # Wait for rollout to complete
    kubectl rollout status deployment/rancher -n ${RANCHER_NAMESPACE} --timeout=300s
    
    # Show pod status
    echo_info "Rancher pods:"
    kubectl get pods -n ${RANCHER_NAMESPACE} -l app=rancher
    
    # Show service status
    echo_info "Rancher service:"
    kubectl get svc -n ${RANCHER_NAMESPACE} -l app=rancher
    
    # Show ingress status
    echo_info "Rancher ingress:"
    kubectl get ingress -n ${RANCHER_NAMESPACE}
    
    echo_success "Deployment check completed!"
}

# Function to display access information
show_access_info() {
    echo_success "Rancher deployment completed successfully!"
    echo ""
    echo_info "Access Information:"
    echo "  URL: https://rancher.us103kubeadm01.infutable.com"
    echo "  Bootstrap Password: infUtableR@ncher2024!"
    echo ""
    echo_warning "Next steps:"
    echo "  1. DNS already configured with wildcard *.us103kubeadm01.infutable.com ✓"
    echo "  2. Wait for certificate to be issued (check with: kubectl get certificate -n cattle-system)"
    echo "  3. Access the Rancher UI and complete initial setup"
    echo "  4. Import your K3s cluster as a downstream cluster"
    echo ""
    echo_info "To check certificate status:"
    echo "  kubectl get certificate -n cattle-system"
    echo "  kubectl describe certificate tls-rancher-ingress -n cattle-system"
}

# Main deployment function
main() {
    echo_info "Starting Rancher deployment for infUTable homelab..."
    echo_info "Target cluster: us103-kubeadm01"
    echo ""
    
    check_prerequisites
    add_helm_repo
    create_namespace
    deploy_rancher
    check_deployment
    show_access_info
}

# Run main function
main "$@"