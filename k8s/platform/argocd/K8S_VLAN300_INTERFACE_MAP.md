# K8s VLAN300 Interface Mapping

**Date:** 2025-11-09
**Status:** VIFs correctly configured sequentially

---

## VIF to Guest OS Interface Mapping

### Talos Cluster

| VM Name | VIF Devices | Guest OS Interfaces | VLAN300 Interface |
|---------|-------------|---------------------|-------------------|
| bsus103tal-k8m01 | 0, 1 | eth0, eth1 | **eth1** (172.16.1.2) |
| bsus103tal-k8w01 | 0, 1, 2 | eth0, eth1, eth2 | **eth2** (172.16.1.3) |
| bsus103tal-k8w02 | 0, 1, 2 | eth0, eth1, eth2 | **eth2** (172.16.1.4) |

### Kubeadm Cluster

| VM Name | VIF Devices | Guest OS Interfaces | VLAN300 Interface |
|---------|-------------|---------------------|-------------------|
| bsus103k-8m01 | 0, 1 | eth0, eth1 | **eth1** (172.16.1.20) |
| bsus103k-8w01 | 0, 1, 2, 3 | eth0, eth1, eth2, eth3 | **eth3** (172.16.1.21) |
| bsus103k-8w02 | 0, 1, 2, 3 | eth0, eth1, eth2, eth3 | **eth3** (172.16.1.22) |

---

## Complete Network Layout Per VM

### bsus103tal-k8m01 (Talos Master)
- **eth0** (VIF 0): VLAN20 k8s-mgt = 10.0.2.2
- **eth1** (VIF 1): VLAN300 BU = **172.16.1.2** ← Configure this

### bsus103tal-k8w01 (Talos Worker 1)
- **eth0** (VIF 0): VLAN20 k8s-mgt = 10.0.2.3
- **eth1** (VIF 1): VLAN30 k8s-bgp
- **eth2** (VIF 2): VLAN300 BU = **172.16.1.3** ← Configure this

### bsus103tal-k8w02 (Talos Worker 2)
- **eth0** (VIF 0): VLAN20 k8s-mgt = 10.0.2.4
- **eth1** (VIF 1): VLAN30 k8s-bgp
- **eth2** (VIF 2): VLAN300 BU = **172.16.1.4** ← Configure this

### bsus103k-8m01 (Kubeadm Master)
- **eth0** (VIF 0): VLAN20 k8s-mgt = 10.0.2.20
- **eth1** (VIF 1): VLAN300 BU = **172.16.1.20** ← Configure this

### bsus103k-8w01 (Kubeadm Worker 1)
- **eth0** (VIF 0): VLAN20 k8s-mgt = 10.0.2.21
- **eth1** (VIF 1): VLAN30 k8s-bgp
- **eth2** (VIF 2): VLAN200 MGT
- **eth3** (VIF 3): VLAN300 BU = **172.16.1.21** ← Configure this

### bsus103k-8w02 (Kubeadm Worker 2)
- **eth0** (VIF 0): VLAN20 k8s-mgt = 10.0.2.22
- **eth1** (VIF 1): VLAN30 k8s-bgp
- **eth2** (VIF 2): VLAN200 MGT
- **eth3** (VIF 3): VLAN300 BU = **172.16.1.22** ← Configure this

---

## Configuration Commands

### For Talos Nodes

**Master (bsus103tal-k8m01):**
```bash
talosctl -n 10.0.2.2 patch mc --patch '[
  {
    "op": "add",
    "path": "/machine/network/interfaces/-",
    "value": {
      "interface": "eth1",
      "addresses": ["172.16.1.2/24"],
      "mtu": 9000
    }
  }
]'
```

**Worker 1 (bsus103tal-k8w01):**
```bash
talosctl -n 10.0.2.3 patch mc --patch '[
  {
    "op": "add",
    "path": "/machine/network/interfaces/-",
    "value": {
      "interface": "eth2",
      "addresses": ["172.16.1.3/24"],
      "mtu": 9000
    }
  }
]'
```

**Worker 2 (bsus103tal-k8w02):**
```bash
talosctl -n 10.0.2.4 patch mc --patch '[
  {
    "op": "add",
    "path": "/machine/network/interfaces/-",
    "value": {
      "interface": "eth2",
      "addresses": ["172.16.1.4/24"],
      "mtu": 9000
    }
  }
]'
```

### For Kubeadm Nodes

**Master (bsus103k-8m01) - add to netplan or /etc/network/interfaces:**
```yaml
# Interface eth1
auto eth1
iface eth1 inet static
    address 172.16.1.20
    netmask 255.255.255.0
    mtu 9000
```

**Worker 1 (bsus103k-8w01) - eth3:**
```yaml
auto eth3
iface eth3 inet static
    address 172.16.1.21
    netmask 255.255.255.0
    mtu 9000
```

**Worker 2 (bsus103k-8w02) - eth3:**
```yaml
auto eth3
iface eth3 inet static
    address 172.16.1.22
    netmask 255.255.255.0
    mtu 9000
```

---

## Quick Reference

**Masters:** Use **eth1** for VLAN300
**Talos Workers:** Use **eth2** for VLAN300
**Kubeadm Workers:** Use **eth3** for VLAN300

All interfaces should be configured with:
- MTU: **9000**
- Netmask: **255.255.255.0** (/24)
- No gateway needed (same subnet)

---

## Verification

After configuring, from each node:
```bash
# Check interface is up
ip addr show eth1  # or eth2/eth3 depending on VM

# Ping TrueNAS
ping 172.16.1.30

# Test jumbo frames
ping -M do -s 8972 172.16.1.30

# Test NFS mount
mkdir /mnt/test
mount -t nfs 172.16.1.30:/mnt/BSUS103VM02_Disk_Pool_01/Backups/Kubernetes/us103-talos01 /mnt/test
```
