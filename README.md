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

## Repo Layout

- **platform/** — Cluster-scoped + site-scoped infrastructure (namespaces, RBAC, quotas, network policies).
- **apps/** — Kubernetes applications (each with `base` + `overlays/<site>`).
- **apps-legacy/** — Unrefactored manifests (temporary holding area).
- **orchestration/** — Automation scripts and vars for site bring-up/teardown.
- **ops/** — Jumpstation configs, kubeconfigs (sanitized), shell profiles.
- **docs/** — Diagrams, runbooks, and examples.

