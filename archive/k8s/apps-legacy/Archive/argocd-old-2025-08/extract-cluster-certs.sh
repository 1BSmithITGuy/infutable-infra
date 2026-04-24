#!/bin/bash
#----------------------------------------------------------------------------------------------------------------
#  Bryan Smith
#  BSmithITGuy@gmail.com
#  Last Update:  08/20/2025
#
#  DESCRIPTION:
#    Extracts cluster certificates from existing kubeconfig and saves them to /srv/secrets/clusters/
#
#  USAGE:
#    ./extract-cluster-certs.sh [cluster-name]
#    Example: ./extract-cluster-certs.sh us103-k3s01
#----------------------------------------------------------------------------------------------------------------

CLUSTER_NAME=${1:-us103-k3s01}
SECRETS_DIR="/srv/secrets/clusters/$CLUSTER_NAME"

echo "Extracting certificates for cluster: $CLUSTER_NAME"

# Create directory if it doesn't exist
sudo mkdir -p "$SECRETS_DIR"

# Extract from current kubeconfig context
echo "Extracting CA certificate..."
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d | sudo tee "$SECRETS_DIR/ca.crt" > /dev/null

echo "Extracting client certificate..."
# For K3s, the client cert might include the full chain. We need just the first certificate.
kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' | base64 -d | \
  awk '/-----BEGIN CERTIFICATE-----/{p=1} p{print} /-----END CERTIFICATE-----/{if(p==1) exit}' | \
  sudo tee "$SECRETS_DIR/client.crt" > /dev/null

echo "Extracting client key..."
kubectl config view --raw -o jsonpath='{.users[0].user.client-key-data}' | base64 -d | sudo tee "$SECRETS_DIR/client.key" > /dev/null

# Set appropriate permissions and ownership
sudo chmod 644 "$SECRETS_DIR/ca.crt"
sudo chmod 644 "$SECRETS_DIR/client.crt"
sudo chmod 640 "$SECRETS_DIR/client.key"  # 640 allows group read

# Set group ownership to gitadmins
sudo chgrp gitadmins "$SECRETS_DIR/ca.crt"
sudo chgrp gitadmins "$SECRETS_DIR/client.crt"
sudo chgrp gitadmins "$SECRETS_DIR/client.key"

echo ""
echo "Certificates extracted to: $SECRETS_DIR"
echo "Files created:"
echo "  - ca.crt (CA certificate)"
echo "  - client.crt (Client certificate)"
echo "  - client.key (Client private key)"
echo ""
echo "You can now run install.sh to deploy ArgoCD"