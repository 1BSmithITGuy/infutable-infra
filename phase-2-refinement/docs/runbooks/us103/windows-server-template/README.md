# Runbook: Windows Server 2022 Core Template (Proxmox)

Author: Bryan Smith  
Created: 2026-02-17

| Date | Change |
|------|--------|
| 2026-02-17 | Initial creation |

## Purpose

Creates a sysprepped Windows Server 2022 Datacenter Server Core

## Prerequisites

- Proxmox VE 9.x
- Windows Server 2022 ISO
- VirtIO drivers ISO ([from Fedora](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/))


## Step 1: Create the VM

In Proxmox:

| Setting | Value |
|---------|-------|
| VM ID | 9000 |
| Name | `tmpl-ws2022-core` |
| OS Type | Microsoft Windows 11/2022 |
| QEMU Agent | Enabled (checkbox) |
| CPU | 2 cores, type `x86-64-v2-AES` |
| Memory | 2500 MB |
| SCSI Controller | VirtIO SCSI single |
| Disk | 32 GB, SCSI0, discard=on, SSD emulation=on, cache=none |
| Network | VirtIO NIC on `vmbr0` |
| CD-ROM 1 (ide0) | Windows Server 2022 ISO |
| CD-ROM 2 (ide2) | VirtIO drivers ISO |

## Step 2: Install Windows Server 2022 Core

1. Start the VM and and begin installation.
2. When you get to the part to select which disk, Click *Load driver* → Browse → `D:\vioscsi\2k22\amd64` → Install the **Red Hat VirtIO SCSI controller**.
3. Select the disk.

## Step 3: Install VirtIO Drivers

After Windows boots to the Server Core command prompt:

```powershell
pnputil.exe /add-driver E:\vioscsi\2k22\amd64\*.inf /install
pnputil.exe /add-driver E:\NetKVM\2k22\amd64\*.inf /install
pnputil.exe /add-driver E:\Balloon\2k22\amd64\*.inf /install
pnputil.exe /add-driver E:\viostor\2k22\amd64\*.inf /install
pnputil.exe /add-driver E:\vioserial\2k22\amd64\*.inf /install
```

## Step 4: Install QEMU Guest Agent

```powershell
msiexec /i E:\guest-agent\qemu-ga-x86_64.msi
```

## Step 5: Enable WinRM for Remote Management

```powershell
winrm quickconfig -force

winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

Set-Service WinRM -StartupType Automatic
```

> **Note:** Basic auth over HTTP is used here for Terraform provisioner access on a management VLAN. In production, I would use HTTPS with a certificate or Kerberos after domain join. Hardening is out of scope for the template — cloned VMs should be locked down post-deployment.

## Step 6: Run Windows Update

```powershell
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate

Get-WindowsUpdate -Install -AcceptAll -AutoReboot
```

Run until no more updates are available.

## Step 7: Clean Up

```powershell
Stop-Service wuauserv
Remove-Item -Recurse -Force C:\Windows\SoftwareDistribution\Download\*
Start-Service wuauserv
```

## Step 8: Sysprep and Generalize

```powershell
C:\Windows\System32\Sysprep\sysprep.exe /oobe /generalize /shutdown /mode:vm
```

> **Note:** `/mode:vm` skips hardware re-detection on next boot whiich significantly speeds up first boot after cloning.

## Step 9: Convert to Template

In Proxmox UI:  
1. Remove mounded ISOs.
2. Right-click VM and **Convert to Template**.

## References

- [Proxmox VM Templates](https://pve.proxmox.com/wiki/VM_Templates_and_Clones)
- [VirtIO Windows Drivers](https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md)
- [Microsoft Sysprep Reference](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep-command-line-options)
