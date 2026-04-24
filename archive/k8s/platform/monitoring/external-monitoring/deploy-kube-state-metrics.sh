#!/bin/bash
#----------------------------------------------------------------------------------------------------------------
#  Bryan Smith
#  BSmithITGuy@gmail.com
#  Last Update:  08/24/2025
#
#  DESCRIPTION: 
#    - Install kube-state-metrics so prometheus can gather pod stats from external clusters
#    - Below is setup for my k3s cluster.  
#    - Use this same process to deploy to other k8s clusters.
#
#  NOTES:
#     -  kube-state-metrics is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects.
#     -  The exposed metrics can be found here:
#     https://github.com/kubernetes/kube-state-metrics/blob/master/docs/README.md#exposed-metrics
#
#----------------------------------------------------------------------------------------------------------------

echo "Deploying kube-state-metrics to K3s cluster..."
kubectl config use-context us103-k3s01

helm install kube-state-metrics prometheus-community/kube-state-metrics \
  -n monitoring \
  --set service.type=NodePort \
  --set service.nodePort=30911


echo "Switching back to kubeadm context..."
kubectl config use-context us103-kubeadm01


