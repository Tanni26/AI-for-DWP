# Floor 6 Deployment Diagnostics - Quick Start Guide

## Overview
This PowerShell script investigates whether the Friday document management application deployment caused Monday's login and performance issues on Floor 6 Legal machines.

**Mode of Operation:** Read-only diagnostic collection. The script does not modify, fix, or remove anything.

---

## Requirements
- Windows 11 (matching Floor 6 post-migration environment)
- PowerShell 5.1 or later
- Administrator privileges (required for event log and service queries)
- ~2-3 minutes execution time

---

## Quick Start

### DRY-RUN MODE (Recommended First Step)
Validates the script and shows what will be checked **without collecting data**:

```powershell
# Open PowerShell as Administrator, then:
cd C:\path\to\script
.\finbridge-floor6-deployment-diagnostics.ps1 -DryRun $true
```

**Output:** Console display showing each collection section and what data would be gathered. No files created.

**When to use:** Before running on production devices to verify the script runs without errors and understand what it checks.

---

### ACTUAL COLLECTION MODE
Gathers full diagnostic evidence and outputs to JSON:

```powershell
# Open PowerShell as Administrator, then:
cd C:\path\to\script

# Option 1: Save to current directory (default)
.\finbridge-floor6-deployment-diagnostics.ps1

# Option 2: Specify custom output directory
.\finbridge-floor6-deployment-diagnostics.ps1 -OutputPath "C:\Diagnostics"
```

**Output:** Structured JSON file named `Floor6_Diagnostics_YYYYMMDD_HHMMSS.json` containing:
- Device metadata (OS, build, uptime)
- Installed applications (document management apps, recent installs)
- Intune Management Extension logs (install failures, retries, detection issues)
- Windows Event Logs (errors in System, Application, User Profile Service, Group Policy)
- Startup items and services (auto-start entries added by deployment)
- Performance metrics (CPU, memory, disk, top processes)

**When to use:** On affected Floor 6 machines during or shortly after they report issues.

---

## How to Interpret Results

### Strong Indicators Deployment Caused Issue
✓ Document management app found in recent installs (Friday window)  
✓ Intune logs show install failures, retries, or "detection loops"  
✓ Event logs show User Profile Service or Group Policy errors during deployment window  
✓ Device rebooted immediately after Friday deployment (uptime ~48-72 hrs on Monday)  
✓ High CPU/Memory during login hours  
✓ Document-related service or scheduled task in "top processes"

### Indicators Deployment Unlikely the Cause
✓ No document management app installed during Friday window  
✓ Clean Intune logs (successful install, no errors)  
✓ No correlating errors in Event logs during deployment window  
✓ Device not rebooted since before Friday  
✓ Normal resource utilization  
✓ No startup or scheduled task changes from deployment

---

## Output JSON Structure

```json
{
  "Metadata": {
    "OperatingSystem": "Windows 11",
    "OSBuild": "22621",
    "ComputerName": "FL6-USER01",
    "CollectedTime": "2024-01-15T10:23:45Z"
  },
  "DeviceInfo": {
    "BootInfo": {
      "LastBootTime": "2024-01-12T16:45:00Z",
      "UptimeDays": 2.75,
      "ConfirmsDeploymentCause": "...",
      "RulesOutDeploymentCause": "...",
      "RecommendedAction": "..."
    },
    "CurrentSessions": {...}
  },
  "InstalledApplications": {
    "DocumentManagementApps": [...],
    "RecentInstallations": [...],
    "ConfirmsDeploymentCause": "...",
    "RulesOutDeploymentCause": "...",
    "RecommendedAction": "..."
  },
  "IntuneManagementLogs": {
    "AgentExecutor.log": {
      "ErrorLinesCount": 12,
      "FailureIndicators": 3,
      "RetryIndicators": 5,
      "RecentLines": [...]
    }
  },
  "WindowsEventLogs": {
    "System": { "ErrorEventCount": 8, "Events": [...] },
    "Application": { "ErrorEventCount": 2, "Events": [...] },
    "Microsoft-Windows-User Profile Service/Operational": { ... }
  },
  "StartupAndServices": {
    "StartupRegistryItems": { "Count": 5, "Items": [...] },
    "ScheduledTasks": { "TotalTasks": 127, "RecentlyRunTasks": 3 },
    "Services": { "TotalServices": 301, "AutoStartServices": 45 }
  },
  "PerformanceMetrics": {
    "CPU": { "Cores": 8, "LoadPercentage": 15 },
    "Memory": { "TotalMemoryMB": 16384, "UsagePercent": 72 },
    "Disk": { "TotalSizeGB": 512, "UsagePercent": 68 },
    "TopProcessesByCPU": [...]
  },
  "Summary": {
    "KeyIndicators": {
      "DocumentManagementAppFound": true,
      "RecentInstallsDetected": true,
      "IMEErrorsDetected": false,
      "SystemErrorsInLogs": true,
      "HighMemoryUsage": false,
      "LowDiskSpace": false
    },
    "AnalysisGuidance": [...],
    "NextSteps": [...]
  }
}
```

---

## Recommended Workflow

### For L1/L2 Service Desk (Triage)
1. **On affected device:** Run script in **ACTUAL mode**
2. **Review JSON:** Look at `Summary.KeyIndicators` section
3. **Assess confidence:**
   - High confidence (deployment caused issue): 4+ indicators true
   - Medium confidence: 2-3 indicators true
   - Low confidence: 0-1 indicators true
4. **Document findings:** Screenshot or export JSON for ticket
5. **Escalate if needed:** Forward JSON to Infrastructure Engineering with context

### For Engineering (Deep Dive)
1. **Parse JSON output** from L1/L2 triage
2. **Cross-reference timestamps:**
   - Correlate Intune install logs with Event log errors
   - Match device boot time with deployment window
3. **Root cause analysis:**
   - If install failures: Contact application vendor with IME logs
   - If Group Policy errors: Run `gpresult /h report.html` for full policy trace
   - If performance: Compare baseline metrics to normal device; identify resource consumer
4. **Mitigation:**
   - Redeploy app if installation failed
   - Adjust Group Policy if conflicts detected
   - Allocate resources or adjust app configuration if performance issue

---

## Data Privacy & Safety

**What the script collects:**
- OS and hardware info
- Installed software names/versions
- Log file entries (up to 500 lines)
- Service/task names
- Performance metrics (CPU%, memory%, disk%)
- Process names (top 20)

**What the script DOES NOT collect:**
- Passwords or credentials
- User personal data (email, documents, files)
- Client matter/legal content
- Network traffic or communications
- Full event log contents (only error entries)

**Safe to run on:**
- Production Floor 6 devices during business hours
- Legal department machines (collects no case files or sensitive data)
- Remote or VPN-connected devices

---

## Troubleshooting

### Script fails with "Administrator privileges required"
**Solution:** Right-click PowerShell, select "Run as Administrator", then run script.

### Script timeout or hangs
**Solution:** Press `Ctrl+C` to stop. Likely cause: event log queries on slow storage. This is normal on older hardware.

### JSON file not created
**Possible causes:**
- Output directory doesn't exist (script creates it if missing in most cases)
- Disk space issue
- Permission issue on output directory

**Solution:** Specify explicit output path:
```powershell
.\finbridge-floor6-deployment-diagnostics.ps1 -OutputPath "C:\Windows\Temp"
```

### Some event log sections return "Log may not exist"
This is normal on systems without specific log providers enabled (e.g., Winlogon/Operational may be disabled). Script gracefully handles this and continues collection.

---

## Escalation Triggers

**Escalate to Infrastructure Engineering immediately if:**
- Document management app found with install failures in Intune logs
- User Profile Service errors correlating with deployment window
- Multiple detection loops or retry cycles in Intune logs
- Sustained high CPU/memory (>90%) preventing normal user sessions
- Device in boot loop or unable to complete logon

---

## Questions?

For script issues or output interpretation questions, contact your Infrastructure Engineering team with:
1. The JSON output file
2. The device name and floor information
3. When the issue was first reported
4. Number of affected users/devices
