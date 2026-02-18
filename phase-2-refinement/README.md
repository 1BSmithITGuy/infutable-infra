# Phase 2: Platform Refinement

Author: Bryan Smith  
Created: 2026-02-15  
Last Updated: 2026-02-16  

## Revision History

| Date       | Author | Change Summary                              |
|------------|--------|---------------------------------------------|
| 2026-02-15 | Bryan  | Initial document                            |
| 2026-02-16 | Bryan  | Addeded Current Content                     |


## Purpose

Phase 2 transitions the lab from exploratory experimentation to a production-style Kubernetes platform. The focus is on operational discipline, recoverability, GitOps-driven deployments, and enterprise-aligned tooling.

For phase 1 lab exploration work, see [phase-1-exploration/](../phase-1-exploration/).

Full plan and details to follow as implementation progresses.

## Current Content

| Area | Description |
|------|-------------|
| [Documentation Standards](./docs/standards/documentation.md) | Header format, file naming, runbook structure |
| [Runbook Template](./docs/templates/runbook-template.md) | Ready-to-copy starting point for new runbooks |
| **Site Infrastructure** | |
| [US103 Site Overview](./docs/infra/sites/us103/) | Hardware, VLANs, address plan, network architecture |
| [Hypervisors](./docs/infra/sites/us103/hypervisors/) | XCP-ng and Proxmox hosts, Terraform API setup |
| [Firewall](./docs/infra/sites/us103/firewall/) | OPNsense interfaces, BGP configuration |
| [Switches](./docs/infra/sites/us103/switches/) | VLAN port assignments for both switches |
| [Wireless](./docs/infra/sites/us103/wireless/) | Access point and SSID configuration |
| **Runbooks** | |
| [Jump Station](./docs/runbooks/us103/jump-station/) | Server and workstation setup for bsus103jump02 |
| [Windows Server Template](./docs/runbooks/us103/windows-server-template/) | Sysprepped Server 2022 Datacenter Core template for Proxmox |