#Requires -Version 5.1

<#
.SYNOPSIS
    Enhanced Floor 6 Post-Deployment Diagnostic Script
    Investigates login and performance issues following Windows 11 migration and application deployment.

.DESCRIPTION
    Performs read-only diagnostic collection from device logs, services, tasks, and performance metrics
    to determine if a specific application deployment caused reported login/performance issues.
    
    Operates in read-only mode. No applications are modified, services are stopped, or configurations changed.
    Outputs structured JSON for parsing and analysis by other tools/engineers.
    
    Includes support for dry-run validation, unique RunId tracking for idempotency, and artifact cleanup via rollback.

.PARAMETER ApplicationName
    Name or pattern to identify the target application deployment being investigated.
    Required when not in DryRun or Rollback modes.
    Example: "ShareFile", "document management", "content repository"

.PARAMETER DeploymentDate
    The date the application was deployed (for example, "2024-01-12").
    If not provided, defaults to 7 days before the current date.
    Format: YYYY-MM-DD or relative days (e.g., "-7" for 7 days ago)

.PARAMETER LookbackDays
    Number of days to look back in logs for evidence of issues.
    Default: 3 (covers Friday deployment + Monday morning reporting window)
    Minimum: 1, Maximum: 30

.PARAMETER DryRun
    If $true, displays all checks and data sources without collecting evidence or creating files.
    Useful for validating the script configuration and understanding what will be checked.

.PARAMETER Rollback
    If $true, removes report files and JSON manifests created by a previous collection run.
    Must be combined with -RunId to specify which run's artifacts to clean up.
    Does NOT reverse application deployments or system configuration changes.

.PARAMETER RunId
    Unique identifier for this diagnostic run. Used for tracking and rollback.
    Auto-generated if not provided. Should not contain spaces or special characters.
    Format: Typically YYYYMMDD-HHmmss or alphanumeric string

.PARAMETER OutputPath
    Directory where JSON output and log files will be saved.
    Default: $env:ProgramData\DWP-Diagnostics
    Will be created if it does not exist.

.NOTES
    PowerShell Version: 5.1 (Windows PowerShell)
    Permissions: Administrator privileges required to read certain event logs and services
    Output: Structured JSON with check status, evidence, and recommendations
    
    Read-Only Operations Only:
    - Reads registry (no modifications)
    - Reads event logs (no clearing or modification)
    - Reads WMI/CIM data (no changes)
    - Reads file properties and logs (no deletion or modification)
    - Reads service status (no stopping or disabling)
    
    NOT performed:
    - Application installation/uninstallation
    - Service restart or state changes
    - Registry modification
    - File deletion or moving
    - System settings changes
    - Intune configuration changes

.EXAMPLE
    # Dry-run: Validate script configuration without collecting data
    .\finbridge-floor6-deployment-diagnostics-enhanced.ps1 -DryRun $true -ApplicationName "Document Manager"

    # Actual collection: Investigate specific application deployment
    .\finbridge-floor6-deployment-diagnostics-enhanced.ps1 `
        -ApplicationName "ShareFile" `
        -DeploymentDate "2024-01-12" `
        -LookbackDays 3

    # Rollback: Remove artifacts from a previous run
    .\finbridge-floor6-deployment-diagnostics-enhanced.ps1 `
        -Rollback $true `
        -RunId "20240115-102345"

.PARAMETER Force
    If specified with -Rollback, removes all matching artifacts without confirmation.
#>

[CmdletBinding(SupportsShouldProcess = $false)]
param(
    # Target application being investigated
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ApplicationName,
    
    # Deployment date (used to establish investigation window)
    [Parameter(Mandatory = $false)]
    [string]$DeploymentDate,
    
    # Number of days to look back in logs
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 30)]
    [int]$LookbackDays = 3,
    
    # Dry-run mode: show what would be checked without collecting
    [Parameter(Mandatory = $false)]
    [bool]$DryRun = $false,
    
    # Rollback mode: remove artifacts from previous run
    [Parameter(Mandatory = $false)]
    [bool]$Rollback = $false,
    
    # Unique run identifier for tracking and rollback
    [Parameter(Mandatory = $false)]
    [string]$RunId,
    
    # Output directory for results
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "$env:ProgramData\DWP-Diagnostics",
    
    # Force rollback without confirmation
    [Parameter(Mandatory = $false)]
    [bool]$Force = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ============================================================================
# PARAMETER VALIDATION
# ============================================================================

# Validate mutually exclusive modes
if ($DryRun -and $Rollback) {
    Write-Host "[ERROR] Cannot specify both -DryRun and -Rollback. Choose one mode." -ForegroundColor Red
    exit 1
}

# ApplicationName is required for normal mode
if (-not $DryRun -and -not $Rollback -and [string]::IsNullOrWhiteSpace($ApplicationName)) {
    Write-Host "[ERROR] -ApplicationName parameter is required for diagnostic collection mode." -ForegroundColor Red
    Write-Host "        Use -DryRun `$true to validate the script without providing ApplicationName." -ForegroundColor Yellow
    exit 1
}

# RunId is required for rollback mode
if ($Rollback -and [string]::IsNullOrWhiteSpace($RunId)) {
    Write-Host "[ERROR] -RunId parameter is required for rollback mode." -ForegroundColor Red
    Write-Host "        Example: -RunId '20240115-102345'" -ForegroundColor Yellow
    exit 1
}

# ============================================================================
# CONFIGURATION AND INITIALIZATION
# ============================================================================

# Create unique run identifier if not provided (for idempotency)
if ([string]::IsNullOrWhiteSpace($RunId)) {
    $RunId = Get-Date -Format "yyyyMMdd-HHmmss"
}

# Parse deployment date
$deploymentWindow = $null
if ([string]::IsNullOrWhiteSpace($DeploymentDate)) {
    # Default: Friday of last week (5 days ago) at noon
    $deploymentDate = (Get-Date).AddDays(-5).Date.AddHours(12)
    $deploymentWindowStart = $deploymentDate
    $deploymentWindowEnd = $deploymentDate.AddHours(8)
} else {
    # Parse provided date
    try {
        if ($DeploymentDate -match '^\d+$') {
            # Relative days (e.g., "-7")
            $offset = [int]$DeploymentDate
            $deploymentDate = (Get-Date).AddDays($offset).Date.AddHours(12)
        } else {
            # Absolute date (e.g., "2024-01-12")
            $deploymentDate = [datetime]::ParseExact($DeploymentDate, "yyyy-MM-dd", $null).AddHours(12)
        }
        $deploymentWindowStart = $deploymentDate
        $deploymentWindowEnd = $deploymentDate.AddHours(8)
    } catch {
        Write-Host "[ERROR] Invalid DeploymentDate format. Use YYYY-MM-DD or relative days (e.g., -5)" -ForegroundColor Red
        exit 1
    }
}

# Establish lookback window for event log collection
$lookbackStart = (Get-Date).AddDays(-$LookbackDays)

# Create output directory if needed
if (-not (Test-Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
}

# Generate output filenames
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportFile = Join-Path $OutputPath "Floor6_Diagnostics_${RunId}.json"
$manifestFile = Join-Path $OutputPath "Floor6_Manifest_${RunId}.json"
$logFile = Join-Path $OutputPath "Floor6_Log_${RunId}.txt"

# ============================================================================
# RESULT TRACKING STRUCTURE
# ============================================================================

$diagnosticResults = @{
    RunMetadata = @{
        RunId = $RunId
        Timestamp = Get-Date -Format "o"
        ScriptVersion = "2.0-Enhanced"
        ComputerName = $env:COMPUTERNAME
        OperatingSystem = (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).Caption
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        DryRunMode = $DryRun
        RollbackMode = $Rollback
        ApplicationName = $ApplicationName
        DeploymentWindowStart = $deploymentWindowStart
        DeploymentWindowEnd = $deploymentWindowEnd
        LookbackDays = $LookbackDays
    }
    Diagnostics = @{}
    Summary = @{
        TotalCheckAttempts = 0
        ChecksPassed = 0
        ChecksFailed = 0
        ChecksSkipped = 0
        ChecksInconclusive = 0
        Evidence = @{
            Supporting = @()
            Contradicting = @()
            Inconclusive = @()
        }
        OverallConclusion = "Inconclusive"
    }
}

# ============================================================================
# LOGGING AND UTILITY FUNCTIONS
# ============================================================================

function Write-LogEntry {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'SUCCESS', 'WARN', 'ERROR', 'DEBUG')][string]$Level = 'INFO',
        [bool]$ToFile = $true
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Determine console color
    $color = switch ($Level) {
        'SUCCESS' { 'Green' }
        'ERROR' { 'Red' }
        'WARN' { 'Yellow' }
        'DEBUG' { 'Cyan' }
        default { 'White' }
    }
    
    Write-Host $logEntry -ForegroundColor $color
    
    # Optionally write to file
    if ($ToFile -and -not $DryRun) {
        Add-Content -Path $logFile -Value $logEntry -ErrorAction SilentlyContinue
    }
}

function Add-DiagnosticCheck {
    param(
        [string]$CheckName,
        [ValidateSet('Success', 'Failed', 'Skipped', 'AccessDenied', 'Inconclusive')][string]$Status,
        [hashtable]$Evidence,
        [string]$SupportingEvidence,
        [string]$ContradictingEvidence,
        [string]$ConfirmsCause,
        [string]$RuleOutCause,
        [string]$RecommendedAction,
        [string]$ErrorDetail
    )
    
    $check = @{
        CheckName = $CheckName
        Status = $Status
        Timestamp = Get-Date -Format "o"
        Evidence = $Evidence
        SupportingEvidence = $SupportingEvidence
        ContradictingEvidence = $ContradictingEvidence
        ConfirmsCause = $ConfirmsCause
        RuleOutCause = $RuleOutCause
        RecommendedAction = $RecommendedAction
        ErrorDetail = $ErrorDetail
    }
    
    $diagnosticResults.Diagnostics[$CheckName] = $check
    $diagnosticResults.Summary.TotalCheckAttempts++
    
    switch ($Status) {
        'Success' { 
            $diagnosticResults.Summary.ChecksPassed++
            if ($SupportingEvidence) {
                $diagnosticResults.Summary.Evidence.Supporting += $CheckName
            }
        }
        'Failed' { 
            $diagnosticResults.Summary.ChecksFailed++
            if ($ContradictingEvidence) {
                $diagnosticResults.Summary.Evidence.Contradicting += $CheckName
            }
        }
        'Skipped' { $diagnosticResults.Summary.ChecksSkipped++ }
        'AccessDenied' { $diagnosticResults.Summary.ChecksSkipped++ }
        'Inconclusive' { $diagnosticResults.Summary.ChecksInconclusive++ }
    }
}

function Test-AdminPrivileges {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ============================================================================
# ROLLBACK FUNCTION
# ============================================================================

function Invoke-RollbackArtifacts {
    Write-LogEntry "Rollback mode: Removing diagnostic artifacts for RunId $RunId" "INFO"
    
    # Find matching manifest file
    $manifestPath = Join-Path $OutputPath "Floor6_Manifest_${RunId}.json"
    $reportPath = Join-Path $OutputPath "Floor6_Diagnostics_${RunId}.json"
    $logPath = Join-Path $OutputPath "Floor6_Log_${RunId}.txt"
    
    $removed = 0
    $skipped = 0
    
    # Remove report file if it exists
    if (Test-Path $reportPath) {
        try {
            Remove-Item -Path $reportPath -Force -ErrorAction Stop
            Write-LogEntry "Removed report: $reportPath" "SUCCESS"
            $removed++
        } catch {
            Write-LogEntry "Failed to remove report: $_" "WARN"
            $skipped++
        }
    } else {
        Write-LogEntry "Report file not found: $reportPath" "WARN"
        $skipped++
    }
    
    # Remove log file if it exists
    if (Test-Path $logPath) {
        try {
            Remove-Item -Path $logPath -Force -ErrorAction Stop
            Write-LogEntry "Removed log: $logPath" "SUCCESS"
            $removed++
        } catch {
            Write-LogEntry "Failed to remove log: $_" "WARN"
            $skipped++
        }
    }
    
    # Remove manifest file if it exists
    if (Test-Path $manifestPath) {
        try {
            Remove-Item -Path $manifestPath -Force -ErrorAction Stop
            Write-LogEntry "Removed manifest: $manifestPath" "SUCCESS"
            $removed++
        } catch {
            Write-LogEntry "Failed to remove manifest: $_" "WARN"
            $skipped++
        }
    }
    
    Write-Host ""
    Write-Host "=== Rollback Summary ===" -ForegroundColor Cyan
    Write-Host "Artifacts removed: $removed"
    Write-Host "Artifacts skipped: $skipped"
    Write-Host "Note: Application deployments and system configuration changes are not affected by rollback."
    
    return @{ Removed = $removed; Skipped = $skipped }
}

# ============================================================================
# DIAGNOSTIC COLLECTION FUNCTIONS
# ============================================================================

# SECTION 1: Device and Boot Information
function Collect-DeviceInfo {
    Write-LogEntry "Collecting device and boot information..." "INFO"
    
    if ($DryRun) {
        Write-LogEntry "  [DRY-RUN] Would collect: OS version, build, boot time, uptime, current sessions" "DEBUG"
        Add-DiagnosticCheck -CheckName "Device-Info" -Status "Inconclusive" `
            -Evidence @{ Mode = "DRY-RUN" } `
            -ConfirmsCause "Device info would help determine if reboot coincided with deployment window" `
            -RecommendedAction "Run without -DryRun to collect actual device information"
        return
    }
    
    try {
        $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $systemInfo = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        $biosInfo = Get-CimInstance -ClassName Win32_BIOS -ErrorAction Stop
        
        $bootTime = $osInfo.LastBootUpTime
        $uptimeDays = [math]::Round((New-TimeSpan -Start $bootTime -End (Get-Date)).TotalDays, 2)
        
        # Check if device rebooted within deployment window (within 2 hours of Friday deployment)
        $bootedDuringDeployment = ($bootTime -ge $deploymentWindowStart) -and ($bootTime -le $deploymentWindowEnd.AddHours(2))
        
        $evidence = @{
            ComputerName = $env:COMPUTERNAME
            OSCaption = $osInfo.Caption
            OSVersion = $osInfo.Version
            OSBuild = $osInfo.BuildNumber
            SerialNumber = $biosInfo.SerialNumber
            Manufacturer = $systemInfo.Manufacturer
            Model = $systemInfo.Model
            LastBootTime = $bootTime
            UptimeDays = $uptimeDays
            BootedDuringDeploymentWindow = $bootedDuringDeployment
        }
        
        Add-DiagnosticCheck -CheckName "Device-Info" -Status "Success" `
            -Evidence $evidence `
            -SupportingEvidence $(if ($bootedDuringDeployment) { "Device rebooted during/immediately after deployment window" } else { $null }) `
            -ConfirmsCause "Device rebooted shortly after Friday deployment suggests installation triggered restart" `
            -RuleOutCause "Device uptime significantly exceeds deployment window; no restart from installation likely" `
            -RecommendedAction "Cross-reference boot time with Intune deployment logs for restart requirements"
        
        Write-LogEntry "Device info collected: $($osInfo.Caption), Build $($osInfo.BuildNumber), Uptime ${uptimeDays}d" "SUCCESS"
    } catch {
        Write-LogEntry "Failed to collect device info: $($_.Exception.Message)" "ERROR"
        Add-DiagnosticCheck -CheckName "Device-Info" -Status "Failed" `
            -ErrorDetail $_.Exception.Message `
            -RecommendedAction "Ensure script runs with Administrator privileges"
    }
}

# SECTION 2: Installed Applications and Deployment Timing
function Collect-ApplicationInfo {
    Write-LogEntry "Collecting installed application details..." "INFO"
    
    if ($DryRun) {
        Write-LogEntry "  [DRY-RUN] Would scan: Installed programs, application-specific installs, deployment timing" "DEBUG"
        Add-DiagnosticCheck -CheckName "Application-Inventory" -Status "Inconclusive" `
            -Evidence @{ Mode = "DRY-RUN"; ApplicationName = $ApplicationName } `
            -ConfirmsCause "App installed during deployment window would directly implicate Friday rollout" `
            -RecommendedAction "Run without -DryRun to collect application inventory"
        return
    }
    
    try {
        $appFound = $false
        $appDetails = $null
        $recentInstalls = @()
        
        # Query 64-bit and 32-bit registry for installed apps (avoid Win32_Product for performance)
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        
        $allApps = @()
        foreach ($regPath in $regPaths) {
            $allApps += Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue | 
                Where-Object { $_.DisplayName } |
                Select-Object -Property DisplayName, DisplayVersion, InstallDate, Publisher
        }
        
        # Search for target application by name
        if ($allApps.Count -gt 0) {
            $appFound = $allApps | Where-Object { $_.DisplayName -match [regex]::Escape($ApplicationName) } | Select-Object -First 1
            
            # Check for installs within deployment window
            foreach ($app in $allApps) {
                if ($app.InstallDate) {
                    try {
                        $installDate = [datetime]::ParseExact($app.InstallDate, "yyyyMMdd", $null)
                        if ($installDate -ge $deploymentWindowStart -and $installDate -le $deploymentWindowEnd) {
                            $recentInstalls += @{
                                Name = $app.DisplayName
                                Version = $app.DisplayVersion
                                InstallDate = $installDate
                                Publisher = $app.Publisher
                            }
                        }
                    } catch {
                        # Ignore parsing errors for individual dates
                    }
                }
            }
        }
        
        $evidence = @{
            TotalAppsInstalled = $allApps.Count
            TargetApplicationFound = $null -ne $appFound
            TargetApplication = $appFound
            AppsInstalledDuringDeploymentWindow = $recentInstalls.Count
            RecentInstallations = $recentInstalls
        }
        
        $supportingEv = $null
        $contradictingEv = $null
        
        if ($appFound) {
            $supportingEv = "Target application '$($appFound.DisplayName)' is installed on device"
            if ($recentInstalls.Count -gt 0) {
                $supportingEv += "; $($recentInstalls.Count) app(s) installed during deployment window"
            }
        } else {
            $contradictingEv = "Target application '$ApplicationName' not found in installed programs"
        }
        
        Add-DiagnosticCheck -CheckName "Application-Inventory" -Status "Success" `
            -Evidence $evidence `
            -SupportingEvidence $supportingEv `
            -ContradictingEvidence $contradictingEv `
            -ConfirmsCause "Target app installed during Friday deployment window implicates the rollout" `
            -RuleOutCause "Target app not found or installed before Friday suggests deployment not responsible" `
            -RecommendedAction "If app found: check Intune logs for install failures, retries, or detection loops"
        
        Write-LogEntry "Application scan complete: Found $($allApps.Count) total apps, target=$($null -ne $appFound), recent=$($recentInstalls.Count)" "SUCCESS"
    } catch {
        Write-LogEntry "Failed to collect application info: $($_.Exception.Message)" "ERROR"
        Add-DiagnosticCheck -CheckName "Application-Inventory" -Status "AccessDenied" `
            -ErrorDetail $_.Exception.Message `
            -RecommendedAction "Check registry permissions or try running as Administrator"
    }
}

# SECTION 3: Intune Management Extension Logs
function Collect-IntuneManagementLogs {
    Write-LogEntry "Collecting Intune Management Extension logs..." "INFO"
    
    if ($DryRun) {
        Write-LogEntry "  [DRY-RUN] Would parse: IME logs for install failures, retries, detection issues, timeouts" "DEBUG"
        Add-DiagnosticCheck -CheckName "Intune-Management-Extension" -Status "Inconclusive" `
            -Evidence @{ Mode = "DRY-RUN" } `
            -ConfirmsCause "IME logs showing install failures/retries would strongly indicate deployment issue" `
            -RecommendedAction "Run without -DryRun to examine Intune logs"
        return
    }
    
    try {
        $imeLogPaths = @(
            "$env:ProgramFiles\Microsoft Intune Management Extension\Logs\AgentExecutor.log",
            "$env:ProgramFiles\Microsoft Intune Management Extension\Logs\InstallationSummary.log",
            "$env:ProgramFiles\Microsoft Intune Management Extension\Logs\IntuneManagementExtension.log"
        )
        
        $logsAnalysis = @{}
        $hasErrors = $false
        
        foreach ($logPath in $imeLogPaths) {
            $logName = Split-Path -Path $logPath -Leaf
            
            if (Test-Path -Path $logPath) {
                try {
                    # Read recent log entries only (performance optimization - tail 1000 lines)
                    $logLines = @(Get-Content -Path $logPath -Tail 1000 -ErrorAction Stop)
                    
                    # Search for error patterns relevant to application installation
                    $errorPatterns = @(
                        'Error', 'FAILED', 'Timeout', 'Exception', 'detection loop', 
                        'Install failed', 'Enforcement failed', 'Retry', 'retrying'
                    )
                    
                    $matchedLines = @()
                    foreach ($pattern in $errorPatterns) {
                        $matchedLines += $logLines | Where-Object { $_ -match $pattern }
                    }
                    
                    if ($matchedLines.Count -gt 0) {
                        $hasErrors = $true
                    }
                    
                    $logsAnalysis[$logName] = @{
                        FileExists = $true
                        SizeKB = [math]::Round((Get-Item -Path $logPath).Length / 1KB, 2)
                        LastModified = (Get-Item -Path $logPath).LastWriteTime
                        ErrorPatternsFound = $matchedLines.Count
                        SampleErrors = @($matchedLines | Select-Object -First 5)
                    }
                } catch {
                    $logsAnalysis[$logName] = @{
                        FileExists = $true
                        Error = "Could not read log: $($_.Exception.Message)"
                    }
                }
            } else {
                $logsAnalysis[$logName] = @{
                    FileExists = $false
                    Message = "Intune Management Extension logs not found (IME may not be installed)"
                }
            }
        }
        
        $supportingEv = $null
        if ($hasErrors) {
            $supportingEv = "Error patterns detected in Intune Management Extension logs suggest installation issues"
        }
        
        Add-DiagnosticCheck -CheckName "Intune-Management-Extension" -Status "Success" `
            -Evidence $logsAnalysis `
            -SupportingEvidence $supportingEv `
            -ConfirmsCause "Installation failures, detection loops, or repeated retries in IME logs strongly indicate deployment problem" `
            -RuleOutCause "Clean IME logs with no errors suggest Intune deployment completed successfully" `
            -RecommendedAction "If errors found: review detailed log entries and contact application vendor; consider redeploying if installation incomplete"
        
        Write-LogEntry "Intune logs analyzed: $(($logsAnalysis | Where-Object { $_.Value.FileExists -eq $true }).Count) log file(s) found, $hasErrors error patterns detected" "SUCCESS"
    } catch {
        Write-LogEntry "Failed to collect Intune logs: $($_.Exception.Message)" "ERROR"
        Add-DiagnosticCheck -CheckName "Intune-Management-Extension" -Status "AccessDenied" `
            -ErrorDetail $_.Exception.Message `
            -RecommendedAction "Check file permissions or ensure Intune Management Extension is installed"
    }
}

# SECTION 4: Windows Event Logs (with performance optimization)
function Collect-WindowsEventLogs {
    Write-LogEntry "Collecting Windows Event Logs..." "INFO"
    
    if ($DryRun) {
        Write-LogEntry "  [DRY-RUN] Would query: System, Application, User Profile Service, Group Policy, Winlogon logs for errors" "DEBUG"
        Add-DiagnosticCheck -CheckName "Windows-Event-Logs" -Status "Inconclusive" `
            -Evidence @{ Mode = "DRY-RUN"; LookbackDays = $LookbackDays } `
            -ConfirmsCause "User Profile Service or Group Policy errors during deployment window would indicate app interfered with login" `
            -RecommendedAction "Run without -DryRun to analyze event logs"
        return
    }
    
    try {
        $eventLogs = @{}
        
        # Define log queries with specific event IDs for performance
        $logQueries = @(
            @{
                LogName = "System"
                EventIDs = @(1000, 1001, 1102)  # Errors and critical events
                Description = "System critical errors and events"
            },
            @{
                LogName = "Application"
                EventIDs = @(1000, 1002)  # App crashes and errors
                Description = "Application errors and crashes"
            },
            @{
                LogName = "Microsoft-Windows-User Profile Service/Operational"
                EventIDs = @(1, 4, 6)  # Profile service errors
                Description = "User profile service issues"
            },
            @{
                LogName = "Microsoft-Windows-GroupPolicy/Operational"
                EventIDs = @(1094, 1097, 1098)  # GPO errors
                Description = "Group Policy application failures"
            },
            @{
                LogName = "Microsoft-Windows-Winlogon/Operational"
                EventIDs = @()  # All events, filtered by level
                Description = "Logon/Logoff events and issues"
            }
        )
        
        $hasErrors = $false
        
        foreach ($query in $logQueries) {
            $logName = $query.LogName
            
            try {
                # Build filter hashtable for Get-WinEvent (performance optimization)
                $filterHash = @{
                    LogName = $logName
                    StartTime = $lookbackStart
                }
                
                if ($query.EventIDs -and $query.EventIDs.Count -gt 0) {
                    $filterHash.Id = $query.EventIDs
                } else {
                    # If no specific IDs, filter for error/warning level
                    $filterHash.Level = @(2, 3)  # Error and Warning
                }
                
                # Query events with limit (performance optimization)
                $events = @(Get-WinEvent -FilterHashtable $filterHash -MaxEvents 100 -ErrorAction SilentlyContinue | 
                    Where-Object { $_.LevelDisplayName -in @('Error', 'Critical', 'Warning') })
                
                if ($events.Count -gt 0) {
                    $hasErrors = $true
                }
                
                $eventLogs[$logName] = @{
                    Description = $query.Description
                    EventsFound = $events.Count
                    TimeRange = "Since $(Get-Date $lookbackStart -Format 'yyyy-MM-dd HH:mm')"
                    SampleEvents = @($events | Select-Object -First 5 | ForEach-Object {
                        @{
                            TimeCreated = $_.TimeCreated
                            Level = $_.LevelDisplayName
                            EventId = $_.Id
                            Provider = $_.ProviderName
                            Message = $_.Message.Substring(0, [math]::Min(200, $_.Message.Length))
                        }
                    })
                }
            } catch {
                # Log exists but not accessible or doesn't exist
                $eventLogs[$logName] = @{
                    Description = $query.Description
                    Status = "Inaccessible"
                    ErrorDetail = $_.Exception.Message
                }
            }
        }
        
        $supportingEv = $null
        if ($hasErrors) {
            $supportingEv = "User Profile Service or Group Policy errors detected during lookback period suggest app impacted login pipeline"
        }
        
        Add-DiagnosticCheck -CheckName "Windows-Event-Logs" -Status "Success" `
            -Evidence $eventLogs `
            -SupportingEvidence $supportingEv `
            -ConfirmsCause "High error count in profile service or group policy logs during/after deployment window implicates application installation" `
            -RuleOutCause "Minimal errors in event logs during deployment window suggests app deployment did not cause login issues" `
            -RecommendedAction "Review detailed event messages and correlate timestamps with Intune deployment logs"
        
        Write-LogEntry "Event logs analyzed: Checked $(($eventLogs.Keys).Count) log source(s), error patterns=$hasErrors" "SUCCESS"
    } catch {
        Write-LogEntry "Failed to collect event logs: $($_.Exception.Message)" "ERROR"
        Add-DiagnosticCheck -CheckName "Windows-Event-Logs" -Status "AccessDenied" `
            -ErrorDetail $_.Exception.Message `
            -RecommendedAction "Ensure script runs with Administrator privileges to access event logs"
    }
}

# SECTION 5: Startup Items, Services, and Scheduled Tasks
function Collect-StartupAndServices {
    Write-LogEntry "Collecting startup items, services, and scheduled tasks..." "INFO"
    
    if ($DryRun) {
        Write-LogEntry "  [DRY-RUN] Would enumerate: Startup registry entries, auto-start services, scheduled tasks" "DEBUG"
        Add-DiagnosticCheck -CheckName "Startup-Services-Tasks" -Status "Inconclusive" `
            -Evidence @{ Mode = "DRY-RUN" } `
            -ConfirmsCause "New startup items or services from app could delay login or cause login hangs" `
            -RecommendedAction "Run without -DryRun to examine startup configuration"
        return
    }
    
    try {
        $startupInfo = @{}
        
        # Collect startup registry entries
        $startupRegPaths = @(
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        )
        
        $startupItems = @()
        foreach ($regPath in $startupRegPaths) {
            if (Test-Path -Path $regPath) {
                $startupItems += Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue | 
                    Where-Object { $_ -and $_.PSObject.Properties.Count -gt 5 } |
                    Select-Object -Property @{Name="Registry"; Expression={$regPath}}, * -ExcludeProperty PS* |
                    Get-Member -MemberType NoteProperty | 
                    Where-Object { $_.Name -notmatch '^PS' } |
                    ForEach-Object { @{ Name = $_.Name; Path = $regPath } }
            }
        }
        
        $startupInfo.StartupEntries = @{
            Count = $startupItems.Count
            Items = $startupItems | Select-Object -First 10
        }
        
        # Collect auto-start services (only names and basic status)
        $allServices = @(Get-Service -ErrorAction SilentlyContinue)
        $autoStartServices = @($allServices | Where-Object { $_.StartType -eq "Automatic" })
        
        $startupInfo.AutoStartServices = @{
            TotalServices = $allServices.Count
            AutoStartCount = $autoStartServices.Count
            AutoStartSample = @($autoStartServices | Select-Object -First 10 | ForEach-Object {
                @{
                    Name = $_.Name
                    DisplayName = $_.DisplayName
                    Status = $_.Status
                    StartType = $_.StartType
                }
            })
        }
        
        # Collect scheduled tasks (limited to recently run tasks)
        try {
            $allTasks = @(Get-ScheduledTask -ErrorAction SilentlyContinue)
            $runningTasks = @($allTasks | Where-Object { $_.State -eq "Running" })
            
            $startupInfo.ScheduledTasks = @{
                TotalTasks = $allTasks.Count
                RunningTasks = $runningTasks.Count
                RunningSample = @($runningTasks | Select-Object -First 10 | ForEach-Object {
                    @{
                        TaskName = $_.TaskName
                        TaskPath = $_.TaskPath
                        Enabled = $_.Enabled
                        State = $_.State
                    }
                })
            }
        } catch {
            $startupInfo.ScheduledTasks = @{
                Status = "Inaccessible"
                ErrorDetail = $_.Exception.Message
            }
        }
        
        Add-DiagnosticCheck -CheckName "Startup-Services-Tasks" -Status "Success" `
            -Evidence $startupInfo `
            -ConfirmsCause "New startup entries or auto-start services from app could cause login delays or hangs" `
            -RuleOutCause "No new startup entries or services suggests app doesn't hook into login process" `
            -RecommendedAction "Identify unknown startup entries; verify if associated with deployed application"
        
        Write-LogEntry "Startup analysis complete: $($startupItems.Count) startup entries, $($autoStartServices.Count) auto-start services" "SUCCESS"
    } catch {
        Write-LogEntry "Failed to collect startup/services: $($_.Exception.Message)" "ERROR"
        Add-DiagnosticCheck -CheckName "Startup-Services-Tasks" -Status "AccessDenied" `
            -ErrorDetail $_.Exception.Message `
            -RecommendedAction "Check registry and service permissions"
    }
}

# SECTION 6: Performance Metrics
function Collect-PerformanceMetrics {
    Write-LogEntry "Collecting performance metrics..." "INFO"
    
    if ($DryRun) {
        Write-LogEntry "  [DRY-RUN] Would capture: CPU load, memory usage, disk space, top processes" "DEBUG"
        Add-DiagnosticCheck -CheckName "Performance-Metrics" -Status "Inconclusive" `
            -Evidence @{ Mode = "DRY-RUN" } `
            -ConfirmsCause "High resource usage or deployed app in top processes would suggest performance impact" `
            -RecommendedAction "Run without -DryRun to collect performance baseline"
        return
    }
    
    try {
        $perfMetrics = @{}
        
        # CPU metrics
        $cpuInfo = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cpuInfo) {
            $perfMetrics.CPU = @{
                Cores = $cpuInfo.NumberOfCores
                LogicalProcessors = $cpuInfo.NumberOfLogicalProcessors
                Name = $cpuInfo.Name
                MaxClockSpeedMHz = $cpuInfo.MaxClockSpeed
                CurrentLoad = $cpuInfo.LoadPercentage
            }
        }
        
        # Memory metrics
        $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
        if ($osInfo) {
            $totalMemMB = [math]::Round($osInfo.TotalVisibleMemorySize / 1KB, 2)
            $freeMemMB = [math]::Round($osInfo.FreePhysicalMemory / 1KB, 2)
            $usedMemMB = $totalMemMB - $freeMemMB
            $memUsagePercent = [math]::Round(($usedMemMB / $totalMemMB) * 100, 2)
            
            $perfMetrics.Memory = @{
                TotalMemoryMB = $totalMemMB
                UsedMemoryMB = $usedMemMB
                FreeMemoryMB = $freeMemMB
                UsagePercent = $memUsagePercent
            }
        }
        
        # Disk metrics
        $diskInfo = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($diskInfo) {
            $diskSizeGB = [math]::Round($diskInfo.Size / 1GB, 2)
            $diskFreeGB = [math]::Round($diskInfo.FreeSpace / 1GB, 2)
            $diskUsedGB = $diskSizeGB - $diskFreeGB
            $diskUsagePercent = [math]::Round(($diskUsedGB / $diskSizeGB) * 100, 2)
            
            $perfMetrics.Disk = @{
                DriveLetter = $diskInfo.DeviceID
                TotalSizeGB = $diskSizeGB
                UsedGB = $diskUsedGB
                FreeGB = $diskFreeGB
                UsagePercent = $diskUsagePercent
            }
        }
        
        # Top processes (limited to 10, performance optimization)
        $topProcesses = @(Get-Process -ErrorAction SilentlyContinue | 
            Sort-Object -Property WorkingSet -Descending | 
            Select-Object -First 10 | 
            ForEach-Object {
                @{
                    ProcessName = $_.ProcessName
                    CPU = [math]::Round($_.CPU, 2)
                    MemoryMB = [math]::Round($_.WorkingSet / 1MB, 2)
                    Handles = $_.Handles
                }
            })
        
        $perfMetrics.TopProcessesByMemory = $topProcesses
        
        $supportingEv = $null
        if ($perfMetrics.Memory -and $perfMetrics.Memory.UsagePercent -gt 85) {
            $supportingEv = "High memory usage (>85%) may indicate resource exhaustion from deployed application"
        }
        
        Add-DiagnosticCheck -CheckName "Performance-Metrics" -Status "Success" `
            -Evidence $perfMetrics `
            -SupportingEvidence $supportingEv `
            -ConfirmsCause "Deployed application or related processes consuming high CPU/memory would impact login performance" `
            -RuleOutCause "Normal resource utilization suggests no performance degradation from application installation" `
            -RecommendedAction "If resource usage high: identify top processes and verify if related to deployed application"
        
        Write-LogEntry "Performance metrics collected: CPU=$($perfMetrics.CPU.CurrentLoad)%, Memory=$($perfMetrics.Memory.UsagePercent)%, Disk=$($perfMetrics.Disk.UsagePercent)%" "SUCCESS"
    } catch {
        Write-LogEntry "Failed to collect performance metrics: $($_.Exception.Message)" "ERROR"
        Add-DiagnosticCheck -CheckName "Performance-Metrics" -Status "Failed" `
            -ErrorDetail $_.Exception.Message `
            -RecommendedAction "Try running script again; this check is typically resilient"
    }
}

# ============================================================================
# ANALYSIS AND CONCLUSION
# ============================================================================

function Determine-Conclusion {
    # Analyze evidence to reach overall conclusion
    
    $supportingCount = $diagnosticResults.Summary.Evidence.Supporting.Count
    $contradictingCount = $diagnosticResults.Summary.Evidence.Contradicting.Count
    $inconclusiveCount = $diagnosticResults.Summary.ChecksInconclusive
    
    # Decision logic
    if ($supportingCount -ge 3) {
        $diagnosticResults.Summary.OverallConclusion = "Supported"
        $diagnosticResults.Summary.ConclusionDetail = "Multiple independent evidence points support the deployment as the likely cause"
    } elseif ($contradictingCount -ge 2 -and $supportingCount -eq 0) {
        $diagnosticResults.Summary.OverallConclusion = "Not Supported"
        $diagnosticResults.Summary.ConclusionDetail = "Evidence contradicts the deployment as the cause"
    } else {
        $diagnosticResults.Summary.OverallConclusion = "Inconclusive"
        $diagnosticResults.Summary.ConclusionDetail = "Insufficient or conflicting evidence; escalate for deeper investigation"
    }
    
    # Add recommendations
    $diagnosticResults.Summary.NextSteps = @(
        "Review all check results for Supporting and Contradicting evidence"
        "Correlate timestamps across logs (boot, Intune IME, Event logs)"
        "If deployment suspected: Check Intune console for install logs and detection results"
        "If Group Policy errors present: Run 'gpresult /h report.html' for detailed policy analysis"
        "If performance issues: Baseline the device and monitor during typical login time"
        "Contact application vendor with relevant logs if deployment issue confirmed"
    )
}

# ============================================================================
# OUTPUT AND REPORTING
# ============================================================================

function Save-DiagnosticResults {
    Write-LogEntry "Saving diagnostic results..." "INFO"
    
    try {
        # Convert to JSON (PowerShell 5.1 compatible)
        $jsonOutput = $diagnosticResults | ConvertTo-Json -Depth 5
        
        # Save report
        $jsonOutput | Out-File -FilePath $reportFile -Encoding UTF8 -Force
        Write-LogEntry "Report saved: $reportFile" "SUCCESS"
        
        # Create manifest for rollback tracking
        $manifest = @{
            RunId = $RunId
            Created = Get-Date -Format "o"
            ReportFile = $reportFile
            LogFile = $logFile
            ManifestFile = $manifestFile
            ApplicationName = $ApplicationName
            DeploymentDate = $deploymentWindowStart
            Status = "Complete"
        }
        
        $manifest | ConvertTo-Json | Out-File -FilePath $manifestFile -Encoding UTF8 -Force
        Write-LogEntry "Manifest saved: $manifestFile" "SUCCESS"
    } catch {
        Write-LogEntry "Failed to save results: $($_.Exception.Message)" "ERROR"
    }
}

function Display-Summary {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  DIAGNOSTIC SUMMARY                                                            ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Application Investigated: $ApplicationName" -ForegroundColor White
    Write-Host "Deployment Window: $(Get-Date $deploymentWindowStart -Format 'yyyy-MM-dd HH:mm') to $(Get-Date $deploymentWindowEnd -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor White
    Write-Host "Lookback Period: $LookbackDays days" -ForegroundColor White
    Write-Host ""
    
    Write-Host "RESULTS:" -ForegroundColor Cyan
    Write-Host "  Checks Performed: $($diagnosticResults.Summary.TotalCheckAttempts)"
    Write-Host "  Checks Passed: $($diagnosticResults.Summary.ChecksPassed)"
    Write-Host "  Checks Failed: $($diagnosticResults.Summary.ChecksFailed)"
    Write-Host "  Checks Skipped: $($diagnosticResults.Summary.ChecksSkipped)"
    Write-Host "  Checks Inconclusive: $($diagnosticResults.Summary.ChecksInconclusive)"
    Write-Host ""
    
    Write-Host "EVIDENCE ANALYSIS:" -ForegroundColor Cyan
    Write-Host "  Supporting Evidence: $($diagnosticResults.Summary.Evidence.Supporting.Count)"
    Write-Host "  Contradicting Evidence: $($diagnosticResults.Summary.Evidence.Contradicting.Count)"
    Write-Host "  Inconclusive Evidence: $($diagnosticResults.Summary.Evidence.Inconclusive.Count)"
    Write-Host ""
    
    $conclusionColor = switch ($diagnosticResults.Summary.OverallConclusion) {
        "Supported" { "Yellow" }
        "Not Supported" { "Green" }
        "Inconclusive" { "Cyan" }
        default { "White" }
    }
    
    Write-Host "OVERALL CONCLUSION:" -ForegroundColor Cyan
    Write-Host "  $($diagnosticResults.Summary.OverallConclusion)" -ForegroundColor $conclusionColor
    Write-Host "  $($diagnosticResults.Summary.ConclusionDetail)" -ForegroundColor White
    Write-Host ""
    
    if (-not $DryRun) {
        Write-Host "OUTPUT FILES:" -ForegroundColor Cyan
        Write-Host "  Report: $reportFile"
        Write-Host "  Log: $logFile"
        Write-Host "  Manifest: $manifestFile"
        Write-Host ""
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Invoke-DiagnosticCollection {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  Enhanced Floor 6 Deployment Diagnostic Script v2.0                            ║" -ForegroundColor Cyan
    Write-Host "║  Safe, Read-Only Application Deployment Investigation                         ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Check for admin privileges
    if (-not (Test-AdminPrivileges)) {
        Write-LogEntry "WARNING: Script should run as Administrator for complete access to logs and services" "WARN"
    }
    
    # Display mode
    if ($DryRun) {
        Write-LogEntry "MODE: DRY-RUN (no data collection or file creation)" "WARN"
        Write-LogEntry "ApplicationName: $ApplicationName" "INFO"
        Write-LogEntry "Script will show what would be checked without actual evidence collection" "INFO"
    } elseif ($Rollback) {
        Write-LogEntry "MODE: ROLLBACK (removing previous diagnostic artifacts)" "WARN"
        return Invoke-RollbackArtifacts
    } else {
        Write-LogEntry "MODE: DIAGNOSTIC COLLECTION" "INFO"
        Write-LogEntry "ApplicationName: $ApplicationName" "INFO"
        Write-LogEntry "DeploymentWindow: $(Get-Date $deploymentWindowStart -Format 'yyyy-MM-dd HH:mm')" "INFO"
        Write-LogEntry "RunId: $RunId" "INFO"
        Write-LogEntry "Output: $OutputPath" "INFO"
    }
    
    Write-Host ""
    
    # Run all diagnostic functions
    Collect-DeviceInfo
    Collect-ApplicationInfo
    Collect-IntuneManagementLogs
    Collect-WindowsEventLogs
    Collect-StartupAndServices
    Collect-PerformanceMetrics
    
    # Analyze and reach conclusion
    if (-not $DryRun) {
        Determine-Conclusion
        Save-DiagnosticResults
    }
    
    # Display summary
    Display-Summary
}

# Execute main function
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Invoke-DiagnosticCollection
$stopwatch.Stop()

Write-Host "Diagnostic execution completed in $($stopwatch.Elapsed.TotalSeconds) seconds" -ForegroundColor Gray
Write-Host ""
