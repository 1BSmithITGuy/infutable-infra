# Runbook: Proxmox API Token for Terraform

Author: Bryan Smith  
Created: 2026-02-17

| Date | Change |
|------|--------|
| 2026-02-17 | Initial creation |

Creates a dedicated Proxmox user and API token with minimum required permissions for Terraform to manage VMs.

## Prerequisites

- Proxmox VE 9.x with root or admin access
- SSH access to the Proxmox host (or use the web shell)

## Relevant Logs

```bash
# Verify token exists (Proxmox host)
pveum user token list terraform@pam
```

## Step 1: Create the Terraform User

```bash
pveum user add terraform@pam --comment "Terraform automation account"
```

## Step 2: Create a Custom Role

```bash
pveum role add TerraformRole --privs "Datastore.Allocate,Datastore.AllocateSpace,Datastore.AllocateTemplate,Datastore.Audit,Pool.Allocate,SDN.Use,Sys.Audit,Sys.Console,Sys.Modify,VM.Allocate,VM.Audit,VM.Clone,VM.Config.CDROM,VM.Config.Cloudinit,VM.Config.CPU,VM.Config.Disk,VM.Config.HWType,VM.Config.Memory,VM.Config.Network,VM.Config.Options,VM.Migrate,VM.PowerMgmt"
```

### Permissions:

| Permission | Why |
|-----------|-----|
| `VM.Allocate` | Create and delete VMs |
| `VM.Clone` | Clone from templates |
| `VM.Config.*` | Modify VM hardware settings |
| `VM.PowerMgmt` | Start/stop/reset VMs |
| `VM.Audit` | Read VM status |
| `Datastore.Allocate*` | Create/resize disks |
| `SDN.Use` | Assign network interfaces |
| `Sys.Audit` / `Sys.Console` / `Sys.Modify` | Node queries, console access |
| `Pool.Allocate` | Manage resource pools |

## Step 3: Assign the Role

Apply the role at the root path (`/`) so Terraform can access all nodes and datastores:

```bash
pveum acl modify / --user terraform@pam --role TerraformRole
```

To scope down later, apply ACLs to specific paths instead of `/` (e.g. `/vms/<vmid>`, `/storage/<storeid>`, `/nodes/<nodename>`).

## Step 4: Create an API Token

```bash
pveum user token add terraform@pam terraform --privsep=0 --comment "Terraform API access"
```

- `--privsep=0` — Token inherits the user's full permissions (no privilege separation).
- The output shows the token value **once**. Copy it immediately.

## Step 5: Configure Terraform

The bpg/proxmox provider expects the token in this format:

```hcl
proxmox_api_token = "terraform@pam!terraform=<token-value>"
```

Store this in `terraform.tfvars` (gitignored).

## Validation

```bash
# From the jump station:
curl -s -k -H 'Authorization: PVEAPIToken=terraform@pam!terraform=<token-value>' \
  https://BSUS103PX01.infra.infutable.com:8006/api2/json/version
```

Expected: JSON with Proxmox version info.

## References

- [Proxmox User Management](https://pve.proxmox.com/wiki/User_Management)
- [Proxmox API Tokens](https://pve.proxmox.com/pve-docs/pveum.1.html)
- [bpg/proxmox Terraform Provider — Authentication](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#authentication)
