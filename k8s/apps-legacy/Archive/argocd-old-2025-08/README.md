# Archived: Old ArgoCD Deployment (August 2025)

**Archived Date:** November 7, 2025
**Reason:** Replaced with production-ready Helm-based deployment

## Original Deployment Method

This was the original ArgoCD deployment using:
- Raw Kubernetes manifests from upstream
- Bash scripts with manual `kubectl patch` commands
- Mixed imperative/declarative approach
- Secrets stored in Git (security issue)

## Why It Was Replaced

1. **Not production-ready:** Raw manifests with manual patches
2. **Security issues:** GitHub PAT stored in base64 in repo
3. **Hard to maintain:** Mix of Kustomize and bash scripts
4. **Not GitOps:** Manual UI configuration required

## New Deployment Location

The new ArgoCD deployment is located at:
```
k8s/platform/argocd/
```

**New approach uses:**
- Official Helm chart
- Declarative configuration via helm-values.yaml
- SSH deploy keys (never in Git)
- Multi-cluster management
- Proper GitOps from day one

## Migration Notes

The new deployment was created from scratch. No migration of the old deployment was performed - ArgoCD was removed and reinstalled cleanly.

**Original installation script:** See `install.sh` in this directory for reference.
