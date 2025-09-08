Bryan Smith
09/06/2025


# Cilium CNI Installation on Talos Linux

This guide provides the production-ready method for deploying Cilium as the CNI on Talos Linux clusters.

## Prerequisites

- Talos cluster initialized and running
- `kubectl` configured to access the cluster
- `helm` CLI installed (v3.x)
- `talosctl` configured (optional, for verification)

## Why This Approach?

Talos Linux has specific security constraints that prevent standard Cilium installations from working:
- Restricted capabilities (no `CAP_SYS_MODULE`)
- Different CNI binary path (`/var/lib/cni/bin` instead of `/opt/cni/bin`)
- Specific API server proxy configuration

## Installation Method

### Step 1: Add Cilium Helm Repository

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update
```

### Step 2: Install Cilium with Talos-Specific Values

```bash
helm install cilium cilium/cilium \
  --version 1.18.1 \
  --namespace kube-system \
  --set ipam.mode=kubernetes \
  --set kubeProxyReplacement=true \
  --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
  --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
  --set cgroup.autoMount.enabled=false \
  --set cgroup.hostRoot=/sys/fs/cgroup \
  --set k8sServiceHost=localhost \
  --set k8sServicePort=7445
```

### Step 3: Verify Installation

```bash
# Check Cilium pods are running
kubectl get pods -n kube-system -l app.kubernetes.io/part-of=cilium

# Wait for all pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=cilium -n kube-system --timeout=300s

# Check Cilium status (optional)
kubectl exec -n kube-system -it $(kubectl get pods -n kube-system -l app.kubernetes.io/name=cilium-agent -o jsonpath='{.items[0].metadata.name}') -- cilium status
```

### Step 4: Disable kube-proxy (Optional but Recommended)

Since Cilium is running with `kubeProxyReplacement=true`, kube-proxy is redundant:

```bash
kubectl patch daemonset kube-proxy -n kube-system -p '{"spec":{"template":{"spec":{"nodeSelector":{"non-existing-node": "true"}}}}}'
```

## Configuration Parameters Explained

| Parameter | Value | Purpose |
|-----------|--------|---------|
| `ipam.mode` | `kubernetes` | Use Kubernetes host-scope IPAM (required for Talos) |
| `kubeProxyReplacement` | `true` | Replace kube-proxy with eBPF for better performance |
| `securityContext.capabilities.ciliumAgent` | (see above) | Talos-compatible capabilities (excludes `SYS_MODULE`) |
| `securityContext.capabilities.cleanCiliumState` | (see above) | Capabilities for init container |
| `cgroup.autoMount.enabled` | `false` | Talos manages cgroups differently |
| `cgroup.hostRoot` | `/sys/fs/cgroup` | Talos cgroup path |
| `k8sServiceHost` | `localhost` | Talos proxies API server locally |
| `k8sServicePort` | `7445` | Talos API proxy port |

## Advanced: Helm Template + Kustomize Approach

For GitOps or environments requiring manifest control, you can render and patch the manifests:

### 1. Render Helm Chart to File

```bash
helm template cilium cilium/cilium \
  --version 1.18.1 \
  --namespace kube-system \
  --set ipam.mode=kubernetes \
  --set kubeProxyReplacement=true \
  --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
  --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
  --set cgroup.autoMount.enabled=false \
  --set cgroup.hostRoot=/sys/fs/cgroup \
  --set k8sServiceHost=localhost \
  --set k8sServicePort=7445 \
  > cilium-manifests.yaml
```

### 2. Apply Manifests

```bash
kubectl apply -f cilium-manifests.yaml
```

## Enabling Additional Features

### Hubble Observability

Add these parameters to enable Hubble:

```bash
--set hubble.enabled=true \
--set hubble.relay.enabled=true \
--set hubble.ui.enabled=true
```

### BGP Support

For BGP routing:

```bash
--set bgpControlPlane.enabled=true
```

### Gateway API

For Kubernetes Gateway API support:

```bash
--set gatewayAPI.enabled=true
```

## Upgrading Cilium

To upgrade to a new version:

```bash
helm upgrade cilium cilium/cilium \
  --version <NEW_VERSION> \
  --namespace kube-system \
  --reuse-values
```

## Troubleshooting

### Common Issues

1. **Pods stuck in Init:CrashLoopBackOff**
   - Usually indicates missing Talos-specific parameters
   - Check logs: `kubectl logs -n kube-system <pod-name> -c <init-container-name>`

2. **CoreDNS pods not getting IPs**
   - Ensure Cilium DaemonSet is running on all nodes
   - Check CNI configuration: `ls -la /etc/cni/net.d/` on nodes

3. **DNS resolution failing**
   - Verify Cilium operator can pull images
   - Check if kube-proxy is still intercepting traffic

### Useful Commands

```bash
# Check Cilium connectivity
kubectl exec -n kube-system -it $(kubectl get pods -n kube-system -l app.kubernetes.io/name=cilium-agent -o jsonpath='{.items[0].metadata.name}') -- cilium connectivity test

# View Cilium configuration
kubectl get configmap -n kube-system cilium-config -o yaml

# Check for network policies
kubectl get cnp,ccnp -A

# Monitor Cilium events
kubectl exec -n kube-system -it $(kubectl get pods -n kube-system -l app.kubernetes.io/name=cilium-agent -o jsonpath='{.items[0].metadata.name}') -- cilium monitor
```

## Uninstalling Cilium

```bash
# If installed with Helm
helm uninstall cilium -n kube-system

# Clean up remaining resources
kubectl delete crd -l app.kubernetes.io/part-of=cilium
```

## References

- [Cilium Documentation](https://docs.cilium.io/)
- [Talos Linux Documentation](https://www.talos.dev/)
- [Cilium on Talos GitHub Discussions](https://github.com/siderolabs/talos/discussions)

## Notes

- This configuration is tested with Cilium v1.18.1 and Talos v1.5+
- The Talos-specific parameters are critical and cannot be omitted
- Always test in a non-production environment first
- Consider using GitOps for production deployments