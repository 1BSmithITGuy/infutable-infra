# Terraform

Author: Bryan Smith  
Created: 2026-04-16  
Last Updated: 2026-04-21  

## Revision History

| Date       | Author | Change Summary              |
|------------|--------|-----------------------------|
| 2026-04-16 | Bryan  | Initial document            |
| 2026-04-20 | Bryan  | Ansible inventory generation, Packer module link        |
| 2026-04-21 | Bryan  | Module section points to module README (canonical)      |

## Purpose

* Provisions VMs from templates.
* Bootstraps with hostname, networking, and storage configuration.
* Generates Ansible inventory files - Terraform is the single source of truth for hosts/servers.

## Directory Structure

```
terraform/
    modules/proxmox/windows-vm/     Reusable VM module (clone, disks, network)
    us103/
        domain-controllers/          Domain controller VMs
```

New deployments get their own directory under `<site-code>/<server-role-description>` (example: `us103/domain-controllers`). Each uses the shared module to create the VM and follows the same pattern: 
* Map variable for per-VM values.
* Shared defaults for common specs.
* `apply.sh` wrapper for logging.

## Module: proxmox/windows-vm

Reusable module that clones a Proxmox Windows template (created from [Packer Template](../packer/windows-server-2022-core/README.md)) and configures CPU, memory, disks, and networking. The module is generic; role-specific configuration (domain join, DC promotion, etc.) is handled by Ansible.

Full variable list, outputs, and bootstrap behavior: [windows-vm module README](modules/proxmox/windows-vm/README.md).

## Ansible Inventory Generation

* Each deployment's `main.tf` includes a `local_file.ansible_inventory` resource that generates an inventory file from a template (`templates/hosts.yml.tftpl`) into `ansible/inventory/<site>/<deployment>.yml`. 
* The static group hierarchy (`ansible/inventory/<site>/groups.yml`) is manually maintained and not touched by Terraform, so any new server roles may need to be added to this file.  

The generated file should not be edited directly.  Changes are overwritten on
the next apply. Edit `terraform.tfvars` (for host data) or the `.tftpl` template
(for structure or comments) instead.



## Misc. Files and Logs

* Each deployment has an `apply.sh` wrapper that logs to `/srv/logs/terraform/us103/<deployment>/`
* On each provisioned server, logs should be placed according to OS (see [Logging standards](../docs/standards/logging.md))

## References

### Internal
- [Packer Template](../packer/windows-server-2022-core/README.md)
- [Logging standards](../docs/standards/logging.md)
- [Filesystem conventions](../docs/standards/filesystem.md)
- [Ansible documentation](../ansible/README.md)

### External
- [bpg/proxmox provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
