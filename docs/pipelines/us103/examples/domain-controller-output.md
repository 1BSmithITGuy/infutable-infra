# Domain Controller Pipeline Output

Full output from:  
[Domain-Controller-Runbook](../domain-controller.md)

*Notes:* 

* **Expected "fatal" during promotion:** The promotion task triggers a reboot. After reboot, the original local Administrator context is no longer valid, causing the WinRM reconnect to fail. This is expected. A subsequent play validates that promotion completed successfully.
* **dcdiag:** Some warnings or failures are expected immediately after promotion while replication and AD services stabilize. See [dcdiag](../domain-controller.md#dcdiag) in the runbook for details.

```bash
Initializing the backend...
Upgrading modules...
- dc in ../../modules/proxmox/windows-vm
Initializing provider plugins...
- terraform.io/builtin/terraform is built in to Terraform
- Finding bpg/proxmox versions matching "~> 0.98"...
- Finding latest version of hashicorp/local...
- Using previously-installed bpg/proxmox v0.102.0
- Using previously-installed hashicorp/local v2.8.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.ansible_inventory will be created
  + resource "local_file" "ansible_inventory" {
      + content              = <<-EOT
            # Domain Controllers -- site US103
            #
            # Managed by Terraform -- DO NOT EDIT
            # Source of truth: terraform.tfvars (domain_controllers map)

            domain_controllers:
              hosts:
                INFUS103DC03:
                  ansible_host: 10.0.1.4
                INFUS103DC04:
                  ansible_host: 10.0.1.5
        EOT
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0644"
      + filename             = "./../../../ansible/inventory/us103/domain-controllers.yml"
      + id                   = (known after apply)
    }

  # module.dc["dc03"].proxmox_virtual_environment_vm.windows_vm will be created
  + resource "proxmox_virtual_environment_vm" "windows_vm" {
      + acpi                                 = true
      + bios                                 = "seabios"
      + boot_order                           = (known after apply)
      + delete_unreferenced_disks_on_destroy = true
      + description                          = "Domain Controller - ad.infutable.com (Terraform managed)"
      + hotplug                              = (known after apply)
      + id                                   = (known after apply)
      + ipv4_addresses                       = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + keyboard_layout                      = "en-us"
      + mac_addresses                        = (known after apply)
      + migrate                              = false
      + name                                 = "INFUS103DC03"
      + network_device                       = [
          + {
              + bridge      = "vmbr1"
              + enabled     = true
              + firewall    = false
              + mac_address = (known after apply)
              + model       = "virtio"
              + mtu         = 0
              + queues      = 0
              + rate_limit  = 0
              + vlan_id     = 10
            },
        ]
      + network_interface_names              = (known after apply)
      + node_name                            = "BSUS103PX01"
      + on_boot                              = true
      + protection                           = false
      + purge_on_destroy                     = true
      + reboot                               = false
      + reboot_after_update                  = true
      + scsi_hardware                        = "virtio-scsi-single"
      + started                              = true
      + stop_on_destroy                      = false
      + tablet_device                        = true
      + tags                                 = [
          + "terraform",
          + "windows",
          + "domain-controller",
          + "us103",
          + "adds",
        ]
      + template                             = false
      + timeout_clone                        = 1200
      + timeout_create                       = 1800
      + timeout_migrate                      = 1800
      + timeout_move_disk                    = 1800
      + timeout_reboot                       = 1800
      + timeout_shutdown_vm                  = 1800
      + timeout_start_vm                     = 1800
      + timeout_stop_vm                      = 300
      + vm_id                                = 111

      + agent {
          + enabled = true
          + timeout = "15m"
          + trim    = false
          + type    = "virtio"
        }

      + clone {
          + full    = true
          + retries = 1
          + vm_id   = 9000
        }

      + cpu {
          + cores      = 2
          + hotplugged = 0
          + limit      = 0
          + numa       = false
          + sockets    = 1
          + type       = "x86-64-v2-AES"
          + units      = (known after apply)
        }

      + disk {
          + aio               = "io_uring"
          + backup            = true
          + cache             = "none"
          + datastore_id      = "local-zfs"
          + discard           = "on"
          + file_format       = "raw"
          + interface         = "scsi0"
          + iothread          = true
          + path_in_datastore = (known after apply)
          + replicate         = true
          + size              = 60
          + ssd               = true
        }
      + disk {
          + aio               = "io_uring"
          + backup            = true
          + cache             = "none"
          + datastore_id      = "local-zfs"
          + discard           = "on"
          + file_format       = "raw"
          + interface         = "scsi1"
          + iothread          = true
          + path_in_datastore = (known after apply)
          + replicate         = true
          + size              = 15
          + ssd               = true
        }
      + disk {
          + aio               = "io_uring"
          + backup            = true
          + cache             = "none"
          + datastore_id      = "local-zfs"
          + discard           = "on"
          + file_format       = "raw"
          + interface         = "scsi2"
          + iothread          = true
          + path_in_datastore = (known after apply)
          + replicate         = true
          + size              = 10
          + ssd               = true
        }
      + disk {
          + aio               = "io_uring"
          + backup            = true
          + cache             = "none"
          + datastore_id      = "local-zfs"
          + discard           = "on"
          + file_format       = "raw"
          + interface         = "scsi3"
          + iothread          = true
          + path_in_datastore = (known after apply)
          + replicate         = true
          + size              = 10
          + ssd               = true
        }

      + memory {
          + dedicated      = 2048
          + floating       = 0
          + keep_hugepages = false
          + shared         = 0
        }

      + operating_system {
          + type = "win11"
        }

      + vga (known after apply)
    }

  # module.dc["dc03"].terraform_data.bootstrap[0] will be created
  + resource "terraform_data" "bootstrap" {
      + id = (known after apply)
    }

Plan: 3 to add, 0 to change, 0 to destroy.
╷
│ Warning: Resource targeting is in effect
│
│ You are creating a plan with the -target option, which means that the
│ result of this plan may not represent all of the changes requested by the
│ current configuration.
│
│ The -target option is not for routine use, and is provided only for
│ exceptional situations such as recovering from errors or mistakes, or when
│ Terraform specifically suggests to use it as part of an error message.
╵

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

local_file.ansible_inventory: Creating...
local_file.ansible_inventory: Creation complete after 0s [id=9bab1d0d8ac0e3c89754c62ed5e329cc6bc4f86e]
module.dc["dc03"].proxmox_virtual_environment_vm.windows_vm: Creating...
module.dc["dc03"].proxmox_virtual_environment_vm.windows_vm: Still creating... [00m10s elapsed]
module.dc["dc03"].proxmox_virtual_environment_vm.windows_vm: Still creating... [00m20s elapsed]
module.dc["dc03"].proxmox_virtual_environment_vm.windows_vm: Still creating... [00m30s elapsed]
module.dc["dc03"].proxmox_virtual_environment_vm.windows_vm: Still creating... [00m40s elapsed]
module.dc["dc03"].proxmox_virtual_environment_vm.windows_vm: Still creating... [00m50s elapsed]
module.dc["dc03"].proxmox_virtual_environment_vm.windows_vm: Still creating... [01m00s elapsed]
module.dc["dc03"].proxmox_virtual_environment_vm.windows_vm: Still creating... [01m10s elapsed]
module.dc["dc03"].proxmox_virtual_environment_vm.windows_vm: Still creating... [01m20s elapsed]
module.dc["dc03"].proxmox_virtual_environment_vm.windows_vm: Still creating... [01m30s elapsed]
module.dc["dc03"].proxmox_virtual_environment_vm.windows_vm: Creation complete after 1m37s [id=111]
module.dc["dc03"].terraform_data.bootstrap[0]: Creating...
module.dc["dc03"].terraform_data.bootstrap[0]: Provisioning with 'remote-exec'...
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): Connecting to remote host via WinRM...
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   Host: 10.0.1.25
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   Port: 5985
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   User: Administrator
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   Password: true
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   HTTPS: false
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   Insecure: true
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   NTLM: false
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   CACert: false
module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [00m10s elapsed]
module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [00m20s elapsed]
module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [00m30s elapsed]
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): Connected!
module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [00m40s elapsed]
module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [00m50s elapsed]
#< CLIXML
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04"><Obj S="progress" RefId="0"><TN RefId="0"><T>System.Management.Automation.PSCustomObject</T><T>System.Object</T></TN><MS><I64 N="SourceId">1</I64><PR N="Record"><AV>Preparing modules for first use.</AV><AI>0</AI><Nil /><PI>-1</PI><PC>-1</PC><T>Completed</T><SR>-1</SR><SD> </SD></PR></MS></Obj></Objs>module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [01m00s elapsed]
#< CLIXML
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04"><Obj S="progress" RefId="0"><TN RefId="0"><T>System.Management.Automation.PSCustomObject</T><T>System.Object</T></TN><MS><I64 N="SourceId">1</I64><PR N="Record"><AV>Preparing modules for first use.</AV><AI>0</AI><Nil /><PI>-1</PI><PC>-1</PC><T>Completed</T><SR>-1</SR><SD> </SD></PR></MS></Obj></Objs>module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [01m10s elapsed]

module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): C:\Users\Administrator>powershell.exe -NoProfile -Command New-Item -Path 'C:\ProgramData\Infutable\bootstrap\terraform' -ItemType Directory -Force
module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [01m20s elapsed]


module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):     Directory: C:\ProgramData\Infutable\bootstrap


module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): Mode                 LastWriteTime         Length Name
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): ----                 -------------         ------ ----
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): d-----         4/17/2026  11:39 PM                terraform


module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [01m30s elapsed]
#< CLIXML
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04"><Obj S="progress" RefId="0"><TN RefId="0"><T>System.Management.Automation.PSCustomObject</T><T>System.Object</T></TN><MS><I64 N="SourceId">1</I64><PR N="Record"><AV>Preparing modules for first use.</AV><AI>0</AI><Nil /><PI>-1</PI><PC>-1</PC><T>Completed</T><SR>-1</SR><SD> </SD></PR></MS></Obj><Obj S="progress" RefId="1"><TNRef RefId="0" /><MS><I64 N="SourceId">1</I64><PR N="Record"><AV>Preparing modules for first use.</AV><AI>0</AI><Nil /><PI>-1</PI><PC>-1</PC><T>Completed</T><SR>-1</SR><SD> </SD></PR></MS></Obj></Objs>#< CLIXML
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04"><Obj S="progress" RefId="0"><TN RefId="0"><T>System.Management.Automation.PSCustomObject</T><T>System.Object</T></TN><MS><I64 N="SourceId">1</I64><PR N="Record"><AV>Preparing modules for first use.</AV><AI>0</AI><Nil /><PI>-1</PI><PC>-1</PC><T>Completed</T><SR>-1</SR><SD> </SD></PR></MS></Obj></Objs>module.dc["dc03"].terraform_data.bootstrap[0]: Provisioning with 'file'...
module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [01m40s elapsed]
module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [01m50s elapsed]
#< CLIXML
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04"><Obj S="progress" RefId="0"><TN RefId="0"><T>System.Management.Automation.PSCustomObject</T><T>System.Object</T></TN><MS><I64 N="SourceId">1</I64><PR N="Record"><AV>Preparing modules for first use.</AV><AI>0</AI><Nil /><PI>-1</PI><PC>-1</PC><T>Completed</T><SR>-1</SR><SD> </SD></PR></MS></Obj></Objs>module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [02m00s elapsed]
#< CLIXML
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04"><Obj S="progress" RefId="0"><TN RefId="0"><T>System.Management.Automation.PSCustomObject</T><T>System.Object</T></TN><MS><I64 N="SourceId">1</I64><PR N="Record"><AV>Preparing modules for first use.</AV><AI>0</AI><Nil /><PI>-1</PI><PC>-1</PC><T>Completed</T><SR>-1</SR><SD> </SD></PR></MS></Obj></Objs>module.dc["dc03"].terraform_data.bootstrap[0]: Provisioning with 'remote-exec'...
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): Connecting to remote host via WinRM...
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   Host: 10.0.1.25
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   Port: 5985
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   User: Administrator
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   Password: true
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   HTTPS: false
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   Insecure: true
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   NTLM: false
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec):   CACert: false
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): Connected!
module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [02m10s elapsed]
#< CLIXML
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04"><Obj S="progress" RefId="0"><TN RefId="0"><T>System.Management.Automation.PSCustomObject</T><T>System.Object</T></TN><MS><I64 N="SourceId">1</I64><PR N="Record"><AV>Preparing modules for first use.</AV><AI>0</AI><Nil /><PI>-1</PI><PC>-1</PC><T>Completed</T><SR>-1</SR><SD> </SD></PR></MS></Obj></Objs>module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [02m20s elapsed]
#< CLIXML
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04"><Obj S="progress" RefId="0"><TN RefId="0"><T>System.Management.Automation.PSCustomObject</T><T>System.Object</T></TN><MS><I64 N="SourceId">1</I64><PR N="Record"><AV>Preparing modules for first use.</AV><AI>0</AI><Nil /><PI>-1</PI><PC>-1</PC><T>Completed</T><SR>-1</SR><SD> </SD></PR></MS></Obj></Objs>module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [02m30s elapsed]

module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): C:\Users\Administrator>powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\ProgramData\Infutable\bootstrap\terraform\bootstrap-network.ps1 -IPAddress 10.0.1.4 -PrefixLength 26 -Gateway 10.0.1.1 -DNS 10.0.1.3 -Hostname INFUS103DC03
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): Setting DNS to 10.0.1.3
module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [02m40s elapsed]
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): Force time sync
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): Sending resync command to local computer
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): The command completed successfully.
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): Renaming to INFUS103DC03
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): WARNING: The changes will take effect after you restart the computer WIN-CT90O02TAQ5.
module.dc["dc03"].terraform_data.bootstrap[0] (remote-exec): VM will reboot in 15 seconds with Static IP (10.0.1.4/26, gw 10.0.1.1) scheduled via task.
module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [02m50s elapsed]
#< CLIXML
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04"><Obj S="progress" RefId="0"><TN RefId="0"><T>System.Management.Automation.PSCustomObject</T><T>System.Object</T></TN><MS><I64 N="SourceId">1</I64><PR N="Record"><AV>Preparing modules for first use.</AV><AI>0</AI><Nil /><PI>-1</PI><PC>-1</PC><T>Completed</T><SR>-1</SR><SD> </SD></PR></MS></Obj><Obj S="progress" RefId="1"><TNRef RefId="0" /><MS><I64 N="SourceId">1</I64><PR N="Record"><AV>Preparing modules for first use.</AV><AI>0</AI><Nil /><PI>-1</PI><PC>-1</PC><T>Completed</T><SR>-1</SR><SD> </SD></PR></MS></Obj></Objs>module.dc["dc03"].terraform_data.bootstrap[0]: Still creating... [03m00s elapsed]
#< CLIXML
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04"><Obj S="progress" RefId="0"><TN RefId="0"><T>System.Management.Automation.PSCustomObject</T><T>System.Object</T></TN><MS><I64 N="SourceId">1</I64><PR N="Record"><AV>Preparing modules for first use.</AV><AI>0</AI><Nil /><PI>-1</PI><PC>-1</PC><T>Completed</T><SR>-1</SR><SD> </SD></PR></MS></Obj></Objs>module.dc["dc03"].terraform_data.bootstrap[0]: Creation complete after 3m1s [id=afe40f1c-2db7-7353-f901-21d3471b7b3a]
╷
│ Warning: Applied changes may be incomplete
│
│ The plan was created with the -target option in effect, so some changes
│ requested in the configuration may have been ignored and the output values
│ may not be fully updated. Run the following command to verify that no other
│ changes are pending:
│     terraform plan
│
│ Note that the -target option is not suitable for routine use, and is
│ provided only for exceptional situations such as recovering from errors or
│ mistakes, or when Terraform specifically suggests to use it as part of an
│ error message.
╵

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
=============================================================================
!!!-WARNING-!!!
PUTTING IN THE TEMPLATE PASSWORD WILL PROMOTE INFUS103DC03 TO A DOMAIN CONTROLLER
=============================================================================
SSH password:

PLAY [Deploy DC: initialize disk and promote] **********************************

TASK [Ensure only one host is targeted] ****************************************
ok: [INFUS103DC03] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [Add new computer account to AD] ******************************************
changed: [INFUS103DC03 -> 10.0.1.3]

TASK [Initialize disks] ********************************************************

TASK [initialize-disk : Initialize disk 1 as GPT] ******************************
changed: [INFUS103DC03]

TASK [initialize-disk : Create partition on disk 1] ****************************
changed: [INFUS103DC03]

TASK [initialize-disk : Format D: as NTFS] *************************************
changed: [INFUS103DC03]

TASK [initialize-disk : Create directories on D:] ******************************
changed: [INFUS103DC03] => (item=D:\NTDS)

TASK [initialize-disk : Initialize disk 2 as GPT] ******************************
changed: [INFUS103DC03]

TASK [initialize-disk : Create partition on disk 2] ****************************
changed: [INFUS103DC03]

TASK [initialize-disk : Format E: as NTFS] *************************************
changed: [INFUS103DC03]

TASK [initialize-disk : Create directories on E:] ******************************
changed: [INFUS103DC03] => (item=E:\NTDS_Logs)

TASK [initialize-disk : Initialize disk 3 as GPT] ******************************
changed: [INFUS103DC03]

TASK [initialize-disk : Create partition on disk 3] ****************************
changed: [INFUS103DC03]

TASK [initialize-disk : Format F: as NTFS] *************************************
changed: [INFUS103DC03]

TASK [initialize-disk : Create directories on F:] ******************************
changed: [INFUS103DC03] => (item=F:\SYSVOL)

TASK [Promote to domain controller] ********************************************

TASK [dc-promotion : Install AD DS feature] ************************************
changed: [INFUS103DC03]

TASK [dc-promotion : Promote to domain controller] *****************************
fatal: [INFUS103DC03]: FAILED! => {"changed": true, "module_result": {"_do_action_reboot": false, "changed": true, "reboot_required": true}, "msg": "Failed to reboot after module returned reboot_required, see reboot_result and module_result for more details", "reboot_result": {"changed": true, "elapsed": 612, "exception": "Traceback (most recent call last):\n  File \"/usr/lib/python3/dist-packages/ansible_collections/microsoft/ad/plugins/plugin_utils/_reboot.py\", line 561, in _wrap_conn_err\n    func(*args, **kwargs)\n  File \"/usr/lib/python3/dist-packages/ansible/plugins/connection/winrm.py\", line 636, in reset\n    self._connect()\n  File \"/usr/lib/python3/dist-packages/ansible/plugins/connection/winrm.py\", line 627, in _connect\n    self.protocol = self._winrm_connect()\n                    ^^^^^^^^^^^^^^^^^^^^^\n  File \"/usr/lib/python3/dist-packages/ansible/plugins/connection/winrm.py\", line 495, in _winrm_connect\n    raise AnsibleConnectionFailure(', '.join(map(to_native, errors)))\nansible.errors.AnsibleConnectionFailure: ntlm: the specified credentials were rejected by the server\n\nDuring handling of the above exception, another exception occurred:\n\nTraceback (most recent call last):\n  File \"/usr/lib/python3/dist-packages/ansible_collections/microsoft/ad/plugins/plugin_utils/_reboot.py\", line 367, in _do_until_success_or_timeout\n    return _do_until_success_or_condition(\n           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  File \"/usr/lib/python3/dist-packages/ansible_collections/microsoft/ad/plugins/plugin_utils/_reboot.py\", line 445, in _do_until_success_or_condition\n    raise last_error\n  File \"/usr/lib/python3/dist-packages/ansible_collections/microsoft/ad/plugins/plugin_utils/_reboot.py\", line 403, in _do_until_success_or_condition\n    _reset_connection(task_action, connection, host_context)\n  File \"/usr/lib/python3/dist-packages/ansible_collections/microsoft/ad/plugins/plugin_utils/_reboot.py\", line 589, in _reset_connection\n    _wrap_conn_err(connection.reset)\n  File \"/usr/lib/python3/dist-packages/ansible_collections/microsoft/ad/plugins/plugin_utils/_reboot.py\", line 567, in _wrap_conn_err\n    raise AnsibleError(e)\nansible.errors.AnsibleError: ntlm: the specified credentials were rejected by the server\n\nDuring handling of the above exception, another exception occurred:\n\nTraceback (most recent call last):\n  File \"/usr/lib/python3/dist-packages/ansible_collections/microsoft/ad/plugins/plugin_utils/_reboot.py\", line 270, in reboot_host\n    _do_until_success_or_timeout(\n  File \"/usr/lib/python3/dist-packages/ansible_collections/microsoft/ad/plugins/plugin_utils/_reboot.py\", line 378, in _do_until_success_or_timeout\n    raise Exception(\nException: Timed out waiting for post-reboot test command (timeout=600)\n", "failed": true, "msg": "Timed out waiting for post-reboot test command (timeout=600)", "rebooted": true, "unreachable": false}}
...ignoring

PLAY [Deploy DC: post-promotion setup] *****************************************

TASK [Ensure only one host is targeted] ****************************************
ok: [INFUS103DC03] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [Wait for reboot and AD services to start] ********************************
ok: [INFUS103DC03]

TASK [Gather facts] ************************************************************
ok: [INFUS103DC03]

TASK [Verify DC promotion succeeded] *******************************************
ok: [INFUS103DC03] => {
    "attempts": 1,
    "changed": false,
    "msg": "INFUS103DC03 is a Backup domain controller in ad.InfUtable.com"
}

TASK [Set DNS (replace own IP with loopback)] **********************************
changed: [INFUS103DC03]

TASK [Wait for AD services to run] *********************************************
changed: [INFUS103DC03]

TASK [Enable Remote Event Log Management firewall rules] ***********************
changed: [INFUS103DC03]

TASK [Force AD replication sync] ***********************************************
changed: [INFUS103DC03]

TASK [Run dcdiag] **************************************************************
changed: [INFUS103DC03]

TASK [Show dcdiag output] ******************************************************
ok: [INFUS103DC03] => {
    "dcdiag_result.output": [
        "\r\nDirectory Server Diagnosis\r\n\r\n\r\nPerforming initial setup:\r\n\r\n   Trying to find home server...\r\n\r\n   Home Server = INFUS103DC03\r\n\r\n   * Identified AD Forest. \r\n   Done gathering initial info.\r\n\r\n\r\nDoing initial required tests\r\n\r\n   \r\n   Testing server: US103\\INFUS103DC03\r\n\r\n      Starting test: Connectivity\r\n\r\n         ......................... INFUS103DC03 passed test Connectivity\r\n\r\n\r\n\r\nDoing primary tests\r\n\r\n   \r\n   Testing server: US103\\INFUS103DC03\r\n\r\n      Starting test: Advertising\r\n\r\n         ......................... INFUS103DC03 passed test Advertising\r\n\r\n      Starting test: FrsEvent\r\n\r\n         ......................... INFUS103DC03 passed test FrsEvent\r\n\r\n      Starting test: DFSREvent\r\n\r\n         There are warning or error events within the last 24 hours after the\r\n\r\n         SYSVOL has been shared.  Failing SYSVOL replication problems may cause\r\n\r\n         Group Policy problems. \r\n         ......................... INFUS103DC03 failed test DFSREvent\r\n\r\n      Starting test: SysVolCheck\r\n\r\n         ......................... INFUS103DC03 passed test SysVolCheck\r\n\r\n      Starting test: KccEvent\r\n\r\n         A warning event occurred.  EventID: 0x00000283\r\n\r\n            Time Generated: 04/18/2026   00:11:56\r\n\r\n            Event String:\r\n\r\n            NTDS (636,D,50) NTDSA:  Out of date NLS sort version detected on the database 'D:\\NTDS\\ntds.dit' for Locale 'en-US', index sort version: (SortId=00000001-57ee-1e5c-00b4-d0000bb1e11e, Version=0006020F0006020F), current sort version: (SortId=00000001-57ee-1e5c-00b4-d0000bb1e11e, Version=0006040300060403).\r\n\r\n         A warning event occurred.  EventID: 0x00000266\r\n\r\n            Time Generated: 04/18/2026   00:11:56\r\n\r\n            Event String:\r\n\r\n            NTDS (636,D,50) NTDSA: Database 'D:\\NTDS\\ntds.dit': The secondary index 'INDEX_00000003' of table 'datatable' is out of date with sorting libraries. If used in this state (i.e. not rebuilt), it may appear corrupt or get further corrupted. If there is no later event showing the index being rebuilt, then please defragment the database to rebuild the index.\r\n\r\n         A warning event occurred.  EventID: 0x00000283\r\n\r\n            Time Generated: 04/18/2026   00:11:57\r\n\r\n            Event String:\r\n\r\n            NTDS (636,D,50) NTDSA:  Out of date NLS sort version detected on the database 'D:\\NTDS\\ntds.dit' for Locale 'en-US', index sort version: (SortId=00000001-57ee-1e5c-00b4-d0000bb1e11e, Version=0006020F0006020F), current sort version: (SortId=00000001-57ee-1e5c-00b4-d0000bb1e11e, Version=0006040300060403).\r\n\r\n         A warning event occurred.  EventID: 0x800005B7\r\n\r\n            Time Generated: 04/18/2026   00:11:57\r\n\r\n            Event String:\r\n\r\n            Active Directory Domain Services has detected and deleted some possibly corrupted indices as part of initialization. \r\n\r\n\r\n         A warning event occurred.  EventID: 0x80000BEB\r\n\r\n            Time Generated: 04/18/2026   00:12:28\r\n\r\n            Event String:\r\n\r\n            The directory has been configured to not enforce per-attribute authorization during LDAP add operations. Warning events will be logged, but no requests will be blocked. \r\n\r\n\r\n         A warning event occurred.  EventID: 0x80000BEE\r\n\r\n            Time Generated: 04/18/2026   00:12:28\r\n\r\n            Event String:\r\n\r\n            The directory has been configured to allow implicit owner privileges when initially setting or modifying the nTSecurityDescriptor attribute during LDAP add and modify operations. Warning events will be logged, but no requests will be blocked. \r\n\r\n\r\n         A warning event occurred.  EventID: 0x80000B46\r\n\r\n            Time Generated: 04/18/2026   00:12:38\r\n\r\n            Event String:\r\n\r\n            The security of this directory server can be significantly enhanced by configuring the server to reject SASL (Negotiate, Kerberos, NTLM, or Digest) LDAP binds that do not request signing (integrity verification) and LDAP simple binds that are performed on a clear text (non-SSL/TLS-encrypted) connection.  Even if no clients are using such binds, configuring the server to reject them will improve the security of this server. \r\n\r\n\r\n         A warning event occurred.  EventID: 0x80000BE1\r\n\r\n            Time Generated: 04/18/2026   00:12:38\r\n\r\n            Event String:\r\n\r\n            The security of this directory server can be significantly enhanced by configuring the server to enforce  validation of Channel Binding Tokens received in LDAP bind requests sent over LDAPS connections. Even if  no clients are issuing LDAP bind requests over LDAPS, configuring the server to validate Channel Binding  Tokens will improve the security of this server. \r\n\r\n\r\n         A warning event occurred.  EventID: 0x8000043B\r\n\r\n            Time Generated: 04/18/2026   00:13:11\r\n\r\n            Event String:\r\n\r\n            Active Directory Domain Services could not update the following object with changes received from the directory service at the following network address because Active Directory Domain Services was busy processing information. \r\n\r\n\r\n         A warning event occurred.  EventID: 0x8000059B\r\n\r\n            Time Generated: 04/18/2026   00:17:39\r\n\r\n            Event String:\r\n\r\n            The Knowledge Consistency Checker (KCC) encountered an unexpected error while performing an Active Directory Domain Services operation. \r\n\r\n\r\n         An error event occurred.  EventID: 0xC000046B\r\n\r\n            Time Generated: 04/18/2026   00:17:39\r\n\r\n            Event String:\r\n\r\n            The Knowledge Consistency Checker (KCC) encountered an error while adding a Connection object from the following source directory service to the following destination directory service. \r\n\r\n\r\n         A warning event occurred.  EventID: 0x8000059B\r\n\r\n            Time Generated: 04/18/2026   00:17:39\r\n\r\n            Event String:\r\n\r\n            The Knowledge Consistency Checker (KCC) encountered an unexpected error while performing an Active Directory Domain Services operation. \r\n\r\n\r\n         An error event occurred.  EventID: 0xC000046B\r\n\r\n            Time Generated: 04/18/2026   00:17:39\r\n\r\n            Event String:\r\n\r\n            The Knowledge Consistency Checker (KCC) encountered an error while adding a Connection object from the following source directory service to the following destination directory service. \r\n\r\n\r\n         A warning event occurred.  EventID: 0x8000059B\r\n\r\n            Time Generated: 04/18/2026   00:17:39\r\n\r\n            Event String:\r\n\r\n            The Knowledge Consistency Checker (KCC) encountered an unexpected error while performing an Active Directory Domain Services operation. \r\n\r\n\r\n         An error event occurred.  EventID: 0xC000046B\r\n\r\n            Time Generated: 04/18/2026   00:17:39\r\n\r\n            Event String:\r\n\r\n            The Knowledge Consistency Checker (KCC) encountered an error while adding a Connection object from the following source directory service to the following destination directory service. \r\n\r\n\r\n         A warning event occurred.  EventID: 0x8000059B\r\n\r\n            Time Generated: 04/18/2026   00:17:39\r\n\r\n            Event String:\r\n\r\n            The Knowledge Consistency Checker (KCC) encountered an unexpected error while performing an Active Directory Domain Services operation. \r\n\r\n\r\n         An error event occurred.  EventID: 0xC000046B\r\n\r\n            Time Generated: 04/18/2026   00:17:39\r\n\r\n            Event String:\r\n\r\n            The Knowledge Consistency Checker (KCC) encountered an error while adding a Connection object from the following source directory service to the following destination directory service. \r\n\r\n\r\n         ......................... INFUS103DC03 failed test KccEvent\r\n\r\n      Starting test: KnowsOfRoleHolders\r\n\r\n         [INFUS103DC02] DsBindWithSpnEx() failed with error 5,\r\n\r\n         Access is denied..\r\n         Warning: INFUS103DC02 is the Schema Owner, but is not responding to DS\r\n\r\n         RPC Bind.\r\n\r\n         Warning: INFUS103DC02 is the Domain Owner, but is not responding to DS\r\n\r\n         RPC Bind.\r\n\r\n         Warning: INFUS103DC02 is the PDC Owner, but is not responding to DS\r\n\r\n         RPC Bind.\r\n\r\n         Warning: INFUS103DC02 is the Rid Owner, but is not responding to DS\r\n\r\n         RPC Bind.\r\n\r\n         Warning: INFUS103DC02 is the Infrastructure Update Owner, but is not\r\n\r\n         responding to DS RPC Bind.\r\n\r\n         ......................... INFUS103DC03 failed test KnowsOfRoleHolders\r\n\r\n      Starting test: MachineAccount\r\n\r\n         ......................... INFUS103DC03 passed test MachineAccount\r\n\r\n      Starting test: NCSecDesc\r\n\r\n         ......................... INFUS103DC03 passed test NCSecDesc\r\n\r\n      Starting test: NetLogons\r\n\r\n         ......................... INFUS103DC03 passed test NetLogons\r\n\r\n      Starting test: ObjectsReplicated\r\n\r\n         ......................... INFUS103DC03 passed test ObjectsReplicated\r\n\r\n      Starting test: Replications\r\n\r\n         ......................... INFUS103DC03 failed test Replications\r\n\r\n      Starting test: RidManager\r\n\r\n         ......................... INFUS103DC03 failed test RidManager\r\n\r\n      Starting test: Services\r\n\r\n         ......................... INFUS103DC03 passed test Services\r\n\r\n      Starting test: SystemLog\r\n\r\n         A warning event occurred.  EventID: 0x00000034\r\n\r\n            Time Generated: 04/17/2026   23:38:01\r\n\r\n            Event String:\r\n\r\n            The time service has set the time with offset 32400 seconds.\r\n\r\n         An error event occurred.  EventID: 0x00000709\r\n\r\n            Time Generated: 04/17/2026   23:38:03\r\n\r\n            Event String:\r\n\r\n            Updated Secure Boot certificates are available on this device but have not yet been applied to the firmware. Review the published guidance to complete the update and maintain full protection. This device signature information is included here.\r\n\r\n\r\n         A warning event occurred.  EventID: 0x0000000F\r\n\r\n            Time Generated: 04/17/2026   23:41:02\r\n\r\n            Event String:\r\n\r\n            Credential Guard and/or VBS Key Isolation are configured but the secure kernel is not running; continuing without them.\r\n\r\n         A warning event occurred.  EventID: 0x00000086\r\n\r\n            Time Generated: 04/17/2026   23:41:03\r\n\r\n            Event String:\r\n\r\n            NtpClient was unable to set a manual peer to use as a time source because of DNS resolution error on 'time.windows.com,0x8'. NtpClient will try again in 15 minutes and double the reattempt interval thereafter. The error was: No such host is known. (0x80072AF9)\r\n\r\n         A warning event occurred.  EventID: 0x00000086\r\n\r\n            Time Generated: 04/17/2026   23:41:04\r\n\r\n            Event String:\r\n\r\n            NtpClient was unable to set a manual peer to use as a time source because of DNS resolution error on 'time.windows.com,0x8'. NtpClient will try again in 15 minutes and double the reattempt interval thereafter. The error was: No such host is known. (0x80072AF9)\r\n\r\n         An error event occurred.  EventID: 0x00000709\r\n\r\n            Time Generated: 04/17/2026   23:46:03\r\n\r\n            Event String:\r\n\r\n            Updated Secure Boot certificates are available on this device but have not yet been applied to the firmware. Review the published guidance to complete the update and maintain full protection. This device signature information is included here.\r\n\r\n\r\n         A warning event occurred.  EventID: 0x80040022\r\n\r\n            Time Generated: 04/18/2026   00:11:56\r\n\r\n            Event String:\r\n\r\n            The driver disabled the write cache on device \\Device\\Harddisk1\\DR1.\r\n\r\n         A warning event occurred.  EventID: 0x80040022\r\n\r\n            Time Generated: 04/18/2026   00:11:56\r\n\r\n            Event String:\r\n\r\n            The driver disabled the write cache on device \\Device\\Harddisk2\\DR2.\r\n\r\n         A warning event occurred.  EventID: 0x00001796\r\n\r\n            Time Generated: 04/18/2026   00:12:08\r\n\r\n            Event String:\r\n\r\n            Microsoft Windows Server has detected that NTLM authentication is presently being used between clients and this server. This event occurs once per boot of the server on the first time a client uses NTLM with this server.\r\n\r\n\r\n         An error event occurred.  EventID: 0x00001659\r\n\r\n            Time Generated: 04/18/2026   00:12:08\r\n\r\n            Event String:\r\n\r\n            The session setup to the Windows Domain Controller \\\\INFUS103DC02.ad.InfUtable.com for the domain AD failed because the Domain Controller did not have an account INFUS103DC03$ needed to set up the session by this computer INFUS103DC03.  \r\n\r\n\r\n         A warning event occurred.  EventID: 0x000727A5\r\n\r\n            Time Generated: 04/18/2026   00:12:18\r\n\r\n            Event String:\r\n\r\n            The WinRM service is not listening for WS-Management requests. \r\n\r\n\r\n         A warning event occurred.  EventID: 0x0000000F\r\n\r\n            Time Generated: 04/18/2026   00:12:27\r\n\r\n            Event String:\r\n\r\n            Credential Guard and/or VBS Key Isolation are configured but the secure kernel is not running; continuing without them.\r\n\r\n         A warning event occurred.  EventID: 0x000003F6\r\n\r\n            Time Generated: 04/18/2026   00:12:29\r\n\r\n            Event String:\r\n\r\n            Name resolution for the name _ldap._tcp.dc._msdcs.ad.InfUtable.com. timed out after none of the configured DNS servers responded.\r\n\r\n         An error event occurred.  EventID: 0x0000410B\r\n\r\n            Time Generated: 04/18/2026   00:13:11\r\n\r\n            Event String:\r\n\r\n            The request for a new account-identifier pool failed. The operation will be retried until the request succeeds. The error is \r\n\r\n\r\n         A warning event occurred.  EventID: 0x0000A00A\r\n\r\n            Time Generated: 04/18/2026   00:13:11\r\n\r\n            Event String:\r\n\r\n            The Security System has detected a downgrade attempt when contacting the 3-part SPN \r\n\r\n\r\n         A warning event occurred.  EventID: 0x0000A00A\r\n\r\n            Time Generated: 04/18/2026   00:13:11\r\n\r\n            Event String:\r\n\r\n            The Security System has detected a downgrade attempt when contacting the 3-part SPN \r\n\r\n\r\n         An error event occurred.  EventID: 0x000003EE\r\n\r\n            Time Generated: 04/18/2026   00:13:11\r\n\r\n            Event String:\r\n\r\n            The processing of Group Policy failed. Windows could not authenticate to the Active Directory service on a domain controller. (LDAP Bind function call failed). Look in the details tab for error code and description.\r\n\r\n         An error event occurred.  EventID: 0x00000709\r\n\r\n            Time Generated: 04/18/2026   00:17:29\r\n\r\n            Event String:\r\n\r\n            Updated Secure Boot certificates are available on this device but have not yet been applied to the firmware. Review the published guidance to complete the update and maintain full protection. This device signature information is included here.\r\n\r\n\r\n         A warning event occurred.  EventID: 0x00001796\r\n\r\n            Time Generated: 04/18/2026   00:25:20\r\n\r\n            Event String:\r\n\r\n            Microsoft Windows Server has detected that NTLM authentication is presently being used between clients and this server. This event occurs once per boot of the server on the first time a client uses NTLM with this server.\r\n\r\n\r\n         ......................... INFUS103DC03 failed test SystemLog\r\n\r\n      Starting test: VerifyReferences\r\n\r\n         ......................... INFUS103DC03 passed test VerifyReferences\r\n\r\n   \r\n   \r\n   Running partition tests on : DomainDnsZones\r\n\r\n      Starting test: CheckSDRefDom\r\n\r\n         ......................... DomainDnsZones passed test CheckSDRefDom\r\n\r\n      Starting test: CrossRefValidation\r\n\r\n         ......................... DomainDnsZones passed test\r\n\r\n         CrossRefValidation\r\n\r\n   \r\n   Running partition tests on : ForestDnsZones\r\n\r\n      Starting test: CheckSDRefDom\r\n\r\n         ......................... ForestDnsZones passed test CheckSDRefDom\r\n\r\n      Starting test: CrossRefValidation\r\n\r\n         ......................... ForestDnsZones passed test\r\n\r\n         CrossRefValidation\r\n\r\n   \r\n   Running partition tests on : Schema\r\n\r\n      Starting test: CheckSDRefDom\r\n\r\n         ......................... Schema passed test CheckSDRefDom\r\n\r\n      Starting test: CrossRefValidation\r\n\r\n         ......................... Schema passed test CrossRefValidation\r\n\r\n   \r\n   Running partition tests on : Configuration\r\n\r\n      Starting test: CheckSDRefDom\r\n\r\n         ......................... Configuration passed test CheckSDRefDom\r\n\r\n      Starting test: CrossRefValidation\r\n\r\n         ......................... Configuration passed test CrossRefValidation\r\n\r\n   \r\n   Running partition tests on : ad\r\n\r\n      Starting test: CheckSDRefDom\r\n\r\n         ......................... ad passed test CheckSDRefDom\r\n\r\n      Starting test: CrossRefValidation\r\n\r\n         ......................... ad passed test CrossRefValidation\r\n\r\n   \r\n   Running enterprise tests on : ad.InfUtable.com\r\n\r\n      Starting test: LocatorCheck\r\n\r\n         ......................... ad.InfUtable.com passed test LocatorCheck\r\n\r\n      Starting test: Intersite\r\n\r\n         ......................... ad.InfUtable.com passed test Intersite\r\n\r\n"
    ]
}

PLAY RECAP *********************************************************************
INFUS103DC03               : ok=26   changed=20   unreachable=0    failed=0    skipped=0    rescued=0    ignored=1

```


