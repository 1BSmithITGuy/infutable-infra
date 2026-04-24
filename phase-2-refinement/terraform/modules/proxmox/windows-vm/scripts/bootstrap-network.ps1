# =============================================================================
# Network Bootstrap for Terraform-provisioned Windows VMs
#
# Required parameter example:
#     -IPAddress '10.0.1.4' -PrefixLength 26 -Gateway '10.0.1.1' -DNS '10.0.1.3' -Hostname 'INFUS103DC03'
# 
# The VM boots with DHCP, then this script sets DNS, renames the computer, and schedules a one time task 
# to apply the static IP and reboot. 
#       The scheduled task is to delay the static IP changes until after the WinRM
#           session exits cleanly, so Terraform does not see the connection drop as a failure.
#
# Notes:
#    Does not (currently) work with multiple adapters
# =============================================================================

param(
    [Parameter(Mandatory)][string]$IPAddress,
    [Parameter(Mandatory)][int]$PrefixLength,
    [Parameter(Mandatory)][string]$Gateway,
    [Parameter(Mandatory)][string]$DNS,
    [Parameter(Mandatory)][string]$Hostname
)

#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

$bootstrapDir = 'C:\ProgramData\Infutable\bootstrap\terraform'
New-Item -Path $bootstrapDir -ItemType Directory -Force | Out-Null

$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1

    if (-not $adapter)
        {throw "network adapter not found."}

# --- Set DNS  ------------------------------------------------------------------
Write-Host "Setting DNS to $DNS"
Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses $DNS

# --- Sync time ------------------------------------------------------------
Write-Host "Force time sync"
w32tm /resync /force 2>&1 | Out-Host

# --- Rename computer ------------------------------------------------------
Write-Host "Renaming to $Hostname"
Rename-Computer -NewName $Hostname -Force

# --- Schedule static IP and reboot --------------------------------------------
# 15-second delay to ensure WinRM completes before the task runs

$scriptPath = "$bootstrapDir\set-static-ip.ps1"

#  Script below needs Remove-NetRoute;
#  without it, it keeps the old gateway, but also and adds a new one, causing an occasional failure joining domain.
$taskScript = @"
    `$ErrorActionPreference = 'Stop'
    `$a = Get-NetAdapter | Where-Object { `$_.Status -eq 'Up' } | Select-Object -First 1
    Set-NetIPInterface -InterfaceIndex `$a.ifIndex -Dhcp Disabled
    Remove-NetIPAddress -InterfaceIndex `$a.ifIndex -Confirm:`$false -ErrorAction SilentlyContinue
    Remove-NetRoute -InterfaceIndex `$a.ifIndex -DestinationPrefix '0.0.0.0/0' -Confirm:`$false -ErrorAction SilentlyContinue
    New-NetIPAddress -InterfaceIndex `$a.ifIndex -IPAddress '$IPAddress' -PrefixLength $PrefixLength -DefaultGateway '$Gateway'
    Unregister-ScheduledTask -TaskName 'Infutable-BootstrapNetwork' -Confirm:`$false -ErrorAction SilentlyContinue
    Remove-Item '$bootstrapDir' -Recurse -Force -ErrorAction SilentlyContinue
    Restart-Computer -Force
"@

$taskScript | Out-File -FilePath $scriptPath -Encoding UTF8 -Force

$action = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File $scriptPath"

$trigger = New-ScheduledTaskTrigger -Once -At ((Get-Date).AddSeconds(15))

Register-ScheduledTask -TaskName 'Infutable-BootstrapNetwork' -Action $action -Trigger $trigger -User 'SYSTEM' `
    -RunLevel Highest -Force | Out-Null

Write-Host "VM will reboot in 15 seconds with Static IP ($IPAddress/$PrefixLength, gw $Gateway) scheduled via task."