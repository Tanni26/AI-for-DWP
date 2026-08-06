<#
Endpoint Health Report (Read-Only)
PowerShell version: 5.1

Purpose:
- Collect endpoint health data for troubleshooting and triage.
- Perform read-only checks only (no system configuration changes).

VERIFY BEFORE RUNNING:
1) Internet speed test section:
   - This script uses the external command-line tool "speedtest" if present.
   - Verify your environment allows running external tools and outbound test traffic.
   - If "speedtest" is not installed, the script reports "to confirm" for speed.
2) Event log access:
   - Reading System log errors may require elevated permissions on some endpoints.
3) Defender service naming:
   - This script checks WinDefend service state. Confirm service name matches your image baseline.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# This helper prints section headers for readability in the console/report output.
function Write-Section {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title
    )
    Write-Host "`n=== $Title ==="
}

# This helper safely runs a read-only data collection block and reports errors as "to confirm".
function Invoke-ReadOnlyCheck {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock
    )
    try {
        & $ScriptBlock
    }
    catch {
        Write-Output ("{0}: to confirm ({1})" -f $Name, $_.Exception.Message)
    }
}

# This section reports system uptime based on the last boot timestamp.
Write-Section -Title 'System Uptime'
Invoke-ReadOnlyCheck -Name 'System uptime' -ScriptBlock {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $boot = $os.LastBootUpTime
    $uptime = (Get-Date) - $boot
    [PSCustomObject]@{
        LastBootTime = $boot
        UptimeDays   = [math]::Round($uptime.TotalDays, 2)
        UptimeHours  = [math]::Round($uptime.TotalHours, 2)
    } | Format-List
}

# This section reports free and total disk space for local fixed drives.
Write-Section -Title 'Free Disk Space'
Invoke-ReadOnlyCheck -Name 'Free disk space' -ScriptBlock {
    Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" |
        Select-Object DeviceID,
            @{Name='SizeGB';Expression={[math]::Round($_.Size / 1GB, 2)}},
            @{Name='FreeGB';Expression={[math]::Round($_.FreeSpace / 1GB, 2)}},
            @{Name='FreePercent';Expression={
                if ($_.Size -gt 0) {
                    [math]::Round(($_.FreeSpace / $_.Size) * 100, 2)
                }
                else {
                    $null
                }
            }} |
        Format-Table -AutoSize
}

# This section checks common registry locations indicating a pending reboot.
Write-Section -Title 'Pending Reboot Check (Registry)'
Invoke-ReadOnlyCheck -Name 'Pending reboot check' -ScriptBlock {
    $pendingPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired',
        'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
    )

    $sessionManagerPending = $false
    $sessionManagerValue = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'PendingFileRenameOperations' -ErrorAction SilentlyContinue
    if ($null -ne $sessionManagerValue) {
        $sessionManagerPending = $true
    }

    $results = [PSCustomObject]@{
        CBSRebootPending            = Test-Path -Path $pendingPaths[0]
        WindowsUpdateRebootRequired = Test-Path -Path $pendingPaths[1]
        PendingFileRenameOperations = $sessionManagerPending
    }

    $isPending = $results.CBSRebootPending -or $results.WindowsUpdateRebootRequired -or $results.PendingFileRenameOperations

    $results | Format-List
    Write-Output ("PendingRebootOverall: {0}" -f $isPending)
}

# This section reports the top 5 running processes by Working Set memory usage.
Write-Section -Title 'Top 5 Processes by Memory (Working Set)'
Invoke-ReadOnlyCheck -Name 'Top processes by memory' -ScriptBlock {
    Get-Process |
        Sort-Object -Property WorkingSet64 -Descending |
        Select-Object -First 5 ProcessName, Id,
            @{Name='WorkingSetMB';Expression={[math]::Round($_.WorkingSet64 / 1MB, 2)}} |
        Format-Table -AutoSize
}

# This section reports the top 5 running processes by cumulative CPU time.
Write-Section -Title 'Top 5 Processes by CPU'
Invoke-ReadOnlyCheck -Name 'Top processes by CPU' -ScriptBlock {
    Get-Process |
        Sort-Object -Property CPU -Descending |
        Select-Object -First 5 ProcessName, Id,
            @{Name='CPUSeconds';Expression={[math]::Round($_.CPU, 2)}} |
        Format-Table -AutoSize
}

# This section reports the latest 5 Error entries from the System event log.
Write-Section -Title 'Last 5 System Log Errors'
Invoke-ReadOnlyCheck -Name 'System log errors' -ScriptBlock {
    Get-WinEvent -FilterHashtable @{LogName='System'; Level=2} -MaxEvents 5 |
        Select-Object TimeCreated, ProviderName, Id, LevelDisplayName, Message |
        Format-Table -Wrap -AutoSize
}

# This section runs an internet speed test using "speedtest" CLI if installed.
Write-Section -Title 'Internet Speed'
Invoke-ReadOnlyCheck -Name 'Internet speed' -ScriptBlock {
    $speedTestCmd = Get-Command -Name 'speedtest' -ErrorAction SilentlyContinue
    if ($null -eq $speedTestCmd) {
        Write-Output 'InternetSpeed: to confirm ("speedtest" CLI not found. Install Ookla Speedtest CLI or use approved internal test method.)'
    }
    else {
        & $speedTestCmd.Source --accept-license --accept-gdpr --format=json | Out-String | ConvertFrom-Json |
            Select-Object isp, serverName,
                @{Name='DownloadMbps';Expression={[math]::Round($_.download.bandwidth * 8 / 1MB, 2)}},
                @{Name='UploadMbps';Expression={[math]::Round($_.upload.bandwidth * 8 / 1MB, 2)}},
                @{Name='LatencyMs';Expression={[math]::Round($_.ping.latency, 2)}} |
            Format-List
    }
}

# This section checks whether Microsoft Defender Antivirus service is currently running.
Write-Section -Title 'Microsoft Defender Service Status'
Invoke-ReadOnlyCheck -Name 'Defender service status' -ScriptBlock {
    $svc = Get-Service -Name 'WinDefend' -ErrorAction SilentlyContinue
    if ($null -eq $svc) {
        Write-Output 'WinDefend service: to confirm (service not found on this endpoint/image)'
    }
    else {
        [PSCustomObject]@{
            ServiceName = $svc.Name
            DisplayName = $svc.DisplayName
            Status      = $svc.Status
            IsRunning   = ($svc.Status -eq 'Running')
        } | Format-List
    }
}

# This section reports count of currently logged-in user sessions.
Write-Section -Title 'Logged-In User Count'
Invoke-ReadOnlyCheck -Name 'Logged-in users' -ScriptBlock {
    # "quser" is read-only and provides active/disconnected session details.
    $quserOutput = quser 2>$null
    if (-not $quserOutput) {
        Write-Output 'LoggedInUsers: to confirm (unable to query session list)'
    }
    else {
        $sessionLines = $quserOutput | Select-Object -Skip 1
        $sessionCount = ($sessionLines | Where-Object { $_ -match '\S' }).Count
        Write-Output ("LoggedInUserSessions: {0}" -f $sessionCount)
        Write-Output 'SessionDetails:'
        $quserOutput
    }
}

# This section reports when the most recent Windows update was installed.
Write-Section -Title 'Last Windows Update Installed'
Invoke-ReadOnlyCheck -Name 'Last Windows update' -ScriptBlock {
    $latestQfe = Get-CimInstance -ClassName Win32_QuickFixEngineering |
        Sort-Object -Property InstalledOn -Descending |
        Select-Object -First 1

    if ($null -eq $latestQfe) {
        Write-Output 'LastWindowsUpdate: to confirm (no Win32_QuickFixEngineering records returned)'
    }
    else {
        [PSCustomObject]@{
            HotFixID    = $latestQfe.HotFixID
            Description = $latestQfe.Description
            InstalledOn = $latestQfe.InstalledOn
        } | Format-List
    }
}

# This final note confirms the script performed read-only checks.
Write-Host "`nReport complete. This script performed read-only data collection only."
