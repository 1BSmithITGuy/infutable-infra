# InfUtable Infrastructure

**InfUtable** — from **immUTABLE** and **INFrastructure** — is a production-style, end-to-end enterprise environment designed to showcase how infrastructure can be built, operated, and evolved with immutable principles at its core.

This repository contains the Infrastructure-as-Code, automation, and configuration artifacts for running InfUtable’s multi-site Kubernetes platform, integrated with Active Directory, hybrid cloud services, and supporting enterprise systems.

## Overview

InfUtable is a fictional company created to demonstrate:
- **Immutable infrastructure design** — treat servers, clusters, and workloads as replaceable, versioned artifacts rather than pets.
- **Kubernetes platform engineering** — multi-cluster deployments with GitOps (Argo CD) and Rancher.
- **Active Directory integration** — centralized authentication, RBAC, and DNS.
- **Infrastructure automation** — scripted orchestration for VM bring-up/teardown, cluster bootstrapping, and CI checks.
- **Hybrid cloud adoption** — extending workloads and identity into AWS and Azure.
- **Enterprise-grade patterns** — namespaces, RBAC, network policies, monitoring, logging, and backup strategies.

The core of the environment runs in an on-premises corporate HQ datacenter (a homelab) and connects to cloud resources via VPN. It is designed to mirror real-world enterprise setups, making it ideal for development, interviews, demonstrations, and skills assessment.

## Recent Projects

Highlighted work demonstrating infrastructure build-out and operational practices. Each project includes documentation and implementation artifacts.

| Project | Description | Dates | Documentation |
|---------|-------------|-------|---------------|
| Proxmox Server | Deployed Proxmox VE hypervisor with ZFS mirror as foundation for lab infrastructure | 01/21/2026 – 01/22/2026 | [docs/runbooks/us103/base-infra/proxmox/](docs/runbooks/us103/base-infra/proxmox/) |
| Jump Station | Ubuntu jump station with workstation integration, automated backups, and Obsidian sync via Syncthing/Git | 01/24/2026 – 01/26/2026 | [docs/runbooks/us103/jump-station/](docs/runbooks/us103/jump-station/) |
| Base Infra Docs | Documented XCP-ng environment, firewall VM, and VLAN architecture | 01/27/2026 | [docs/runbooks/us103/base-infra/](docs/runbooks/us103/base-infra/) |
| Talos Cluster | Rebuild Talos Linux Kubernetes cluster on Proxmox | 01/28/2026 – | *in progress* |


## Repo Layout

- **platform/** — Cluster-scoped + site-scoped infrastructure (namespaces, RBAC, quotas, network policies).
- **apps/** — Kubernetes applications (each with `base` + `overlays/<site>`).
- **apps-legacy/** — Unrefactored manifests (temporary holding area).
- **orchestration/** — Automation scripts and vars for site bring-up/teardown.
- **docs/** — Diagrams, runbooks, and examples.

