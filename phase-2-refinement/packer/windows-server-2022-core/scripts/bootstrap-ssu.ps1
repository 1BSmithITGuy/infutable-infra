# Installs the CU from the build tools ISO.
# The 2022 eval ISO service stack is too old to discover current updates without this.
#
# Place the MSU in the updates\ folder on the build tools ISO (ws2022-build-tools.iso).
# The script finds whatever .msu is there.
#
# wusa.exe runs via a scheduled task as SYSTEM to avoid "Access Denied" over WinRM.
# A reboot is needed after install.
# Runs as a Packer provisioner.

$ErrorActionPreference = "Stop"

# --- Find MSU on build tools ISO -------------------------------------
$drive = (Get-Volume | Where-Object { $_.FileSystemLabel -like "BUILD*" }).DriveLetter

if (-not $drive) {
    Write-Error "Build tools ISO not found"
    exit 1
}

$msuFile = Get-ChildItem "${drive}:\updates\" -Filter "*.msu" -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $msuFile) {
    Write-Error "No .msu file found on build tools ISO"
    exit 1
}

$kbName = $msuFile.BaseName

# --- Copy MSU ---------------------------------------------------------
$localMsu = "C:\Windows\Temp\$($msuFile.Name)"

Copy-Item $msuFile.FullName $localMsu -Force
Write-Host "Copied MSU to $localMsu"

# --- Install via scheduled task -------------------------------------
$taskName = "PackerInstallCU"

$action  = New-ScheduledTaskAction -Execute "wusa.exe" -Argument "`"$localMsu`" /quiet /norestart"

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName $taskName -Action $action -Principal $principal -Force | Out-Null
Write-Host "Installing $kbName"

Start-ScheduledTask -TaskName $taskName

# Poll until the task completes
$timeout = 1800  # 30 minutes
$elapsed = 0

do {
    Start-Sleep -Seconds 15

    $elapsed += 15
    $state = (Get-ScheduledTask -TaskName $taskName).State

    if ($elapsed % 60 -eq 0)
        {Write-Host "  Still installing ($elapsed seconds elapsed)"}

} while ($state -eq "Running" -and $elapsed -lt $timeout)

# Get the exit code from the task's last result
$result = (Get-ScheduledTaskInfo -TaskName $taskName).LastTaskResult

# Clean up the scheduled task
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false

switch ($result) {
    0          { Write-Host "$kbName installed successfully." }
    3010       { Write-Host "$kbName installed successfully (reboot required)." }
    2359302    { Write-Host "$kbName is already installed." }
    default    { Write-Warning "$kbName install exited with code: $result" }
}

# Clean up local copy
Remove-Item $localMsu -Force -ErrorAction SilentlyContinue
