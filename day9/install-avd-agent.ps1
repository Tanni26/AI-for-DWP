# AVD Agent Installation Script
# Purpose: Install and register the AVD agent on a session host VM
# Target: Windows 11 multi-session AVD VM
# Prerequisites: Run as Administrator, internet connectivity

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AVD Agent Installation Script"
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set error action preference
$ErrorActionPreference = "Continue"

# Configure TLS for secure downloads
Write-Host "[1/5] Configuring TLS security protocol..."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "✓ TLS 1.2 enabled" -ForegroundColor Green

# Create temp directory if it doesn't exist
Write-Host "[2/5] Setting up temporary directory..."
$tempDir = "C:\Windows\Temp"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}
Write-Host "✓ Temp directory ready: $tempDir" -ForegroundColor Green

# Download AVD Agent MSI
Write-Host "[3/5] Downloading AVD Agent..."
$uri = "https://aka.ms/avdagent/msi/latest"
$msiPath = Join-Path $tempDir "AVDAgent.msi"

try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($uri, $msiPath)
    $fileSize = (Get-Item $msiPath).Length
    Write-Host "✓ Downloaded: $msiPath ($fileSize bytes)" -ForegroundColor Green
} catch {
    Write-Host "✗ Download failed: $_" -ForegroundColor Red
    exit 1
}

# Install AVD Agent MSI
Write-Host "[4/5] Installing AVD Agent..."
try {
    $process = Start-Process -FilePath "msiexec.exe" `
                             -ArgumentList "/i", $msiPath, "/quiet", "/norestart" `
                             -PassThru `
                             -Wait
    
    if ($process.ExitCode -eq 0) {
        Write-Host "✓ Installation successful (exit code: 0)" -ForegroundColor Green
    } else {
        Write-Host "⚠ Installation completed with exit code: $($process.ExitCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Installation failed: $_" -ForegroundColor Red
    exit 1
}

# Wait for services to initialize and start
Write-Host "[5/5] Initializing services..."
Write-Host "Waiting 30 seconds for AVD services to start..."
Start-Sleep -Seconds 30

# Check agent services status
Write-Host ""
Write-Host "Service Status Check:" -ForegroundColor Cyan
Write-Host "====================="

$services = @("RDAgentBootLoader", "SessionEnvAgent", "Remote Desktop Services")
foreach ($service in $services) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc) {
        $status = $svc.Status
        $statusColor = if ($status -eq "Running") { "Green" } else { "Yellow" }
        Write-Host "$service : $status" -ForegroundColor $statusColor
    } else {
        Write-Host "$service : NOT FOUND" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AVD Agent Installation Complete"
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:"
Write-Host "1. The session host will now attempt to register with the host pool"
Write-Host "2. Wait 2-3 minutes for registration to complete"
Write-Host "3. Check Azure Portal > Desktop Virtualization > Host Pools > POOL-FIN-01"
Write-Host "4. Verify session host appears with 'Available' status"
Write-Host ""
Write-Host "If registration fails, check:"
Write-Host "• Event Viewer > Windows Logs > System (look for RD Agent events)"
Write-Host "• Network connectivity to AVD broker endpoints"
Write-Host "• Registration token validity and scope"
Write-Host ""
