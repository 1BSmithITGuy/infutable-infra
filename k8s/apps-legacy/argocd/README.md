#  ArgoCD deployment

#  Get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

---
**Note:** This repository contains a read-only deploy key in the manifests. It is included *only* for demonstration/interview purposes. The repository is public, so the key does not grant extra privileges.
