#!/bin/bash

# Get all terminating namespaces
TERMINATING_NS=$(kubectl get ns | grep Terminating | awk '{print $1}')

for ns in $TERMINATING_NS; do
  echo "Force cleaning namespace: $ns"
  
  # Method 1: Remove finalizers via API
  kubectl get namespace $ns -o json | \
    jq '.spec.finalizers = []' | \
    kubectl replace --raw "/api/v1/namespaces/$ns/finalize" -f -
  
  # If still stuck, try method 2: Patch directly
  kubectl patch namespace $ns -p '{"metadata":{"finalizers":null}}' --type=merge
  
  # Check status
  kubectl get ns $ns 2>/dev/null || echo "Namespace $ns deleted successfully"
done







