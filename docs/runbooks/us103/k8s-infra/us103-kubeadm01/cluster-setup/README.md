# Kubernetes Cluster Deployment (kubeadm, Ubuntu 22.04)

**Purpose**  
Living runbook for deploying a kubeadm-based Kubernetes cluster on Ubuntu 22.04 images (`Template-Ubuntu_2204_Srv_Base_v4`). These are working notes intended for lab use and future automation.

**Scope**  
- 1× control-plane node, 2× worker nodes
- Config files for each node are tracked alongside this runbook under `node-configs/`

**Status**  
- Last updated: 2025-08-13
- Ownership: Bryan Smith (BSmithITGuy@gmail.com)

---

## 1) Prepare Base Image
All nodes were created from `Template-Ubuntu_2204_Srv_Base_v4` in Xen Orchestra.

---

## 2) OS Prereqs

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```

> Note: `apt-transport-https` may be obsolete on newer releases; safe to skip if unavailable.

---

## 3) Install kubeadm, kubelet, kubectl

Follow upstream docs for the current stable. Example below used v1.33 at the time of these notes.

```bash
# Keyring dir
sudo mkdir -p -m 755 /etc/apt/keyrings

# GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key |   gpg --dearmor | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.gpg >/dev/null

# Repo
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" |   sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

---

## 4) Initialize Control Plane

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

Save the worker join command printed at the end.

---

## 5) kubectl for Non-Root

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

## 6) CNI (Flannel example)

```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

---

## 7) Join Workers

```bash
sudo kubeadm join <control-plane-ip>:6443 --token <token>   --discovery-token-ca-cert-hash sha256:<hash>
```

---

## 8) Verify

```bash
kubectl get nodes
kubectl get pods -A
```

---

## 9) Add-ons (tracked separately)

- Local Path Provisioner (default StorageClass): see `../addons/local-path-provisioner.yaml`
- Ingress (NGINX) setup: see `../ingress/README.md`

---

## Related Node Configs

The node cloud-configs (as captured during this build) are versioned in `node-configs/`:

- `Master node 1/Cloud-Config/`
- `Worker node 1/Cloud-Config/`
- `Worker node 2/Cloud-Config/`

---
