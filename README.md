# InfUtable Infrastructure

**InfUtable** — from **immUTABLE** and **INFRAstructure** — is a production-style, end-to-end enterprise environment designed to demonstrate how infrastructure can be built, operated, and evolved using immutable and automation-first principles.

This repository serves as a **technical portfolio maintained by Bryan Smith**, showcasing real-world infrastructure design, platform engineering patterns, and automation techniques used in enterprise environments.

A highlighted example of this work can be found in the **[VMware](./VMware)** directory, which contains a production-style PowerCLI inventory engine demonstrating environment-wide API traversal, external data correlation, and automation-ready output.

---

## Overview

InfUtable is a fictional company created to demonstrate:

- **Immutable infrastructure design** — treating servers, clusters, and workloads as replaceable, versioned artifacts rather than pets.
- **Kubernetes platform engineering** — multi-cluster deployments with GitOps (Argo CD) and standardized operational patterns.
- **Active Directory integration** — centralized authentication, RBAC, DNS, and enterprise identity concepts.
- **Infrastructure automation** — scripted orchestration for VM lifecycle management, cluster bootstrap, and environment control.
- **Enterprise-grade patterns** — namespaces, RBAC, network policies, monitoring, logging, and backup strategies.

The core of the environment runs in an on-premises datacenter (a homelab), intentionally designed to mirror real enterprise constraints and operational models rather than idealized cloud-only examples.

---

## Repository Structure

This repository contains Infrastructure-as-Code, automation, and configuration artifacts for running InfUtable’s multi-site Kubernetes platform and supporting enterprise systems.

### Documentation quick links

| Area | Description |
|-----|------------|
| **[VMware](./VMware)** | **Archived production-style PowerCLI inventory and automation example** |
| [Base Infrastructure](./base-infrastructure) | Network architecture, firewalls, switches, VLANs, IP allocation |
| [Kubernetes Standards](./kubernetes-standards) | DNS conventions, IngressClass, deployment patterns, storage |
| [Cilium on Talos](./cilium-on-talos) | Cilium CNI installation and configuration for Talos Linux |
| [Jump Station](./jump-station) | Management workstation, tooling, backups, and operator workflows |
| [Orchestration Scripts](./orchestration) | Environment startup/shutdown automation and dependency sequencing |

---

## Active and Recent Work

High-level view of recent and ongoing infrastructure projects. 

| Project | Focus | Status | Documentation |
|--------|-------|--------|---------------|
| Proxmox Server | Hypervisor deployment with ZFS-backed storage | Completed | docs/infra/sites/us103/proxmox/ |
| Jump Station | Management workstation, backups, tooling | Completed | docs/runbooks/us103/jump-station/ |
| Repo organization | Documentation cleanup and structure | Completed | — |
| Lab refresh and standardization | Platform and tooling refresh | In progress | — |

