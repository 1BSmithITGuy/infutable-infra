# Configures WinRM for Ansible management on cloned VMs.
#
# What this does:
#   1. Downloads and runs the official Ansible WinRM setup script from GitHub
#      *  creates HTTPS listener on 5986, enables CredSSP
#   2. Sets WinRM service to auto-start
#
# Runs as a Packer provisioner after updates
#  NOTE:  need to download ansible script to a local file share!  This is high priority in a future refinement plan.  Don't have shares setup yet on domain (do when automating updates)

$ErrorActionPreference = "Stop"

# --- Download/run ConfigureRemotingForAnsible.ps1 -------------------------

$ansibleScript = "C:\Windows\Temp\ConfigureRemotingForAnsible.ps1"
$url = "https://raw.githubusercontent.com/ansible/ansible-documentation/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
#  NOTE:  need to download to a local file share!  This is high priority in a future refinement plan.  Don't have windows shares setup yet (do when automating updates)

Write-Host "Downloading ConfigureRemotingForAnsible.ps1"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile $ansibleScript

if (-not (Test-Path $ansibleScript)) {
    Write-Error "Failed to download script from: $url"
    exit 1
    }

Write-Host "Running Ansible WinRM configuration"
& $ansibleScript -EnableCredSSP -ForceNewSSLCert -Verbose

Set-Service WinRM -StartupType Automatic

# --- WinRM - use windows fw to restrict to jump station (10.0.0.15) ----------------------
# Clean up rules from autounattend and ansible script
netsh advfirewall firewall delete rule name="WinRM-HTTP" 2>$null
netsh advfirewall firewall delete rule name="Allow WinRM HTTPS" 2>$null
Disable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)" -ErrorAction SilentlyContinue

# Allow WinRM from jump station
New-NetFirewallRule -DisplayName "WinRM-HTTP (Jump station)" `
    -Direction Inbound -Protocol TCP -LocalPort 5985 -RemoteAddress 10.0.0.15 -Action Allow
New-NetFirewallRule -DisplayName "WinRM-HTTPS (Jump station)" `
    -Direction Inbound -Protocol TCP -LocalPort 5986 -RemoteAddress 10.0.0.15 -Action Allow

# Cleanup
Remove-Item $ansibleScript -Force -ErrorAction SilentlyContinue
