# Installs VirtIO drivers and the QEMU guest agent in the Packer image build process for Windows Server 2022.
# Runs as a Packer provisioner

$ErrorActionPreference = "Stop"

# Find the ISO
$virtio = (Get-Volume | Where-Object { $_.FileSystemLabel -like "BUILD*" }).DriveLetter
    
if (-not $virtio) {
    Write-Error "Build tools ISO not found"
    exit 1
}

# Install VirtIO drivers
$drivers = @("Balloon", "vioserial", "viostor")

foreach ($name in $drivers) {
    $driverPath = "${virtio}:\${name}\2k22\amd64\*.inf"
    
    if (Test-Path $driverPath) {
        Write-Host "Installing ${name} driver..."
        pnputil.exe /add-driver $driverPath /install
        } 
        else {Write-Warning "Driver path not found: $driverPath - skipping"}
}

# Install QEMU Guest Agent
$gaPath = "${virtio}:\guest-agent\qemu-ga-x86_64.msi"

if (Test-Path $gaPath) {
    Write-Host "Installing QEMU Guest Agent"
    Start-Process msiexec.exe -ArgumentList "/i `"$gaPath`" /qn /norestart" -Wait -NoNewWindow
    Set-Service QEMU-GA -StartupType Automatic
    Start-Service QEMU-GA -ErrorAction SilentlyContinue
    } 
    else {
        Write-Error "QEMU Guest Agent MSI not found at: $gaPath"
        exit 1
    }

# Verify guest agent is running
$svc = Get-Service QEMU-GA -ErrorAction SilentlyContinue

if ($svc -and $svc.Status -eq "Running") {
    Write-Host "QEMU Guest Agent is running."
    } 
    else {Write-Warning "QEMU Guest Agent service is not running."}
