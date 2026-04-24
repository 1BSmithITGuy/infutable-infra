# Final cleanup and sysprep of windows-server-2022-core template.
#
# Sysprep runs via a scheduled task so this script can exit cleanly.

$ErrorActionPreference = "Stop"
$bootstrapDir = 'C:\ProgramData\Infutable\bootstrap\packer'
$jumpStationIP = '10.0.0.15'
New-Item -Path $bootstrapDir -ItemType Directory -Force | Out-Null

# --- Cleanup ----------------------------------------------------------------

Write-Host "Cleaning Windows Update cache"
Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "C:\Windows\SoftwareDistribution\Download\*" -ErrorAction SilentlyContinue
Start-Service wuauserv -ErrorAction SilentlyContinue

Write-Host "Cleaning temp files"
Get-ChildItem "C:\Windows\Temp" -Exclude "packer-*" |   
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  # Note:  Packer still needs files
Remove-Item -Recurse -Force "$env:USERPROFILE\AppData\Local\Temp\*" -ErrorAction SilentlyContinue

Write-Host "Removing logon reg keys"
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -ErrorAction SilentlyContinue

# --- Reset network to DHCP ----------------------------------------------------
# Assumes a single primary NIC (lab)
$adapter = Get-NetAdapter | Select-Object -First 1
if ($adapter) {
    Write-Host "Resetting network adapter '$($adapter.Name)' to DHCP..."
    Remove-NetIPAddress -InterfaceIndex $adapter.ifIndex -Confirm:$false -ErrorAction SilentlyContinue
    Set-NetIPInterface -InterfaceIndex $adapter.ifIndex -Dhcp Enabled
    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ResetServerAddresses
}

# --- Enable RDP ---------------------------------------------------------------
Write-Host "Enabling Remote Desktop..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" `
    -Name "fDenyTSConnections" -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" `
    -Name "UserAuthentication" -Value 1
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# --- Generate sysprep unattend ------------------------------------------------
# Builds the unattend XML at runtime using the admin password passed in from Packer. 
# The password is sourced from a gitignored variable file.
# Skips OOBE and sets a bootstrap password.
# Downstream provisioning (or LAPS, Vault, etc) will rotate or replace this credential.
# Create with Windows System Image Manager (WSIM)

$password = $env:ADMIN_PASSWORD
if (-not $password) {
    Write-Error "ADMIN_PASSWORD environment variable not set - check the Packer provisioner."
    exit 1
}

$unattend = "$bootstrapDir\sysprep-unattend.xml"

@"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
  <settings pass="oobeSystem">
    <component name="Microsoft-Windows-Shell-Setup"
               processorArchitecture="amd64"
               publicKeyToken="31bf3856ad364e35"
               language="neutral"
               versionScope="nonSxS"
               xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
      <OOBE>
        <HideEULAPage>true</HideEULAPage>
        <HideLocalAccountScreen>true</HideLocalAccountScreen>
        <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
        <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
        <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
        <ProtectYourPC>3</ProtectYourPC>
      </OOBE>
      <UserAccounts>
        <AdministratorPassword>
          <Value>$password</Value>
          <PlainText>true</PlainText>
        </AdministratorPassword>
      </UserAccounts>
      <AutoLogon>
        <Enabled>true</Enabled>
        <Username>Administrator</Username>
        <Password>
          <Value>$password</Value>
          <PlainText>true</PlainText>
        </Password>
        <LogonCount>1</LogonCount>
      </AutoLogon>
      <FirstLogonCommands>
        <SynchronousCommand wcm:action="add">
          <Order>1</Order>
          <CommandLine>cmd /c netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new remoteip=$jumpStationIP</CommandLine>
          <Description>Restrict built-in WinRM rules to jump station</Description>
        </SynchronousCommand>
        <SynchronousCommand wcm:action="add">
          <Order>2</Order>
          <CommandLine>cmd /c rmdir /s /q "C:\ProgramData\Infutable\bootstrap\packer"</CommandLine>
          <Description>Clean up Packer bootstrap artifacts</Description>
        </SynchronousCommand>
      </FirstLogonCommands>
      <TimeZone>UTC</TimeZone>
    </component>
    <component name="Microsoft-Windows-International-Core"
               processorArchitecture="amd64"
               publicKeyToken="31bf3856ad364e35"
               language="neutral"
               versionScope="nonSxS">
      <InputLocale>en-US</InputLocale>
      <SystemLocale>en-US</SystemLocale>
      <UILanguage>en-US</UILanguage>
      <UserLocale>en-US</UserLocale>
    </component>
  </settings>
</unattend>
"@ | Out-File -FilePath $unattend -Encoding UTF8

Write-Host "Sysprep unattend generated - $unattend"
Write-Host "Scheduling sysprep"

$wrapperPath = "$bootstrapDir\run-sysprep.ps1"

@"
Unregister-ScheduledTask -TaskName 'Infutable-Sysprep' -Confirm:`$false
Remove-Item 'C:\Windows\Temp\packer-*' -Force -ErrorAction SilentlyContinue
C:\Windows\System32\Sysprep\sysprep.exe /oobe /generalize /shutdown /mode:vm /unattend:$unattend
"@ | Out-File -FilePath $wrapperPath -Encoding UTF8 -Force

$action = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File $wrapperPath"

$trigger = New-ScheduledTaskTrigger -Once -At ((Get-Date).AddSeconds(15))

Register-ScheduledTask -TaskName 'Infutable-Sysprep' -Action $action -Trigger $trigger -User 'SYSTEM' -RunLevel Highest -Force | Out-Null
