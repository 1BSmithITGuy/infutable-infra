# InfUtable-Infra

Maintained by: Bryan Smith  

Multi-site infrastructure automation system that builds server templates, provisions VMs, and deploys fully configured services using Terraform, Ansible, and Packer.  

**Quick demo:** 
* [Active Directory Domain Controller pipeline](./docs/pipelines/us103/domain-controller.md) - End-to-end Active Directory domain controller deployment from ISO to `dcdiag` validated DC.

## About

This repository is a working portfolio and lab to showcase IT and platform engineering (IaC, Kubernetes). It is organized around a company named "InfUtable" (from imm**UTABLE**+**INF**rastructure), a fictitious multi-site enterprise used to exercise realistic naming conventions, directory structure, and scale-out patterns. One site (US103) is active today; the repo layout is designed to add more without refactoring, and the code is modular where possible.

## Design Goals

- Platform-agnostic automation to reduce vendor lock-in
- Reproducible infrastructure using immutable patterns where possible
- Simplified disaster recovery and lifecycle management through automation

> This approach is influenced by real-world constraints such as vendor lock-in (post-Broadcom VMware changes) and the need to make infrastructure lifecycle operations repeatable and low-risk.

## Repository Layout

| Directory                    | Purpose                                                                          |
| ---------------------------- | -------------------------------------------------------------------------------- |
| [`ansible/`](./ansible/)     | Post provision configuration (domain controller roles, domain join, disk init)   |
| [`docs/`](./docs/)           | Pipelines, site infrastructure, runbooks, standards, templates                   |
| [`packer/`](./packer/)       | VM template builds                                                               |
| [`scripts/`](./scripts/)     | Site-level deploy wrappers                                                       |
| [`terraform/`](./terraform/) | Proxmox VM provisioning and reusable module library                              |
| [`VMware/`](./VMware/)       | PowerCLI inventory engine from my prior lab                                      |
| [`archive/`](./archive/)     | Earlier lab exploration (k3s, kubeadm, Talos, Cilium, ArgoCD) kept for reference |

## Documentation

[Domain Controller pipeline runbook](./docs/pipelines/us103/domain-controller.md) - end-to-end DC deployment, with diagram, example output, and recovery notes.

Standards apply to all current work:

- [Documentation standards](./docs/standards/documentation.md) - metadata headers, ISO 8601 dates, kebab-case filenames, runbook structure
- [Logging standards](./docs/standards/logging.md) - directory layout and naming for tooling files/logs
- [Filesystem standards](./docs/standards/filesystem.md) - on-disk layout for tooling files/logs
- [Runbook template](./docs/templates/runbook-template.md) - starting point for new runbooks
- [US103 site overview](./docs/infra/sites/us103/) - hardware, VLANs, firewall, switches, wireless, hypervisors

## Naming and Multi-Site Design

Hostnames and directory structure follow a consistent scheme so additional sites drop in without refactoring.

**Site codes:** `<2-letter-country><3-digit-site>` (example: `US103` -- Easton, PA)

**Server hostname prefixes:**

| Prefix | Meaning | Used for |
|--------|---------|----------|
| `INF` | Infutable | Domain-joined servers |
| `BS`  | Bryan Smith | Non-domain infrastructure (hypervisors, jump stations, etc.) |

**Server role codes:** `DC` (Domain Controller), `CA` (Certificate Authority), `PX` (Proxmox host), `JUMP` (Jump station).

**Examples:** `INFUS103DC03`, `BSUS103JUMP02`, `BSUS103PX01`

Site-scoped directories mirror the convention (`terraform/us103/`, `ansible/inventory/us103/`, `scripts/us103/`, `docs/infra/sites/us103/`). Site-agnostic content (Ansible roles, Terraform modules, standards) lives above the site layer.

## Validation/CI

Pre-commit hooks run locally and on pull request through GitHub Actions:

- `terraform_fmt` and `terraform_validate`
- `yamllint`
- `packer fmt`

Versions pinned in [`.pre-commit-config.yaml`](./.pre-commit-config.yaml); workflow in [`.github/workflows/validate.yml`](./.github/workflows/validate.yml).

## VMware Tooling

[`VMware/`](./VMware/) contains a PowerCLI engine from my previous lab. 
* It uses direct API access (`Get-View`) to cycle through the entire environment and take inventory, but the engine can be easily adapted to modify configuration.  
* It has external data correlation for warranty, site, and lifecycle tracking. 

Not maintained here, kept as a reference.