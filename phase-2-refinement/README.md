# Phase 2: Platform Refinement

Author: Bryan Smith  
Created: 2026-02-15  
Last Updated: 2026-02-16  

## Revision History

| Date       | Author | Change Summary                              |
|------------|--------|---------------------------------------------|
| 2026-02-15 | Bryan  | Initial document                            |
| 2026-02-16 | Bryan  | Added Current Content                     |
| 2026-03-12 | Bryan  | Added Packer template and logging standards  |
| 2026-03-26 | Bryan  | Added Ansible, terraform, and DC pipeline docs |


## Purpose

Phase 2 transitions the lab from exploratory experimentation to a production-style Kubernetes platform. The focus is on operational discipline, recoverability, GitOps-driven deployments, and enterprise-aligned tooling.

For phase 1 lab exploration work, see [phase-1-exploration/](../phase-1-exploration/).

Full plan and details to follow as implementation progresses.

## Naming Conventions

This repo models a fictitious multi-site organization called **Infutable** (AD domain:  `ad.infutable.com`).

**Site codes:** `<2-letter-country><3-digit-site>`

| Code | Location |
|------|----------|
| US103 | Easton, PA |

**Server hostname prefixes:**

| Prefix | Meaning | Used for |
|--------|---------|----------|
| `INF` | Infutable | AD Domain joined servers |
| `BS` | Bryan Smith | Non-domain infrastructure (hypervisors, jump stations, etc.) |

**Server role codes:**

| Code | Role |
|------|------|
| DC | Domain Controller |
| CA | Certificate Authority |
| PX | Proxmox host |
| JUMP | Jump station |

**Examples:**
- `INFUS103DC03` -- AD joined server, site US103, Domain Controller #3
- `BSUS103JUMP02` -- US103, Jump Station #2
- `BSUS103PX01` -- US103, Proxmox host #1

Repo directories follow the same site structure where applicable (e.g., `terraform/us103/`, `ansible/inventory/us103/`, `scripts/us103/`).

## Current Content

| Area | Description |
|------|-------------|
| **Pipelines** | |
| [DC Pipeline Runbook](./docs/pipelines/us103/domain-controller.md) | Automated domain controller deployment (Packer, Terraform, Ansible) |
| [Packer - Windows Server 2022 Core](./packer/windows-server-2022-core/) | Automated 2022 template Packer build (Packer) |
| [Terraform](./terraform/) | VM provisioning and network bootstrap |
| [Ansible](./ansible/) | Post-provision configuration |
| [Scripts](./scripts/) | Orchestration scripts |
| **Standards** | |
| [Documentation Standards](./docs/standards/documentation.md) | Header format, file naming, runbook structure |
| [Logging Standards](./docs/standards/logging.md) | Log directory structure, naming, and tool-specific notes |
| [Runbook Template](./docs/templates/runbook-template.md) | Ready-to-copy starting point for new runbooks |
| **Site Infrastructure** | |
| [US103 Site Overview](./docs/infra/sites/us103/) | Hardware, VLANs, address plan, network architecture |
| [Hypervisors](./docs/infra/sites/us103/hypervisors/) | XCP-ng and Proxmox hosts, Terraform API setup |
| [Firewall](./docs/infra/sites/us103/firewall/) | OPNsense interfaces, BGP configuration |
| [Switches](./docs/infra/sites/us103/switches/) | VLAN port assignments for both switches |
| [Wireless](./docs/infra/sites/us103/wireless/) | Access point and SSID configuration |
| **Runbooks** | |
| [Jump Station](./docs/runbooks/us103/jump-station/) | Server and workstation setup for bsus103jump02 |