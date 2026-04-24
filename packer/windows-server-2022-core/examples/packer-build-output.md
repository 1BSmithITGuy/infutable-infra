Example output from a successful Packer build:

```bash
┌─[bryan@bsus103jump02:{us103-k3s01}]─[/srv/repos/infutable-infra/packer/windows-server-2022-core]
└──╼ $packer build -force -var-file="windows-server-2022-core.pkrvars.hcl" .
proxmox-iso.windows-server-2022-core: output will be in this color.

==> proxmox-iso.windows-server-2022-core: Force set, checking for existing artifact on PVE cluster
==> proxmox-iso.windows-server-2022-core: found existing VM template with ID 9000 on PVE node BSUS103PX01, deleting it
==> proxmox-iso.windows-server-2022-core: Successfully deleted VM template 9000
==> proxmox-iso.windows-server-2022-core: Creating VM
==> proxmox-iso.windows-server-2022-core: Starting VM
==> proxmox-iso.windows-server-2022-core: Waiting 5s for boot
==> proxmox-iso.windows-server-2022-core: Typing the boot command
==> proxmox-iso.windows-server-2022-core: Using WinRM communicator to connect: 10.0.1.190
==> proxmox-iso.windows-server-2022-core: Waiting for WinRM to become available...
==> proxmox-iso.windows-server-2022-core: WinRM connected.
==> proxmox-iso.windows-server-2022-core: Connected to WinRM!
==> proxmox-iso.windows-server-2022-core: Provisioning with Powershell...
==> proxmox-iso.windows-server-2022-core: Provisioning with powershell script: ./scripts/install-virtio-ga.ps1
==> proxmox-iso.windows-server-2022-core: Installing Balloon driver...
==> proxmox-iso.windows-server-2022-core: Microsoft PnP Utility
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core: Adding driver package:  balloon.inf
==> proxmox-iso.windows-server-2022-core: Driver package added successfully.
==> proxmox-iso.windows-server-2022-core: Published Name:         oem2.inf
==> proxmox-iso.windows-server-2022-core: Driver package installed on device: PCI\VEN_1AF4&DEV_1002&SUBSYS_00051AF4&REV_00\3&267a616a&0&18
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core: Total driver packages:  1
==> proxmox-iso.windows-server-2022-core: Added driver packages:  1
==> proxmox-iso.windows-server-2022-core: Installing vioserial driver...
==> proxmox-iso.windows-server-2022-core: Microsoft PnP Utility
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core: Adding driver package:  vioser.inf
==> proxmox-iso.windows-server-2022-core: Driver package added successfully.
==> proxmox-iso.windows-server-2022-core: Published Name:         oem3.inf
==> proxmox-iso.windows-server-2022-core: Driver package installed on device: PCI\VEN_1AF4&DEV_1003&SUBSYS_00031AF4&REV_00\3&267a616a&0&40
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core: Total driver packages:  1
==> proxmox-iso.windows-server-2022-core: Added driver packages:  1
==> proxmox-iso.windows-server-2022-core: Installing viostor driver...
==> proxmox-iso.windows-server-2022-core: Microsoft PnP Utility
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core: Adding driver package:  viostor.inf
==> proxmox-iso.windows-server-2022-core: Driver package added successfully.
==> proxmox-iso.windows-server-2022-core: Published Name:         oem4.inf
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core: Total driver packages:  1
==> proxmox-iso.windows-server-2022-core: Added driver packages:  1
==> proxmox-iso.windows-server-2022-core: Installing QEMU Guest Agent
==> proxmox-iso.windows-server-2022-core: QEMU Guest Agent is running.
==> proxmox-iso.windows-server-2022-core: Provisioning with Powershell...
==> proxmox-iso.windows-server-2022-core: Provisioning with powershell script: ./scripts/bootstrap-ssu.ps1
==> proxmox-iso.windows-server-2022-core: Copied MSU to C:\Windows\Temp\KB5082314.msu
==> proxmox-iso.windows-server-2022-core: Installing KB5082314
==> proxmox-iso.windows-server-2022-core:   Still installing (60 seconds elapsed)
==> proxmox-iso.windows-server-2022-core:   Still installing (120 seconds elapsed)
==> proxmox-iso.windows-server-2022-core:   Still installing (180 seconds elapsed)
==> proxmox-iso.windows-server-2022-core:   Still installing (240 seconds elapsed)
==> proxmox-iso.windows-server-2022-core:   Still installing (300 seconds elapsed)
==> proxmox-iso.windows-server-2022-core:   Still installing (360 seconds elapsed)
==> proxmox-iso.windows-server-2022-core:   Still installing (420 seconds elapsed)
==> proxmox-iso.windows-server-2022-core:   Still installing (480 seconds elapsed)
==> proxmox-iso.windows-server-2022-core:   Still installing (540 seconds elapsed)
==> proxmox-iso.windows-server-2022-core: KB5082314 installed successfully (reboot required).
==> proxmox-iso.windows-server-2022-core: Restarting Machine
==> proxmox-iso.windows-server-2022-core: Waiting for machine to restart...
==> proxmox-iso.windows-server-2022-core: A system shutdown is in progress.(1115)
==> proxmox-iso.windows-server-2022-core: A system shutdown is in progress.(1115)
==> proxmox-iso.windows-server-2022-core: WINDOWS-MQTIP23 restarted.
==> proxmox-iso.windows-server-2022-core: Machine successfully restarted, moving on
==> proxmox-iso.windows-server-2022-core: Uploading the Windows update elevated script...
==> proxmox-iso.windows-server-2022-core: Uploading the Windows update check for reboot required elevated script...
==> proxmox-iso.windows-server-2022-core: Uploading the Windows update script...
==> proxmox-iso.windows-server-2022-core: Running Windows update...
==> proxmox-iso.windows-server-2022-core: Waiting for the Windows Modules Installer to exit...
==> proxmox-iso.windows-server-2022-core: Restarting the machine...
==> proxmox-iso.windows-server-2022-core: Waiting for machine to become available...
==> proxmox-iso.windows-server-2022-core: Checking for pending restart...
==> proxmox-iso.windows-server-2022-core: WINDOWS-MQTIP23 restarted.
==> proxmox-iso.windows-server-2022-core: Restart complete
==> proxmox-iso.windows-server-2022-core: Running Windows update...
==> proxmox-iso.windows-server-2022-core: Searching for Windows updates...
==> proxmox-iso.windows-server-2022-core: Skipped (filter) Windows update (2022-02-15; 46.6 MB): 2022-02 Cumulative Update Preview for .NET Framework 3.5 and 4.8 for Microsoft server operating system version 21H2 for x64 (KB5010475)
==> proxmox-iso.windows-server-2022-core: Found Windows update (2025-10-14; 72.45 MB): 2025-10 Cumulative Update for .NET Framework 3.5, 4.8 and 4.8.1 for Microsoft server operating system version 21H2 for x64 (KB5066743)
==> proxmox-iso.windows-server-2022-core: Found Windows update (2026-02-10; 18.51 MB): Update for Microsoft Defender Antivirus antimalware platform - KB4052623 (Version 4.18.26010.5) - Current Channel (Broad)
==> proxmox-iso.windows-server-2022-core: Downloading Windows updates (2 updates; 90.97 MB)...
==> proxmox-iso.windows-server-2022-core: Installing Windows updates...
==> proxmox-iso.windows-server-2022-core: Waiting for operation to complete (system performance: 56% cpu; 37% memory)...
==> proxmox-iso.windows-server-2022-core: Windows update installation completed. Checking for more updates after a reboot...
==> proxmox-iso.windows-server-2022-core: Waiting for the Windows Modules Installer to exit...
==> proxmox-iso.windows-server-2022-core: Waiting for operation to complete (system performance: 1% cpu; 29% memory)...
==> proxmox-iso.windows-server-2022-core: Restarting the machine...
==> proxmox-iso.windows-server-2022-core: Waiting for machine to become available...
==> proxmox-iso.windows-server-2022-core: Checking for pending restart...
==> proxmox-iso.windows-server-2022-core: Waiting for the Windows Modules Installer to exit...
==> proxmox-iso.windows-server-2022-core: Restart is still pending...
==> proxmox-iso.windows-server-2022-core: Restarting the machine...
==> proxmox-iso.windows-server-2022-core: Waiting for machine to become available...
==> proxmox-iso.windows-server-2022-core: A system shutdown is in progress.(1115)
==> proxmox-iso.windows-server-2022-core: Checking for pending restart...
==> proxmox-iso.windows-server-2022-core: WINDOWS-MQTIP23 restarted.
==> proxmox-iso.windows-server-2022-core: Restart complete
==> proxmox-iso.windows-server-2022-core: Running Windows update...
==> proxmox-iso.windows-server-2022-core: Searching for Windows updates...
==> proxmox-iso.windows-server-2022-core: No Windows updates found
==> proxmox-iso.windows-server-2022-core: Provisioning with Powershell...
==> proxmox-iso.windows-server-2022-core: Provisioning with powershell script: ./scripts/configure-ansible.ps1
==> proxmox-iso.windows-server-2022-core: Downloading ConfigureRemotingForAnsible.ps1
==> proxmox-iso.windows-server-2022-core: Running Ansible WinRM configuration
==> proxmox-iso.windows-server-2022-core: VERBOSE: Verifying WinRM service.
==> proxmox-iso.windows-server-2022-core: VERBOSE: PS Remoting is already enabled.
==> proxmox-iso.windows-server-2022-core: Self-signed SSL certificate generated; thumbprint: 13C8C531798ADE9D2D8524C4970FB0C326BFEAF9
==> proxmox-iso.windows-server-2022-core: VERBOSE: Enabling SSL listener.
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core: wxf                 : http://schemas.xmlsoap.org/ws/2004/09/transfer
==> proxmox-iso.windows-server-2022-core: a                   : http://schemas.xmlsoap.org/ws/2004/08/addressing
==> proxmox-iso.windows-server-2022-core: w                   : http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd
==> proxmox-iso.windows-server-2022-core: lang                : en-US
==> proxmox-iso.windows-server-2022-core: Address             : http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous
==> proxmox-iso.windows-server-2022-core: ReferenceParameters : ReferenceParameters
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core: VERBOSE: Basic auth is already enabled.
==> proxmox-iso.windows-server-2022-core: VERBOSE: Enabling CredSSP auth support.
==> proxmox-iso.windows-server-2022-core: cfg               : http://schemas.microsoft.com/wbem/wsman/1/config/service/auth
==> proxmox-iso.windows-server-2022-core: lang              : en-US
==> proxmox-iso.windows-server-2022-core: Basic             : true
==> proxmox-iso.windows-server-2022-core: Kerberos          : true
==> proxmox-iso.windows-server-2022-core: Negotiate         : true
==> proxmox-iso.windows-server-2022-core: Certificate       : false
==> proxmox-iso.windows-server-2022-core: CredSSP           : true
==> proxmox-iso.windows-server-2022-core: CbtHardeningLevel : Relaxed
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core: VERBOSE: Adding firewall rule to allow WinRM HTTPS.
==> proxmox-iso.windows-server-2022-core: Ok.
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core: VERBOSE: HTTP: Disabled | HTTPS: Enabled
==> proxmox-iso.windows-server-2022-core: VERBOSE: PS Remoting has been successfully configured for Ansible.
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core: Deleted 1 rule(s).
==> proxmox-iso.windows-server-2022-core: Ok.
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core: Deleted 1 rule(s).
==> proxmox-iso.windows-server-2022-core: Ok.
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core: Caption                       :
==> proxmox-iso.windows-server-2022-core: Description                   :
==> proxmox-iso.windows-server-2022-core: ElementName                   : WinRM-HTTP (Jump station)
==> proxmox-iso.windows-server-2022-core: InstanceID                    : {967ecbdb-a92a-4c47-a2b4-6d9b814a1f56}
==> proxmox-iso.windows-server-2022-core: CommonName                    :
==> proxmox-iso.windows-server-2022-core: PolicyKeywords                :
==> proxmox-iso.windows-server-2022-core: Enabled                       : True
==> proxmox-iso.windows-server-2022-core: PolicyDecisionStrategy        : 2
==> proxmox-iso.windows-server-2022-core: PolicyRoles                   :
==> proxmox-iso.windows-server-2022-core: ConditionListType             : 3
==> proxmox-iso.windows-server-2022-core: CreationClassName             : MSFT|FW|FirewallRule|{967ecbdb-a92a-4c47-a2b4-6d9b814a1f56}
==> proxmox-iso.windows-server-2022-core: ExecutionStrategy             : 2
==> proxmox-iso.windows-server-2022-core: Mandatory                     :
==> proxmox-iso.windows-server-2022-core: PolicyRuleName                :
==> proxmox-iso.windows-server-2022-core: Priority                      :
==> proxmox-iso.windows-server-2022-core: RuleUsage                     :
==> proxmox-iso.windows-server-2022-core: SequencedActions              : 3
==> proxmox-iso.windows-server-2022-core: SystemCreationClassName       :
==> proxmox-iso.windows-server-2022-core: SystemName                    :
==> proxmox-iso.windows-server-2022-core: Action                        : Allow
==> proxmox-iso.windows-server-2022-core: Direction                     : Inbound
==> proxmox-iso.windows-server-2022-core: DisplayGroup                  :
==> proxmox-iso.windows-server-2022-core: DisplayName                   : WinRM-HTTP (Jump station)
==> proxmox-iso.windows-server-2022-core: EdgeTraversalPolicy           : Block
==> proxmox-iso.windows-server-2022-core: EnforcementStatus             : NotApplicable
==> proxmox-iso.windows-server-2022-core: LocalOnlyMapping              : False
==> proxmox-iso.windows-server-2022-core: LooseSourceMapping            : False
==> proxmox-iso.windows-server-2022-core: Owner                         :
==> proxmox-iso.windows-server-2022-core: Platforms                     : {}
==> proxmox-iso.windows-server-2022-core: PolicyAppId                   :
==> proxmox-iso.windows-server-2022-core: PolicyStoreSource             : PersistentStore
==> proxmox-iso.windows-server-2022-core: PolicyStoreSourceType         : Local
==> proxmox-iso.windows-server-2022-core: PrimaryStatus                 : OK
==> proxmox-iso.windows-server-2022-core: Profiles                      : 0
==> proxmox-iso.windows-server-2022-core: RemoteDynamicKeywordAddresses : {}
==> proxmox-iso.windows-server-2022-core: RuleGroup                     :
==> proxmox-iso.windows-server-2022-core: Status                        : The rule was parsed successfully from the store. (65536)
==> proxmox-iso.windows-server-2022-core: StatusCode                    : 65536
==> proxmox-iso.windows-server-2022-core: PSComputerName                :
==> proxmox-iso.windows-server-2022-core: Name                          : {967ecbdb-a92a-4c47-a2b4-6d9b814a1f56}
==> proxmox-iso.windows-server-2022-core: ID                            : {967ecbdb-a92a-4c47-a2b4-6d9b814a1f56}
==> proxmox-iso.windows-server-2022-core: Group                         :
==> proxmox-iso.windows-server-2022-core: Profile                       : Any
==> proxmox-iso.windows-server-2022-core: Platform                      : {}
==> proxmox-iso.windows-server-2022-core: LSM                           : False
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core: Caption                       :
==> proxmox-iso.windows-server-2022-core: Description                   :
==> proxmox-iso.windows-server-2022-core: ElementName                   : WinRM-HTTPS (Jump station)
==> proxmox-iso.windows-server-2022-core: InstanceID                    : {989b1e95-1fe7-423c-bc1e-b100bcfbe954}
==> proxmox-iso.windows-server-2022-core: CommonName                    :
==> proxmox-iso.windows-server-2022-core: PolicyKeywords                :
==> proxmox-iso.windows-server-2022-core: Enabled                       : True
==> proxmox-iso.windows-server-2022-core: PolicyDecisionStrategy        : 2
==> proxmox-iso.windows-server-2022-core: PolicyRoles                   :
==> proxmox-iso.windows-server-2022-core: ConditionListType             : 3
==> proxmox-iso.windows-server-2022-core: CreationClassName             : MSFT|FW|FirewallRule|{989b1e95-1fe7-423c-bc1e-b100bcfbe954}
==> proxmox-iso.windows-server-2022-core: ExecutionStrategy             : 2
==> proxmox-iso.windows-server-2022-core: Mandatory                     :
==> proxmox-iso.windows-server-2022-core: PolicyRuleName                :
==> proxmox-iso.windows-server-2022-core: Priority                      :
==> proxmox-iso.windows-server-2022-core: RuleUsage                     :
==> proxmox-iso.windows-server-2022-core: SequencedActions              : 3
==> proxmox-iso.windows-server-2022-core: SystemCreationClassName       :
==> proxmox-iso.windows-server-2022-core: SystemName                    :
==> proxmox-iso.windows-server-2022-core: Action                        : Allow
==> proxmox-iso.windows-server-2022-core: Direction                     : Inbound
==> proxmox-iso.windows-server-2022-core: DisplayGroup                  :
==> proxmox-iso.windows-server-2022-core: DisplayName                   : WinRM-HTTPS (Jump station)
==> proxmox-iso.windows-server-2022-core: EdgeTraversalPolicy           : Block
==> proxmox-iso.windows-server-2022-core: EnforcementStatus             : NotApplicable
==> proxmox-iso.windows-server-2022-core: LocalOnlyMapping              : False
==> proxmox-iso.windows-server-2022-core: LooseSourceMapping            : False
==> proxmox-iso.windows-server-2022-core: Owner                         :
==> proxmox-iso.windows-server-2022-core: Platforms                     : {}
==> proxmox-iso.windows-server-2022-core: PolicyAppId                   :
==> proxmox-iso.windows-server-2022-core: PolicyStoreSource             : PersistentStore
==> proxmox-iso.windows-server-2022-core: PolicyStoreSourceType         : Local
==> proxmox-iso.windows-server-2022-core: PrimaryStatus                 : OK
==> proxmox-iso.windows-server-2022-core: Profiles                      : 0
==> proxmox-iso.windows-server-2022-core: RemoteDynamicKeywordAddresses : {}
==> proxmox-iso.windows-server-2022-core: RuleGroup                     :
==> proxmox-iso.windows-server-2022-core: Status                        : The rule was parsed successfully from the store. (65536)
==> proxmox-iso.windows-server-2022-core: StatusCode                    : 65536
==> proxmox-iso.windows-server-2022-core: PSComputerName                :
==> proxmox-iso.windows-server-2022-core: Name                          : {989b1e95-1fe7-423c-bc1e-b100bcfbe954}
==> proxmox-iso.windows-server-2022-core: ID                            : {989b1e95-1fe7-423c-bc1e-b100bcfbe954}
==> proxmox-iso.windows-server-2022-core: Group                         :
==> proxmox-iso.windows-server-2022-core: Profile                       : Any
==> proxmox-iso.windows-server-2022-core: Platform                      : {}
==> proxmox-iso.windows-server-2022-core: LSM                           : False
==> proxmox-iso.windows-server-2022-core:
==> proxmox-iso.windows-server-2022-core: Provisioning with Powershell...
==> proxmox-iso.windows-server-2022-core: Provisioning with powershell script: ./scripts/sysprep.ps1
==> proxmox-iso.windows-server-2022-core: Cleaning Windows Update cache
==> proxmox-iso.windows-server-2022-core: Cleaning temp files
==> proxmox-iso.windows-server-2022-core: Removing logon reg keys
==> proxmox-iso.windows-server-2022-core: Resetting network adapter 'Ethernet' to DHCP...
==> proxmox-iso.windows-server-2022-core: Stopping VM
==> proxmox-iso.windows-server-2022-core: Converting VM to template
Build 'proxmox-iso.windows-server-2022-core' finished after 27 minutes 43 seconds.

==> Wait completed after 27 minutes 43 seconds

==> Builds finished. The artifacts of successful builds are:
--> proxmox-iso.windows-server-2022-core: A template was created: 9000
```