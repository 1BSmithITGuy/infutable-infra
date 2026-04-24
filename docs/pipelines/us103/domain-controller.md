# Domain Controller Deployment Pipeline

Author: Bryan Smith  
Created: 2026-04-13    

## Revision History

| Date       | Author | Change Summary              |
|------------|--------|-----------------------------|
| 2026-04-13 | Bryan  | Initial document            |
| 2026-04-21 | Bryan  | updated purpose             |
---

## Purpose

End-to-end IaC pipeline that takes a Windows Server 2022 ISO, creates a Server 2022 template, and produces fully promoted, replicating Active Directory domain controller(s) (structured for multiple sites).

1. [Packer](../../../packer/windows-server-2022-core/README.md) builds and configures the Windows 2022 core template from an iso image.  
    * Installs Windows Updates, VirtIO drivers, and QEMU guest agent
    * WinRM hardened with firewall rules restricted to the jump host
2. [Terraform](../../../terraform/README.md) creates and bootstraps the new VM using 2 modules: 
    * **Root module** ([domain-controllers](../../../terraform/us103/domain-controllers)) - calls child module that creates a Windows Server VM and generates an Ansible inventory file ([domain-controllers.yml](../../../ansible/inventory/us103/domain-controllers.yml)).
    * **Child module** ([windows-vm](../../../terraform/modules/proxmox/windows-vm/README.md)) - Generic module that creates Windows VMs from Packer templates.
3. [Ansible](../../../ansible/README.md) performs the rest of the configuration:
    * **Playbook**: [deploy-dc.yml](../../../ansible/playbooks/windows/deploy-dc.yml)
    * **2 Ansible Roles**: [initialize-disk](../../../ansible/roles/initialize-disk), [dc-promotion](../../../ansible/roles/dc-promotion)

>This can be adapted to any platform: Proxmox (ISO), VMware (ISO), AWS (AMI), Azure (Image), etc.

### **NOTES** 
---
- ***This is a lab exercise and not a real environment:***
    - Domain controllers are stateful core services and should not be heavily automated. In most cases, **they should not be automated at all.**
    - Domain admin credentials should never be used in an automation pipeline. For this lab, they are passed via CLI and stored in gitignored .tfvars; production would use HashiCorp Vault, Ansible Vault, or CI/CD secret injection.

- Powershell and bash are also used in this pipeline.
- Pipelines are currently orchestrated via local bash wrappers executed from the jump host. In production, this would be handled by a CI/CD platform to provide centralized execution, approvals, and auditability.
---

## Pipeline Diagram

```
Prerequisite: Build VM template

  Microsoft Server 2022 ISO
          |
          v
   Packer Build (build.sh)
          |
          |-- Install VirtIO drivers + QEMU guest agent
          |-- Bootstrap Windows Update (CU from build-tools ISO)
          |-- Install remaining updates
          |-- Configure WinRM for Ansible
          |-- Secure WinRM via Windows firewall
          |-- Cleanup and Sysprep
          |
          v
   VM Template 


Deploy DC: ./deploy-dc.sh <dc-name>

  Step 1: Terraform (apply.sh)
          |
          |-- Clone VM from template
          |-- Create 3 disks for NTDS DB, logs, and SYSVOL
          |-- Boot with DHCP, connect via WinRM
          |-- Set hostname, DNS, static IP
          |-- Generate Ansible inventory
          |-- Reboot
          v
  Step 2: Ansible (deploy-dc.sh)
          |
          |-- Play 1 (local admin):
          |     |-- Add new computer account to AD
          |     |-- Initialize disks (D:, E:, F:)
          |     |-- Create directories for NTDS, logs, and SYSVOL
          |     |-- Install ADDS and promote to DC
          |     |-- Reboot (ignore failure from old credentials)
          |
          |-- Play 2 (domain admin):
          |     |-- Wait for AD services
          |     |-- Verify DC promotion succeeded 
          |     |-- Set DNS (replace own IP with loopback)
          |     |-- Enable firewall rules for remote management
          |     |-- Force AD replication sync
          |     |-- Run dcdiag
          |
          v
   Domain Controller
```

## Example Output

**Full pipeline run:**  [Domain Controller Pipeline Output](./examples/domain-controller-output.md)

## Relevant Logs

| Tool | Log path |
|------|----------|
| Packer | `/srv/logs/packer/windows-server-2022-core/` |
| Terraform | `/srv/logs/terraform/us103/domain-controllers/` |
| Ansible | `/srv/logs/ansible/us103/<hostname>/` |

## Prerequisites

- Existing DCs are online and healthy
- `microsoft.ad` and `community.windows` Ansible collections installed
- New DC entry in [terraform.tfvars](../../../terraform/us103/domain-controllers/terraform.tfvars.example)

## Step 1: Packer - Build VM Template (if needed)

The template only needs to be rebuilt when the base image is outdated (after Patch Tuesday, driver updates, etc.).


```bash
cd packer/windows-server-2022-core
./build.sh -force
```

> See [Packer template README](../../../packer/windows-server-2022-core/README.md) for details.

## Step 2: Terraform/Ansible - Deploy Domain Controller

Each DC is deployed individually. 

Under `scripts/us103` run: 

```bash
./deploy-dc.sh dc<DC-Number> \
  -e domain_admin_user='AD\Administrator' \
  -e domain_admin_password='<domain-admin-password>' \
  -e dsrm_password='<dsrm-password>'
```

For `<DC-Number>`, use the 2 digit number of the DC. For example:  
* For INFUS103DC05, run `./deploy-dc.sh dc05`.
  
  > See [Naming Conventions](../../../README.md#naming-and-multi-site-design) for hostname and site code format.


## Validation

After deployment, verify from the new DC:

```powershell
Get-ADDomainController -Filter * | Format-Table Name, IPv4Address, IsGlobalCatalog
repadmin /replsummary
dcdiag /a
```

### Dcdiag

Immediately after promotion, several dcdiag tests will fail; these are transient and clear on their own:

| Test | Why it fails | Clears after |
|------|-------------|-------------|
| DFSREvent | SYSVOL replication events still populating | ~24 hours |
| KccEvent | KCC building replication topology | ~15 minutes |
| KnowsOfRoleHolders | FSMO holder not yet reachable from new DC | ~15 minutes |
| Replications | Replication partnerships still forming | ~15 minutes |
| RidManager | RID pool not yet allocated | ~15 minutes |
| SystemLog | Boot-time warnings (time sync, DNS resolution during startup) | ~24 hours |

The pipeline excludes these tests from causing a failure. Functional tests (Connectivity, Advertising, Services, MachineAccount, NetLogons) must pass.

## Design Decisions

**Sequential DC deployment:** Each DC is deployed one at a time; replication needs to be complete before the next one joins. 

**Pre-stage AD computer account prior to joining to AD and force replication:**    The domain_controller Ansible module can create the computer account, but then a DC locator lookup immediately follows. If the locator returns a different DC that hasn't replicated the account yet, promotion fails (error 53 / Access denied). Pre-staging the account and forcing replication to all DCs eliminates this race condition.

**Manual password entry:** Passwords are entered at the CLI. For a domain controller pipeline, a human checkpoint is the right tradeoff; though this could be easily and securely automated using a secrets manager.

**Two play Ansible structure:** Play 1 runs with local admin credentials since it is not on the domain; play 2 switches to domain credentials. 

**Expected "fatal" during promotion:** The promotion task triggers a reboot. After reboot, the original local Admin credentials are no longer valid which causes WinRM reconnect to fail; this is expected, and a subsequent play validates that promotion completed successfully.

**Terraform map variable:** All DCs are defined in a single map variable so the specs can be defined in one place. Each run uses `-target` to deploy a specific DC.

**Cleanup:** All automation tools use `C:\ProgramData\Infutable\bootstrap\<tool>\` on the VM for temp files, and scheduled tasks use the `Infutable-` prefix; all are cleaned up after the task is complete. 

## Architecture

```
scripts/us103/
    deploy-dc.sh                Orchestrator (calls Terraform then Ansible)

terraform/us103/domain-controllers/
    main.tf                     VM specs
    variables.tf                Variables
    terraform.tfvars            Per-DC values (hostname, IP, VM ID)
    apply.sh                    Terraform wrapper with logging

terraform/modules/proxmox/windows-vm/
    main.tf                     Reusable VM module (clone, disks, network)

ansible/
    playbooks/windows/
        deploy-dc.yml           DC promotion playbook
    roles/
        initialize-disk/        Partition, format, create directories on new disks
        dc-promotion/           Install ADDS, promote to DC
    inventory/us103/
        domain-controllers.yml              DC hostnames and IPs (terraform generated)
        group_vars/all.yml                  DNS servers
        group_vars/domain_controllers.yml   AD specific variables
        group_vars/windows.yml              WinRM connection settings
```

## References

### Internal
- [Packer template README](../../../packer/windows-server-2022-core/README.md)
- [Terraform README](../../../terraform/README.md)
- [Ansible README](../../../ansible/README.md)
- [Logging standards](../../standards/logging.md)
- [Filesystem conventions](../../standards/filesystem.md)

### External
- [microsoft.ad.domain_controller module](https://galaxy.ansible.com/ui/repo/published/microsoft/ad/content/module/domain_controller/)
- [community.windows.win_firewall_rule module](https://galaxy.ansible.com/ui/repo/published/community/windows/content/module/win_firewall_rule/)
- [bpg/proxmox Terraform provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
