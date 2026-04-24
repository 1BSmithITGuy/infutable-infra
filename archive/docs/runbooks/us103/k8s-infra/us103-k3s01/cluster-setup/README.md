# K3s Cluster Deployment (Ubuntu 22.04, Production)

**Purpose**  
Documentation for deploying a production-like K3s cluster on Ubuntu 22.04. These notes are intended for lab use and will evolve into automation.

**Scope**  
- 1× control-plane (master) node  
- 2× worker nodes  
- LVM partitioning with most space allocated to `/` and ~10% left free in the VG.

**Status**  
- Last updated: 2025-08-13  
- Ownership: Bryan Smith (BSmithITGuy@gmail.com)

---

## 1) Master Node

**Name**  
`bsus103km01.ad.infutable.com`

**OS Install**  
- Minimal install  
- Disk (LVM):  
  - `/boot/efi` ≈ 1.049 GB (FAT32)  
  - `/boot` ≈ 2.000 GB (ext4)  
  - `/` (root) ≈ 42.148 GB (ext4 on LVM)  
  - ~10% left unallocated in the LVM volume group  
- Install SSH server

**Tools Install**
```bash
sudo apt update
sudo apt install -y xe-guest-utilities
```

**K3s Master Install (disable agent)**
```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable-agent" sh -
```
> Runs only control‑plane components on the master.

---

## 2) Worker Nodes

**Names**  
- `bsus103kw01.ad.infutable.com`  
- `bsus103kw02.ad.infutable.com`

**OS Install**  
- Minimal install  
- Install SSH server  
- Disk (LVM): same pattern as master  
  - `/boot/efi` ≈ 1.049 GB (FAT32)  
  - `/boot` ≈ 2.000 GB (ext4)  
  - `/` (root) ≈ 42.148 GB (ext4 on LVM)  
  - ~10% left unallocated in the LVM volume group  

**Tools Install**
```bash
sudo apt update
sudo apt install -y xe-guest-utilities
```

**Join Worker to Master**

On the **master**, get the join token:
```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

On **each worker**:
```bash
curl -sfL https://get.k3s.io | K3S_URL="https://10.0.0.202:6443" K3S_TOKEN="<MasterNodeToken>::server:<ServerJoinKey>" sh -
```

---

## 3) DNS & Hostname (DNS servers currently not always running)

(NOTE:  this step is no longer needed - DNS servers are always running)

Run the appropriate command **on each node** and ensure `/etc/hosts` has a loopback entry mapping FQDN → shortname.


**Master**
```bash
sudo hostnamectl set-hostname bsus103km01.ad.infutable.com
# /etc/hosts
127.0.1.1 bsus103km01.ad.infutable.com bsus103km01
```

**Worker 1**
```bash
sudo hostnamectl set-hostname bsus103kw01.ad.infutable.com
# /etc/hosts
127.0.1.1 bsus103kw01.ad.infutable.com bsus103kw01
```

**Worker 2**
```bash
sudo hostnamectl set-hostname bsus103kw02.ad.infutable.com
# /etc/hosts
127.0.1.1 bsus103kw02.ad.infutable.com bsus103kw02
```

---

## 4) Verification

On the master:
```bash
kubectl get nodes
kubectl get pods -A
```

---

## Artifacts

- Disk layout screenshots are in `images/` for quick reference.

## Changelog

- 08-12-2025:  The master node is now the only node running in this cluster, and is hosting applications as well.  DNS servers are also functioning.  
