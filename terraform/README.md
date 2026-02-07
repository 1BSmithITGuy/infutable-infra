# Terraform — InfUtable Infrastructure

Terraform configurations for provisioning and managing VM infrastructure on Proxmox VE.

---

## Provider

| Component | Details |
|-----------|---------|
| **Provider** | [bpg/terraform-provider-proxmox](https://github.com/bpg/terraform-provider-proxmox) |
| **Hypervisor** | Proxmox VE |
| **IaC tool** | Terraform (HashiCorp) |

---

## Directory Structure

```
terraform/
├── modules/                        # Reusable modules
│   └── proxmox-vm/                 # Generic Proxmox VM provisioning
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── environments/                   # Per-site compositions
│   └── us103/                      # US103 datacenter
│       ├── main.tf                 # VM definitions (calls modules)
│       ├── variables.tf            # Variable declarations
│       ├── terraform.tfvars        # Variable values (gitignored)
│       ├── terraform.tfvars.example# Documented variable template (committed)
│       ├── outputs.tf              # Output values
│       ├── versions.tf             # Terraform and provider version pins
│       └── providers.tf            # Provider configuration
│
└── README.md
```

### Modules

- **`proxmox-vm`** — Creates a Proxmox VM with configurable CPU, memory, disk, network, and cloud-init settings.

### Environments

Define what gets created by calling modules with site-specific values.

- **`us103`** — The primary (Easton, PA) datacenter.

---

## State Management

Terraform state is managed **locally** on the jump station (`bsus103jump02`). State files are excluded from version control via `.gitignore`.

| Item | Approach |
|------|----------|
| **State storage** | Local filesystem on jump station |
| **State locking** | Not required (one administrator) |
| **State backup** | Covered by jump station backup procedures |
| **Remote backend** | Not currently needed; production environments would use a remote backend with state locking |

---

## Secrets

Secrets are stored outside this repository in `/srv/secrets` on the jump station. Secrets never appear in committed code.
***Note:***  Secrets manager will be implemented at a later state.

### Credential variables (TF_VAR_*)

Sensitive values are passed via environment variables using Terraform's `TF_VAR_` convention:

| Variable | Source | Purpose |
|----------|--------|---------|
| `TF_VAR_proxmox_api_token_id` | `/srv/secrets` | Proxmox API token ID |
| `TF_VAR_proxmox_api_token_secret` | `/srv/secrets` | Proxmox API token secret |

### File-based secrets

SSH keys and certificates are referenced by absolute path from `/srv/secrets`:

| Path | Purpose |
|------|---------|
| `/srv/secrets/ssh-keys/automation/terraform/` | Terraform provisioning keys |
| `/srv/secrets/ssh-keys/human/bryan/infra/` | Operator SSH keys |

### Terraform-side protections

- All sensitive variables are declared with `sensitive = true` 
- All sensitive outputs use `sensitive = true`
- The `.gitignore` excludes `*.tfvars` files, which contain actual variable values
- A `terraform.tfvars.example` file is committed to document expected variables without exposing values

---

## Usage

```bash
cd terraform/environments/us103

# First-time setup
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with actual values

# Initialize providers
terraform init

# Review changes
terraform plan

# Apply
terraform apply
```

### Proxmox parallelism note

Creating multiple VMs simultaneously can cause Proxmox lock errors due to I/O bottlenecks. If provisioning multiple VMs, use:

```bash
terraform apply -parallelism=1
```

---

## Version Pinning

Provider and Terraform versions are pinned in `versions.tf`. The `.terraform.lock.hcl` file is committed to ensure consistent provider builds across runs.

---

## Scope and Drift Policy

Terraform manages **VM provisioning only**: creating, sizing, networking, and bootstrapping VMs via cloud-init on Proxmox. Guest OS configuration (Active Directory, DSC, application setup) is handled by other tools outside of Terraform.

All infrastructure changes go through Terraform. Manual changes via the Proxmox UI are reserved for break-glass scenarios only and should be reconciled back into code as soon as possible.
