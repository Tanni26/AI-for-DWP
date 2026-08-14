#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Floor 6 Post-Deployment Diagnostic Script
    Investigates login and performance issues following Windows 11 migration and document management app deployment
.DESCRIPTION
    Collects structured evidence from device logs, services, tasks, and performance metrics.
    Designed to help identify if the Friday document management application deployment caused Monday's login/performance issues.
    Operates in read-only mode. Outputs results in JSON for parsing by other tools/engineers.
.PARAMETER DryRun
    If $true, displays what would be checked without collecting data. Useful for validation.
.PARAMETER OutputPath
    Path where JSON output will be saved. Defaults to current directory.
.EXAMPLE
    # Dry-run mode - shows checks without collecting data
    .\finbridge-floor6-deployment-diagnostics.ps1 -DryRun $true

    # Actual collection mode - gathers evidence
    .\finbridge-floor6-deployment-diagnostics.ps1 -OutputPath "C:\Diagnostics"
#>

param(
    [bool]$DryRun = $false,
    [string]$OutputPath = (Get-Location).Path
)

# ============================================================================
# CONFIGURATION
# ============================================================================
$ScriptConfig = @{
    DryRun = $DryRun
    OutputPath = $OutputPath
    Timestamp = (Get-Date -Format "yyyyMMdd_HHmmss")
    DeploymentWindowStart = (Get-Date "2024-01-12 12:00:00")  # Friday afternoon window
    DeploymentWindowEnd = (Get-Date "2024-01-15 06:00:00")    # Before Monday morning reports
}

$Results = @{
    Metadata = @{}
    DeviceInfo = @{}
    InstalledApplications = @{}
    IntuneManagementLogs = @{}
    WindowsEventLogs = @{}
    StartupAndServices = @{}
    PerformanceMetrics = @{}
    Summary = @{}
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

function Write-LogEntry {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

function Add-Result {
    param(
        [string]$Category,
        [string]$CheckName,
        [hashtable]$Evidence,
        [string]$ConfirmsDeploymentCause,
        [string]$RulesOutDeploymentCause,
        [string]$RecommendedAction
    )
    
    $result = @{
        CheckName = $CheckName
        Evidence = $Evidence
        ConfirmsDeploymentCause = $ConfirmsDeploymentCause
        RulesOutDeploymentCause = $RulesOutDeploymentCause
        RecommendedAction = $RecommendedAction
        CollectedAt = (Get-Date -Format "o")
    }
    
    if (-not $Results[$Category]) {
        $Results[$Category] = @()
    }
    
    $Results[$Category] += $result
}

function Test-AdminPrivileges {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ============================================================================
# SECTION 1: DEVICE INFORMATION
# ============================================================================

function Collect-DeviceInfo {
    Write-LogEntry "Collecting device information..." "INFO"
    
    if ($ScriptConfig.DryRun) {
        Write-LogEntry "DRY RUN: Would collect OS version, system specs, last boot time, current user context" "DEBUG"
        return
    }
    
    try {
        # Windows version and build
        $osInfo = Get-CimInstance Win32_OperatingSystem
        $systemInfo = Get-CimInstance Win32_ComputerSystem
        
        $Results.Metadata = @{
            CollectionMethod = "PowerShell CIM/WMI"
            OperatingSystem = $osInfo.Caption
            OSVersion = $osInfo.Version
            OSBuild = $osInfo.BuildNumber
            SerialNumber = (Get-CimInstance Win32_BIOS).SerialNumber
            Manufacturer = $systemInfo.Manufacturer
            Model = $systemInfo.Model
            ComputerName = $env:COMPUTERNAME
            CollectedTime = Get-Date -Format "o"
            ScriptVersion = "1.0"
        }
        
        # Boot information
        $bootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
        $Results.DeviceInfo.BootInfo = @{
            LastBootTime = $bootTime
            BootTimeUTC = $bootTime.ToUniversalTime().ToString("o")
            UptimeDays = [math]::Round((New-TimeSpan -Start $bootTime -End (Get-Date)).TotalDays, 2)
            ConfirmsDeploymentCause = "If device rebooted immediately after Friday deployment (within 30min-2hr window), suggests installation required restart"
            RulesOutDeploymentCause = "If device hasn't rebooted since before Friday deployment, installation didn't trigger restart (may rule out aggressive restart hooks)"
            RecommendedAction = "Cross-reference with Intune deployment logs for restart requirements and timing"
        }
        
        # Current user session
        $sessionInfo = quser 2>$null | Select-Object -Skip 1 | ForEach-Object {
            $parts = $_ -split '\s+' | Where-Object { $_ }
            @{
                Username = $parts[0]
                SessionName = $parts[1]
                SessionID = $parts[2]
                State = $parts[3]
            }
        }
        
        $Results.DeviceInfo.CurrentSessions = @{
            ActiveSessions = $sessionInfo
            LoggedInUsers = @(quser 2>$null | Select-Object -Skip 1 | ForEach-Object { $_ -split '\s+' | Select-Object -First 1 })
            ConfirmsDeploymentCause = "If sessions are hung, disconnected, or looping, suggests Group Policy or profile service issues from deployment"
            RulesOutDeploymentCause = "If clean user sessions with normal state, rules out login-time execution issues"
            RecommendedAction = "If stuck sessions present, check User Profile Service logs and Group Policy application timing"
        }
        
        Write-LogEntry "Device information collected successfully" "SUCCESS"
    }
    catch {
        Write-LogEntry "Error collecting device info: $_" "ERROR"
        $Results.DeviceInfo.Error = $_.Exception.Message
    }
}

# ============================================================================
# SECTION 2: INSTALLED APPLICATIONS AND DEPLOYMENT TIMING
# ============================================================================

function Collect-ApplicationInfo {
    Write-LogEntry "Collecting installed application details..." "INFO"
    
    if ($ScriptConfig.DryRun) {
        Write-LogEntry "DRY RUN: Would scan installed programs, document management apps, query installation dates" "DEBUG"
        return
    }
    
    try {
        # Query installed applications with installation times
        $apps = @()
        
        # 64-bit registry
        $regPath64 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        $apps += Get-ItemProperty $regPath64 -ErrorAction SilentlyContinue | 
            Where-Object { $_.DisplayName } |
            Select-Object -Property @{Name="DisplayName"; Expression={$_.DisplayName}},
                                    @{Name="Version"; Expression={$_.DisplayVersion}},
                                    @{Name="InstallDate"; Expression={$_.InstallDate}},
                                    @{Name="Publisher"; Expression={$_.Publisher}},
                                    @{Name="Architecture"; Expression={"64-bit"}}
        
        # 32-bit registry
        $regPath32 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        $apps += Get-ItemProperty $regPath32 -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName } |
            Select-Object -Property @{Name="DisplayName"; Expression={$_.DisplayName}},
                                    @{Name="Version"; Expression={$_.DisplayVersion}},
                                    @{Name="InstallDate"; Expression={$_.InstallDate}},
                                    @{Name="Publisher"; Expression={$_.Publisher}},
                                    @{Name="Architecture"; Expression={"32-bit"}}
        
        # Filter for document management related apps
        $docMgmtApps = $apps | Where-Object {
            $_.DisplayName -match "(document|doc|management|share|repository|content|record)" -or
            $_.Publisher -match "(document|management|file)"
        }
        
        # Check installation within deployment window
        $recentInstalls = $apps | Where-Object {
            if ($_.InstallDate) {
                try {
                    $installDate = [datetime]::ParseExact($_.InstallDate, "yyyyMMdd", $null)
                    $installDate -ge $ScriptConfig.DeploymentWindowStart -and $installDate -le $ScriptConfig.DeploymentWindowEnd
                } catch {
                    $false
                }
            } else {
                $false
            }
        } | Sort-Object InstallDate -Descending
        
        $Results.InstalledApplications = @{
            DocumentManagementApps = @($docMgmtApps)
            RecentInstallations = @($recentInstalls)
            TotalInstalledApps = $apps.Count
            DocumentManagementAppCount = $docMgmtApps.Count
            RecentInstallCount = $recentInstalls.Count
            ConfirmsDeploymentCause = "Document management app found in recent installs within Friday deployment window; multiple recent installs may indicate dependency chain issues"
            RulesOutDeploymentCause = "No document management app found; no installs during Friday deployment window"
            RecommendedAction = "If document management app present: check Intune deployment logs for pre/post-install scripts and dependencies"
        }
        
        Write-LogEntry "Found $($docMgmtApps.Count) potential document management apps, $($recentInstalls.Count) recent installs" "INFO"
    }
    catch {
        Write-LogEntry "Error collecting application info: $_" "ERROR"
        $Results.InstalledApplications.Error = $_.Exception.Message
    }
}

# ============================================================================
# SECTION 3: INTUNE MANAGEMENT EXTENSION LOGS
# ============================================================================

function Collect-IntuneManagementLogs {
    Write-LogEntry "Collecting Intune Management Extension logs..." "INFO"
    
    if ($ScriptConfig.DryRun) {
        Write-LogEntry "DRY RUN: Would parse IME logs for install failures, retries, detection loops, timeouts" "DEBUG"
        return
    }
    
    try {
        # IME log locations
        $imeLogPaths = @(
            "$env:ProgramFiles\Microsoft Intune Management Extension\Logs\AgentExecutor.log",
            "$env:ProgramFiles\Microsoft Intune Management Extension\Logs\InstallationSummary.log",
            "$env:ProgramFiles\Microsoft Intune Management Extension\Logs\IntuneManagementExtension.log"
        )
        
        $imeLogs = @{}
        
        foreach ($logPath in $imeLogPaths) {
            if (Test-Path $logPath) {
                $logName = Split-Path $logPath -Leaf
                Write-LogEntry "Parsing $logName..." "INFO"
                
                $logContent = @()
                try {
                    $rawContent = Get-Content $logPath -Tail 500 -ErrorAction Stop
                    
                    # Extract error patterns
                    $errors = $rawContent -match "Error|FAILED|Timeout|Exception|Retry|Detection loop"
                    $failures = $rawContent -match "Install failed|Detection failed|Enforcement failed"
                    $retries = $rawContent -match "Retry|retrying|attempt"
                    $restarts = $rawContent -match "restart|reboot|Restart"
                    
                    $imeLogs[$logName] = @{
                        FileExists = $true
                        LastModified = (Get-Item $logPath).LastWriteTime
                        FileSizeKB = [math]::Round((Get-Item $logPath).Length / 1KB, 2)
                        ErrorLinesCount = @($errors).Count
                        FailureIndicators = @($failures).Count
                        RetryIndicators = @($retries).Count
                        RestartIndicators = @($restarts).Count
                        RecentLines = @($rawContent | Select-Object -Last 20)
                        ConfirmsDeploymentCause = "Errors/failures/detection loops in install logs strongly indicate deployment issue"
                        RulesOutDeploymentCause = "Clean logs with successful completion and no errors suggest deployment succeeded"
                        RecommendedAction = "Review full log for error patterns; contact application vendor if detection loops present"
                    }
                } catch {
                    $imeLogs[$logName] = @{
                        FileExists = $true
                        Error = $_.Exception.Message
                    }
                }
            } else {
                $imeLogs[(Split-Path $logPath -Leaf)] = @{
                    FileExists = $false
                    Message = "Log file not found"
                }
            }
        }
        
        $Results.IntuneManagementLogs = $imeLogs
        Write-LogEntry "Intune logs collected" "SUCCESS"
    }
    catch {
        Write-LogEntry "Error collecting Intune logs: $_" "ERROR"
        $Results.IntuneManagementLogs.Error = $_.Exception.Message
    }
}

# ============================================================================
# SECTION 4: WINDOWS EVENT LOGS
# ============================================================================

function Collect-WindowsEventLogs {
    Write-LogEntry "Collecting Windows Event Logs..." "INFO"
    
    if ($ScriptConfig.DryRun) {
        Write-LogEntry "DRY RUN: Would query Application, System, Security logs for errors near deployment time" "DEBUG"
        return
    }
    
    try {
        $eventLogs = @{}
        
        # Define log queries: log name, relevant event IDs, and what they indicate
        $logQueries = @(
            @{
                LogName = "System"
                EventIDs = @(1000, 1001, 1102)  # General system errors, power issues
                Description = "System critical errors"
            },
            @{
                LogName = "Application"
                EventIDs = @(1000, 1002)  # Application crashes, errors
                Description = "Application errors"
            },
            @{
                LogName = "Microsoft-Windows-User Profile Service/Operational"
                EventIDs = @(1, 4, 6)  # Profile service errors
                Description = "User profile service issues"
            },
            @{
                LogName = "Microsoft-Windows-Winlogon/Operational"
                EventIDs = @()  # All events - filter by level
                Description = "Logon/logoff events"
            },
            @{
                LogName = "Microsoft-Windows-GroupPolicy/Operational"
                EventIDs = @(1094, 1097, 1098)  # GPO application errors
                Description = "Group Policy failures"
            },
            @{
                LogName = "Microsoft-Windows-Kernel-General/Operational"
                EventIDs = @()
                Description = "Kernel events"
            }
        )
        
        # Collect events from 48 hours ago (covers Friday deployment + Monday morning)
        $startTime = (Get-Date).AddHours(-48)
        
        foreach ($query in $logQueries) {
            $logName = $query.LogName
            Write-LogEntry "Querying $logName..." "INFO"
            
            try {
                $filterParams = @{
                    LogName = $logName
                    StartTime = $startTime
                }
                
                if ($query.EventIDs -and $query.EventIDs.Count -gt 0) {
                    $filterParams.ID = $query.EventIDs
                }
                
                # Try to get error level events first
                $events = Get-WinEvent -FilterHashtable $filterParams -ErrorAction SilentlyContinue -MaxEvents 100 |
                    Where-Object { $_.LevelDisplayName -in @("Error", "Critical") }
                
                $eventLogs[$logName] = @{
                    Description = $query.Description
                    ErrorEventCount = $events.Count
                    TimeRange = "Last 48 hours from $startTime"
                    Events = @($events | Select-Object -First 20 | ForEach-Object {
                        @{
                            TimeCreated = $_.TimeCreated
                            LevelDisplayName = $_.LevelDisplayName
                            Id = $_.Id
                            ProviderName = $_.ProviderName
                            Message = $_.Message.Substring(0, [math]::Min(200, $_.Message.Length))
                        }
                    })
                    ConfirmsDeploymentCause = "High error count in profile service or GPO logs near deployment time indicates installation impacted login pipeline"
                    RulesOutDeploymentCause = "Few/no errors in these logs during deployment window suggests issue unrelated to app installation"
                    RecommendedAction = "Review detailed event messages; correlate timestamps with Intune deployment logs"
                }
            } catch {
                $eventLogs[$logName] = @{
                    Description = $query.Description
                    Error = "Log may not exist on this system or access denied"
                    ErrorDetail = $_.Exception.Message
                }
            }
        }
        
        $Results.WindowsEventLogs = $eventLogs
        Write-LogEntry "Event logs collected" "SUCCESS"
    }
    catch {
        Write-LogEntry "Error collecting Event logs: $_" "ERROR"
        $Results.WindowsEventLogs.Error = $_.Exception.Message
    }
}

# ============================================================================
# SECTION 5: STARTUP ITEMS, SCHEDULED TASKS, AND SERVICES
# ============================================================================

function Collect-StartupAndServices {
    Write-LogEntry "Collecting startup items, scheduled tasks, and services..." "INFO"
    
    if ($ScriptConfig.DryRun) {
        Write-LogEntry "DRY RUN: Would enumerate startup tasks, services, scheduled jobs added after Friday" "DEBUG"
        return
    }
    
    try {
        $startup = @{}
        
        # Get startup programs (Run registry keys)
        Write-LogEntry "Checking startup registry keys..." "INFO"
        $startupRegPaths = @(
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        )
        
        $startupItems = @()
        foreach ($regPath in $startupRegPaths) {
            if (Test-Path $regPath) {
                $startupItems += Get-ItemProperty $regPath -ErrorAction SilentlyContinue |
                    Select-Object -Property @{Name="Path"; Expression={$regPath}},
                                            @{Name="Name"; Expression={$_.PSChildName}},
                                            @{Name="Value"; Expression={$_}} |
                    Where-Object { $_.Value -and $_.Name -ne "PSPath" -and $_.Name -ne "PSProvider" }
            }
        }
        
        $startup.StartupRegistryItems = @{
            Count = $startupItems.Count
            Items = @($startupItems | Select-Object -First 50)
            ConfirmsDeploymentCause = "New startup entries from document management app may run at login, causing delays or failures"
            RulesOutDeploymentCause = "No new startup entries suggests app doesn't hook into login process"
            RecommendedAction = "Identify any unknown startup items; check if associated with document management app"
        }
        
        # Get scheduled tasks created recently
        Write-LogEntry "Checking scheduled tasks..." "INFO"
        $allTasks = Get-ScheduledTask -ErrorAction SilentlyContinue
        $recentTasks = $allTasks | Where-Object {
            # Note: ScheduledTask objects don't expose direct creation time, but we can check state changes
            try {
                $taskInfo = Get-ScheduledTaskInfo -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue
                $taskInfo.LastRunTime -ge $ScriptConfig.DeploymentWindowStart
            } catch {
                $false
            }
        }
        
        $startup.ScheduledTasks = @{
            TotalTasks = $allTasks.Count
            RecentlyRunTasks = $recentTasks.Count
            RecentTasksSample = @($recentTasks | Select-Object -First 20 | ForEach-Object {
                @{
                    TaskName = $_.TaskName
                    TaskPath = $_.TaskPath
                    Enabled = $_.Enabled
                    State = $_.State
                }
            })
            ConfirmsDeploymentCause = "Document management app with scheduled tasks running at login may delay user session initialization"
            RulesOutDeploymentCause = "No new tasks or tasks not executing during login window"
            RecommendedAction = "Review newly created/enabled tasks; check if tied to document management app"
        }
        
        # Get services created/modified recently
        Write-LogEntry "Checking services..." "INFO"
        $allServices = Get-Service -ErrorAction SilentlyContinue
        $startTypeSettings = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\*" -ErrorAction SilentlyContinue |
            Select-Object -Property PSChildName, Start
        
        # Services that start on boot (likely to impact login)
        $autoStartServices = $allServices | Where-Object { $_.StartType -eq "Automatic" }
        
        $startup.Services = @{
            TotalServices = $allServices.Count
            AutoStartServices = $autoStartServices.Count
            AutoStartSample = @($autoStartServices | Select-Object -First 20 | ForEach-Object {
                @{
                    Name = $_.Name
                    DisplayName = $_.DisplayName
                    Status = $_.Status
                    StartType = $_.StartType
                }
            })
            ConfirmsDeploymentCause = "Auto-start services from document management app may block boot/login if they hang or loop"
            RulesOutDeploymentCause = "No new services or services in normal state and not triggering delays"
            RecommendedAction = "Search auto-start services for document management app components; check service logs"
        }
        
        $Results.StartupAndServices = $startup
        Write-LogEntry "Startup and services collected" "SUCCESS"
    }
    catch {
        Write-LogEntry "Error collecting startup/services: $_" "ERROR"
        $Results.StartupAndServices.Error = $_.Exception.Message
    }
}

# ============================================================================
# SECTION 6: PERFORMANCE METRICS
# ============================================================================

function Collect-PerformanceMetrics {
    Write-LogEntry "Collecting performance metrics..." "INFO"
    
    if ($ScriptConfig.DryRun) {
        Write-LogEntry "DRY RUN: Would capture CPU, memory, disk, top processes" "DEBUG"
        return
    }
    
    try {
        $perf = @{}
        
        # CPU usage
        Write-LogEntry "Capturing CPU metrics..." "INFO"
        $cpuMetrics = Get-CimInstance Win32_Processor | Select-Object -First 1
        $perf.CPU = @{
            Cores = $cpuMetrics.NumberOfCores
            LogicalProcessors = $cpuMetrics.NumberOfLogicalProcessors
            Name = $cpuMetrics.Name
            MaxClockSpeed = $cpuMetrics.MaxClockSpeed
            LoadPercentage = $cpuMetrics.LoadPercentage
            ConfirmsDeploymentCause = "High sustained CPU usage (>80%) may indicate background install/scan processes"
            RulesOutDeploymentCause = "Low CPU usage suggests no intensive background processes"
            RecommendedAction = "If high, identify top processes; check if related to document management app"
        }
        
        # Memory usage
        Write-LogEntry "Capturing memory metrics..." "INFO"
        $osInfo = Get-CimInstance Win32_OperatingSystem
        $totalMemMB = [math]::Round($osInfo.TotalVisibleMemorySize / 1KB, 2)
        $freeMemMB = [math]::Round($osInfo.FreePhysicalMemory / 1KB, 2)
        $usedMemMB = $totalMemMB - $freeMemMB
        
        $perf.Memory = @{
            TotalMemoryMB = $totalMemMB
            UsedMemoryMB = $usedMemMB
            FreeMemoryMB = $freeMemMB
            UsagePercent = [math]::Round(($usedMemMB / $totalMemMB) * 100, 2)
            ConfirmsDeploymentCause = "Memory pressure >85% combined with many hung processes suggests app consuming resources"
            RulesOutDeploymentCause = "Healthy memory usage (<60%) suggests no resource exhaustion issue"
            RecommendedAction = "If high, identify processes using most memory"
        }
        
        # Disk space
        Write-LogEntry "Capturing disk metrics..." "INFO"
        $diskMetrics = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object -First 1
        $diskSizeGB = [math]::Round($diskMetrics.Size / 1GB, 2)
        $diskFreeGB = [math]::Round($diskMetrics.FreeSpace / 1GB, 2)
        $diskUsedGB = $diskSizeGB - $diskFreeGB
        
        $perf.Disk = @{
            DriveLetter = $diskMetrics.DeviceID
            TotalSizeGB = $diskSizeGB
            UsedGB = $diskUsedGB
            FreeGB = $diskFreeGB
            UsagePercent = [math]::Round(($diskUsedGB / $diskSizeGB) * 100, 2)
            ConfirmsDeploymentCause = "Document management app may consume significant disk; low disk space impacts login performance"
            RulesOutDeploymentCause = "Healthy disk space (>20% free) rules out storage exhaustion"
            RecommendedAction = "If low on space, check for large log files or app cache directories"
        }
        
        # Top processes by CPU and memory
        Write-LogEntry "Capturing top processes..." "INFO"
        $topCPUProcesses = Get-Process -ErrorAction SilentlyContinue | 
            Sort-Object CPU -Descending |
            Select-Object -First 10 | 
            ForEach-Object {
                @{
                    ProcessName = $_.ProcessName
                    CPU = [math]::Round($_.CPU, 2)
                    MemoryMB = [math]::Round($_.WorkingSet / 1MB, 2)
                    Id = $_.Id
                }
            }
        
        $perf.TopProcessesByCPU = @{
            Processes = $topCPUProcesses
            ConfirmsDeploymentCause = "Document management app or related process in top 3 suggests it's consuming resources"
            RulesOutDeploymentCause = "No document-related process in top processes"
            RecommendedAction = "Research unfamiliar processes; check if tied to deployment"
        }
        
        $Results.PerformanceMetrics = $perf
        Write-LogEntry "Performance metrics collected" "SUCCESS"
    }
    catch {
        Write-LogEntry "Error collecting performance metrics: $_" "ERROR"
        $Results.PerformanceMetrics.Error = $_.Exception.Message
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Invoke-Diagnostics {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗"
    Write-Host "║  Floor 6 Post-Deployment Diagnostic Script                                     ║"
    Write-Host "║  Investigation: Login/Performance Issue After Friday App Deployment             ║"
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝"
    Write-Host ""
    
    # Validate prerequisites
    if (-not (Test-AdminPrivileges)) {
        Write-LogEntry "ERROR: Script must run as Administrator" "ERROR"
        exit 1
    }
    
    if ($ScriptConfig.DryRun) {
        Write-LogEntry "========== DRY-RUN MODE ==========" "WARNING"
        Write-LogEntry "Script will display checks without collecting actual data" "INFO"
        Write-LogEntry "Use DryRun=\$false parameter to collect actual evidence" "INFO"
    } else {
        Write-LogEntry "========== DATA COLLECTION MODE ==========" "INFO"
        Write-LogEntry "Collecting actual device evidence" "INFO"
        Write-LogEntry "Output will be saved to: $($ScriptConfig.OutputPath)" "INFO"
    }
    
    Write-LogEntry "Start time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "INFO"
    Write-Host ""
    
    # Run all collection functions
    Collect-DeviceInfo
    Collect-ApplicationInfo
    Collect-IntuneManagementLogs
    Collect-WindowsEventLogs
    Collect-StartupAndServices
    Collect-PerformanceMetrics
    
    # Create summary
    $Results.Summary = @{
        TotalChecksPerformed = 6
        ExecutionMode = if ($ScriptConfig.DryRun) { "DRY-RUN" } else { "ACTUAL-COLLECTION" }
        DeploymentWindowChecked = @{
            Start = $ScriptConfig.DeploymentWindowStart
            End = $ScriptConfig.DeploymentWindowEnd
        }
        KeyIndicators = @{
            DocumentManagementAppFound = $Results.InstalledApplications.DocumentManagementAppCount -gt 0
            RecentInstallsDetected = $Results.InstalledApplications.RecentInstallCount -gt 0
            IMEErrorsDetected = if ($Results.IntuneManagementLogs.PSObject.Properties) { $true } else { $false }
            SystemErrorsInLogs = if ($Results.WindowsEventLogs.PSObject.Properties) { $true } else { $false }
            HighMemoryUsage = if ($Results.PerformanceMetrics.Memory) { $Results.PerformanceMetrics.Memory.UsagePercent -gt 85 } else { $false }
            LowDiskSpace = if ($Results.PerformanceMetrics.Disk) { $Results.PerformanceMetrics.Disk.UsagePercent -gt 90 } else { $false }
        }
        AnalysisGuidance = @(
            "1. If DocumentManagementAppFound=true AND RecentInstallsDetected=true: Deployment timing aligns with issue window",
            "2. If IMEErrorsDetected=true OR SystemErrorsInLogs=true during deployment window: Application may have failed or caused conflicts",
            "3. If HighMemoryUsage=true OR LowDiskSpace=true: Resource constraints may be delaying login",
            "4. Cross-reference boot time with deployment window - if reboot occurred during install, deployment triggered restart",
            "5. Review Event logs for Group Policy or User Profile Service errors - suggest app interfered with login pipeline"
        )
        NextSteps = @(
            "Review this JSON output for specific error signatures",
            "Correlate timestamps across all logs",
            "If deployment suspected: Check Intune console for app install logs and detection results",
            "If performance suspected: Monitor device for 1 hour during typical login time; capture second baseline",
            "If Group Policy errors: Run 'gpresult /h report.html' on affected device for policy application diagnostic",
            "Contact application vendor with IME logs if installation failures or detection loops found"
        )
    }
    
    # Save results to JSON
    if (-not $ScriptConfig.DryRun) {
        $outputFile = Join-Path $ScriptConfig.OutputPath "Floor6_Diagnostics_$($ScriptConfig.Timestamp).json"
        
        Write-LogEntry "Saving results to JSON..." "INFO"
        try {
            $Results | ConvertTo-Json -Depth 5 | Out-File $outputFile -Encoding UTF8 -ErrorAction Stop
            Write-LogEntry "Results saved to: $outputFile" "SUCCESS"
        } catch {
            Write-LogEntry "Error saving JSON: $_" "ERROR"
        }
    }
    
    Write-Host ""
    Write-LogEntry "Diagnostics complete at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "SUCCESS"
    Write-Host ""
    
    # Display summary
    Write-Host "SUMMARY OF KEY INDICATORS:"
    Write-Host "─────────────────────────────────────────"
    $Results.Summary.KeyIndicators.GetEnumerator() | ForEach-Object {
        $status = if ($_.Value) { "⚠ YES" } else { "✓ NO" }
        Write-Host "$status - $($_.Key)"
    }
    Write-Host ""
    
    # Return results as object for piping
    return $Results
}

# ============================================================================
# EXECUTION
# ============================================================================

$Results = Invoke-Diagnostics

# For further processing, output results
$Results
