#!/bin/bash
#----------------------------------------------------------------------------------------------------------------
#  Bryan Smith
#  BSmithITGuy@gmail.com
#  Last Update:  08/24/2025
#
#  DESCRIPTION: 
#    - Deploys node exporter so prometheus can gather stats from other nodes.
#    - Below is setup for my k3s cluster.  
#    - Use this same process to deploy to other k8s nodes.
#----------------------------------------------------------------------------------------------------------------

echo "Deploying node-exporter to K3s cluster..."
kubectl config use-context us103-k3s01
helm install node-exporter prometheus-community/prometheus-node-exporter \
  -n monitoring --create-namespace \
  --set service.type=NodePort \
  --set service.nodePort=30910

echo "Switching back to kubeadm context..."
kubectl config use-context us103-kubeadm01