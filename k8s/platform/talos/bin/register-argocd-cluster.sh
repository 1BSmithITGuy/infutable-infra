#!/usr/bin/env bash
# Registers the us103-talos01 cluster with Argo CD (running on us103-kubeadm01)
set -euo pipefail

CLUSTER="us103-talos01"                                    # Talos/K8s cluster name
ARGO_CTX="us103-kubeadm01"                                 # kube context where ArgoCD runs
SERVER="${SERVER:-https://bsus103tal-k8m01.k8s.infutable.com:6443}"  # K8s API for Talos CP
SECB="/srv/secrets/clusters/$CLUSTER"

# Ensure secrets exist (generate once with: talosctl --nodes <cp-ip> kubeconfig $SECB/kubeconfig --force)
for f in ca.crt admin.crt admin.key; do
  [[ -s "$SECB/$f" ]] || { echo "Missing $SECB/$f — extract from kubeconfig first."; exit 1; }
done

# base64 wrapper (GNU vs macOS)
b64() { if base64 --help 2>&1 | grep -q -- "-w"; then base64 -w0 "$1"; else base64 -b 0 "$1"; fi; }

# Optional reachability check (warn-only)
if command -v nc >/dev/null 2>&1; then
  host="$(echo "$SERVER" | sed -E 's#https?://([^:/]+).*#\1#')"
  nc -z -w2 "$host" 6443 || echo "Warn: $SERVER not reachable on 6443; proceeding."
fi

CA=$(b64 "$SECB/ca.crt")
CRT=$(b64 "$SECB/admin.crt")
KEY=$(b64 "$SECB/admin.key")

tmp="$(mktemp)"
cat > "$tmp" <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: cluster-$CLUSTER
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
    site: us103
    env: lab
type: Opaque
stringData:
  name: $CLUSTER
  server: $SERVER
  config: |
    {
      "tlsClientConfig": {
        "insecure": false,
        "caData":   "$CA",
        "certData": "$CRT",
        "keyData":  "$KEY"
      }
    }
YAML

kubectl --context "$ARGO_CTX" -n argocd apply -f "$tmp"
rm -f "$tmp"

echo "✓ Registered $CLUSTER with ArgoCD on context $ARGO_CTX"
echo "Verify: kubectl --context $ARGO_CTX -n argocd get secret cluster-$CLUSTER -o yaml | grep secret-type"
