#!/bin/bash
#----------------------------------------------------------------------------------------------------------------
#  Bryan Smith
#  BSmithITGuy@gmail.com
#  Last Update:  08/20/2025
#
#  DESCRIPTION:
#    Removes ArgoCD.
#
#  PREREQUISITES:
#    Make sure kubectl is configured and in the right context.
#
#----------------------------------------------------------------------------------------------------------------


echo "removing ARgoCD....."
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl delete namespace argocd
