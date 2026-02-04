# InfUtable Infrastructure

**InfUtable** — from **immUTABLE** and **INFrastructure** — is a production-style, end-to-end enterprise environment designed to showcase how infrastructure can be built, operated, and evolved with immutable principles at its core.

This repository contains the Infrastructure-as-Code, automation, and configuration artifacts for running InfUtable's multi-site Kubernetes platform, integrated with Active Directory and supporting enterprise systems.

## Overview

InfUtable is a fictional company created to demonstrate:
- **Immutable infrastructure design** — treat servers, clusters, and workloads as replaceable, versioned artifacts rather than pets.
- **Kubernetes platform engineering** — multi-cluster deployments with GitOps (Argo CD).
- **Active Directory integration** — centralized authentication, RBAC, and DNS.
- **Infrastructure automation** — scripted orchestration for VM bring-up/teardown, cluster bootstrapping, and CI checks.
- **Enterprise-grade patterns** — namespaces, RBAC, network policies, monitoring, logging, and backup strategies.

The core of the environment runs in an on-premises datacenter (a homelab). It is designed to mirror real-world enterprise setups, making it ideal for development, demonstrations, and skills assessment.

## Documentation quick links

| Area | Description |
|------|-------------|
| [Base Infrastructure](docs/runbooks/us103/base-infra/) | Network architecture, firewall, switches, VLANs, IP allocations |
| [Kubernetes Standards](docs/standards/kubernetes.md) | DNS conventions, IngressClass, deployment patterns, storage |
| [Cilium on Talos](k8s/platform/clusters/us103-talos01/docs/cilium-talos-readme.md) | Cilium CNI installation guide for Talos Linux |
| [Jump Station](docs/runbooks/us103/jump-station/) | Management workstation, backups, tooling |
| [Proxmox Setup](docs/runbooks/us103/base-infra/proxmox/) | Proxmox VE hypervisor deployment |
| [Orchestration Scripts](orchestration/us103/) | Lab environment startup/shutdown automation |

## Recent Projects

Highlighted work demonstrating infrastructure build-out and operational practices. Each project includes documentation and implementation artifacts.

| Project | Description | Dates | Documentation |
|---------|-------------|-------|---------------|
| Proxmox Server | Deployed Proxmox VE hypervisor with ZFS mirror as foundation for lab infrastructure | 01/21/2026 – 01/22/2026 | [docs/runbooks/us103/base-infra/proxmox/](docs/runbooks/us103/base-infra/proxmox/) |
| Jump Station | Ubuntu jump station with workstation integration, automated backups, and Obsidian sync via Syncthing/Git | 01/24/2026 – 01/26/2026 | [docs/runbooks/us103/jump-station/](docs/runbooks/us103/jump-station/) |
| Base Infra Docs | Documented XCP-ng environment, firewall VM, and VLAN architecture | 01/27/2026 | [docs/runbooks/us103/base-infra/](docs/runbooks/us103/base-infra/) |
| Update docs | Update documentation | 01/28/2026 – | *in progress* |
| Lab refresh | planning stage | 01/28/2026 – | *in progress* |

## Repo Layout

- **k8s/platform/** — Cluster-scoped infrastructure (namespaces, RBAC, networking, ingress, monitoring).
- **k8s/apps/** — Kubernetes applications (each with `base` + `overlays/<cluster>`).
- **orchestration/** — Automation scripts and vars for site bring-up/teardown.
- **docs/** — Standards, runbooks, and operational documentation.

## Roadmap

- **Hybrid cloud extension** — Site-to-site VPN to AWS/Azure with identity federation and workload migration.
- **Centralized secrets management** — HashiCorp Vault integration for Kubernetes secrets.
- **Backup automation** — Velero configuration for cluster state and PV backup/restore.
