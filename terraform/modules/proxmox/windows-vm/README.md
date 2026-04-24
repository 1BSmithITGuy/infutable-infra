# Proxmox Windows VM Module

Author: Bryan Smith  
Created: 2026-03-27  
Last Updated: 2026-04-21  

## Revision History

| Date       | Author | Change Summary      |
| ---------- | ------ | ------------------- |
| 2026-03-27 | Bryan  | Initial document    |
| 2026-04-21 | Bryan  | Bootstrap variables |

## Purpose

Clones a Windows Server VM from a Proxmox template (built by [Packer](../../../../packer/windows-server-2022-core/README.md)) and optionally sets hostname, static IP, and DNS via WinRM so it's ready for Ansible. The template is expected to have WinRM enabled with access restricted to the jump host/controller.

## Usage

Call this child module from a root module with the required variables defined.  Below is an example to deploy a new VM with 3 additional disks:

```hcl
module "new_windows_vm" {
  source = "../../modules/proxmox/windows-vm"

  hostname       = "NEWWINDOWSVM"
  proxmox_node   = "pve"
  template_vm_id = 9000
  vm_id          = 7000

  additional_disks = [
    { size_gb = 15 },
    { size_gb = 10 },
    { size_gb = 10 },
  ]

  network_bridge = "vmbr1"
  vlan_id        = 10

  #  See bootstrap_network section below  
  bootstrap_network = { ... }


}
```

## Variables

| Variable            | Type               | Default                    | Description                                                                                                               |
| ------------------- | ------------------ | -------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `hostname`          | string             | none (required)            | Hostname (also VM name)                                                                                                   |
| `proxmox_node`      | string             | none (required)            | Proxmox host to deploy on (usually the same as hostname; check Proxmox console)                                           |
| `template_vm_id`    | number             | none (required)            | Source template VM ID (see below)                                                                                         |
| `vm_id`             | number             | none (required)            | Proxmox VM ID (0 = auto-assign) (see below)                                                                               |
| `protection`        | bool               | `true`                     | VM protection                                                                                                             |
| `description`       | string             | `"Managed by Terraform"`   | VM description in Proxmox                                                                                                 |
| `tags`              | list(string)       | `["terraform", "windows"]` | Tags                                                                                                                      |
| `cpu_cores`         | number             | `2`                        | CPU cores                                                                                                                 |
| `memory_mb`         | number             | `4096`                     | Memory in MB                                                                                                              |
| `os_disk_size_gb`   | number             | `60`                       | OS disk (C:) size in GB                                                                                                   |
| `additional_disks`  | list(object)       | `[]`                       | Additional disks (see below; requires additional parameter `size_gb`)                                                     |
| `datastore`         | string             | `"local-zfs"`              | Datastore name                                                                                                            |
| `network_bridge`    | string             | `"vmbr0"`                  | Network bridge                                                                                                            |
| `vlan_id`           | number             | `null`                     | VLAN tag                                                                                                                  |
| `start_on_boot`     | bool               | `true`                     | Start when host boots                                                                                                     |
| `bootstrap_network` | object             | `null`                     | Static IP/hostname config applied via WinRM after clone. Null skips bootstrap (see below)                                 |
| `winrm_user`        | string             | `null`                     | WinRM username for bootstrap connection. Required when `bootstrap_network` is set.                                        |
| `winrm_password`    | string (sensitive) | `null`                     | WinRM password for bootstrap connection. Required when `bootstrap_network` is set. Keep in `.tfvars` (gitignored). |

### VM and template IDs

Proxmox assigns a unique VM ID for each VM and template.  
* `vm_id` - the ID of the new VM; specify 0 for auto-assign.
* `template_vm_id` - the ID of the template to clone from.  For this module, currently `9000` is the only template (Server 2022 core).

### additional_disks

List of disks attached after the OS disk.

```
List index 0  -->  scsi1  -->  Disk 1
List index 1  -->  scsi2  -->  Disk 2
List index 2  -->  scsi3  -->  Disk 3
```
* The OS disk is scsi0.
* Drive letters are not assigned here (use Ansible).

> NOTE:  Windows assigns disk numbers based on the SCSI disk number.

Each entry requires `size_gb` which specifies the size of the disk in GB.  

All data disks inherit the module's datastore, format (raw), and disk settings (iothread, discard, ssd).

### bootstrap_network

When `bootstrap_network` is set, the module runs a one-time bootstrap after clone.

> NOTE:  When set, `winrm_user` and `winrm_password` must also be provided. Keep these in `.tfvars` (gitignored)

**Example:**

```hcl
  bootstrap_network = {
    static_ip     = "10.0.1.x"
    prefix_length = 26
    gateway       = "10.0.1.1"
    dns           = "10.0.1.3"
  }
  
  #  Must be variables in .tfvars (gitignored)
  winrm_user = var.winrm_user
  winrm_password = var.winrm_password


```

## Outputs

| Output           | Description                   |
| ---------------- | ----------------------------- |
| `vm_id`          | Proxmox VM ID                 |
| `ipv4_addresses` | All IPs from QEMU guest agent |

## Provider

Requires the [bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs) provider (~> 0.98).

## Notes

- `clone` block is in `ignore_changes` to prevent replacement after creation
- Disk resizing (grow only) can be done by increasing `size_gb` and running `terraform apply`

## References

### Internal
- [Packer template](../../../../packer/windows-server-2022-core/README.md)
- [Ansible documentation](../../../../ansible/README.md)
- [Terraform documentation](../../../README.md)

### External
- [bpg/proxmox Terraform provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)

