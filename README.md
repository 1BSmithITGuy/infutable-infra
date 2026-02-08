# InfUtable Infrastructure

**InfUtable** — from **immUTABLE** and **INFRAstructure** — is a production-style, end-to-end enterprise environment designed to demonstrate how infrastructure can be built, operated, and evolved using immutable and automation-first principles.

This repository serves as a **technical portfolio maintained by Bryan Smith**, showcasing real-world infrastructure design, platform engineering patterns, and automation techniques used in enterprise environments.

A highlighted example of this work can be found in the **[VMware](./VMware)** directory, which contains a production-style PowerCLI inventory engine demonstrating environment-wide API traversal, external data correlation, and automation-ready output.

---

## Overview

InfUtable is a fictional company created to demonstrate:

- **Immutable infrastructure design** — Treating servers, clusters, and workloads as replaceable and avoid vendor lock-in where possible.
- **Kubernetes platform engineering** — Standardize deployments with GitOps (Argo CD).
- **Active Directory integration** — Centralized RBAC and DNS.
- **Infrastructure automation** — Scripted orchestration for VM lifecycle management, cluster bootstrap, and environment control.
- **Enterprise-grade patterns** — RBAC, network policies, monitoring, logging, and backup strategies.

The core of the environment runs in an on-prem datacenter designed to mirror real enterprise constraints and operational models with planned cloud expansion.

---

## Repository Structure

This repository contains Infrastructure-as-Code, automation, and configuration artifacts for running InfUtable’s Kubernetes platform and supporting enterprise systems.

### Documentation quick links

| Area | Description |
|-----|------------|
| **[VMware](./VMware)** | **Archived production-style PowerCLI inventory and automation example** |
| [On-prem Infrastructure](./docs/infra/sites/us103) | Hardware, Network architecture |
| [Kubernetes Standards](./docs/standards/kubernetes.md) | DNS conventions, IngressClass, deployment patterns, storage |
| [Cilium on Talos](./docs/runbooks/us103/k8s-infra/us103-talos01/cilium-talos-runbook.md) | Cilium CNI installation and configuration for Talos Linux |
| [Jump Station\Workstation](./docs/runbooks/us103/jump-station) | jump station\server, engineering workstation, tooling, backups, and workflow |
| [Orchestration Scripts](./orchestration) | Environment startup/shutdown automation and dependency sequencing |

---

## Active and Recent Work

High-level view of recent and ongoing infrastructure projects. 

| Project | Focus | Status | Documentation |
|--------|-------|--------|---------------|
| Proxmox Server | Hypervisor deployment with ZFS-backed storage | Completed | [docs/infra/sites/us103/proxmox/](./docs/infra/sites/us103/proxmox/) |
| Jump Station | Jump station, engineering workstation config | Completed | [docs/runbooks/us103/jump-station/](./docs/runbooks/us103/jump-station/) |
| Repo organization | Documentation cleanup and structure | Completed | — |
| Lab refresh and standardization | Platform and tooling refresh | In progress | — |

