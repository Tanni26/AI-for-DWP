# Floor 6 Enhanced Deployment Diagnostic Script v2.0

## Overview

This enhanced version of the Floor 6 deployment diagnostic script provides safe, read-only investigation of login and performance issues following Windows 11 migration and application deployment. It collects structured evidence without modifying the endpoint, services, applications, or system configuration.

**Key Improvements Over v1.0:**
- Required `-ApplicationName` parameter to focus investigation on specific deployments
- Configurable `-DeploymentDate` and `-LookbackDays` parameters for flexible time windows
- Unique `-RunId` tracking for idempotency and audit trail
- Enhanced `-DryRun` mode showing all data sources without collection
- Safe `-Rollback` option to remove only script artifacts (not system changes)
- Improved JSON output structure with Supporting/Contradicting/Inconclusive evidence categorization
- Better error handling with individual try/catch per diagnostic section
- Performance optimizations for large log files and event queries
- Clearer conclusion logic: "Supported", "Not Supported", or "Inconclusive"
- Comprehensive inline comments for L1/L2 engineers

---

## System Requirements

- **Windows:** Windows 10/11 with PowerShell 5.1
- **Permissions:** Administrator privileges (strongly recommended for complete log access)
- **Network:** None required (local device only)
- **Disk Space:** ~10 MB for output files

---

## Parameters

### Required Parameters (for Normal Mode)

#### `-ApplicationName` 
Specifies the name or pattern of the target application being investigated. Used to search installed programs and correlate with deployment evidence.

**Type:** String  
**Required:** Yes (unless `-DryRun` or `-Rollback` is set)  
**Examples:**
- `"ShareFile"`
- `"Document Manager"`
- `"content repository"`

---

### Optional Parameters

#### `-DeploymentDate`
The date the application was deployed. Used to establish the investigation window.

**Type:** String  
**Format:** 
- Absolute: `"2024-01-12"` (YYYY-MM-DD format)
- Relative: `"-5"` (number of days ago)

**Default:** 7 days ago (covers Friday deployment scenario)  
**Example:** `-DeploymentDate "2024-01-12"`

#### `-LookbackDays`
Number of days to examine in event logs and system state.

**Type:** Integer  
**Range:** 1-30  
**Default:** 3 (Friday deployment + weekend + Monday morning)  
**Example:** `-LookbackDays 3`

#### `-DryRun`
Display all checks and data sources without collecting evidence or creating files. Useful for validating configuration and permissions before actual collection.

**Type:** Boolean  
**Default:** `$false`  
**Example:** `-DryRun $true`  
**Note:** Cannot be combined with `-Rollback`

#### `-Rollback`
Remove diagnostic artifacts (reports, logs, manifests) from a previous run. Does NOT reverse application deployments or system changes.

**Type:** Boolean  
**Default:** `$false`  
**Example:** `-Rollback $true -RunId "20240115-102345"`  
**Note:** Requires `-RunId` parameter; cannot be combined with `-DryRun`

#### `-RunId`
Unique identifier for the diagnostic run. Used for tracking, deduplication, and rollback.

**Type:** String  
**Format:** Alphanumeric string without spaces or special characters (e.g., "20240115-102345")  
**Default:** Auto-generated as `yyyyMMdd-HHmmss`  
**Example:** `-RunId "Floor6-ShareFile-20240115-102345"`  
**Note:** Required when using `-Rollback`

#### `-OutputPath`
Directory where diagnostic reports, logs, and manifests will be saved.

**Type:** String  
**Default:** `$env:ProgramData\DWP-Diagnostics` (typically `C:\ProgramData\DWP-Diagnostics`)  
**Example:** `-OutputPath "C:\Temp\Diagnostics"`  
**Note:** Directory is created if it doesn't exist

#### `-Force`
When used with `-Rollback`, removes artifacts without confirmation prompts.

**Type:** Boolean  
**Default:** `$false`  
**Example:** `-Rollback $true -Force $true`

---

## Usage Examples

### Example 1: Dry-Run Validation
**Scenario:** Validate the script and understand what it will check before collecting data.

```powershell
# Open PowerShell as Administrator, then:
cd C:\Users\labuser\Documents\Training\PROJECT

.\finbridge-floor6-deployment-diagnostics-enhanced.ps1 `
    -DryRun $true `
    -ApplicationName "ShareFile"
```

**Output:** Console display showing all diagnostic checks that would be performed, without collecting evidence or creating files.

---

### Example 2: Actual Diagnostic Collection
**Scenario:** Investigate a real deployment issue after Friday application rollout.

```powershell
# Collect diagnostics for specific application deployed on known date
.\finbridge-floor6-deployment-diagnostics-enhanced.ps1 `
    -ApplicationName "ShareFile" `
    -DeploymentDate "2024-01-12" `
    -LookbackDays 3 `
    -OutputPath "C:\Diagnostics"
```

**Output:**
- `Floor6_Diagnostics_20240115-102345.json` - Main diagnostic report
- `Floor6_Log_20240115-102345.txt` - Timestamped event log
- `Floor6_Manifest_20240115-102345.json` - Run metadata for rollback

---

### Example 3: Multiple Devices Investigation
**Scenario:** Collect diagnostics from multiple affected devices and aggregate results.

```powershell
# On each affected device, run:
.\finbridge-floor6-deployment-diagnostics-enhanced.ps1 `
    -ApplicationName "ShareFile" `
    -DeploymentDate "2024-01-12" `
    -OutputPath "\\fileserver\Diagnostics\Floor6"

# Later, use a central script to parse all JSON reports
Get-ChildItem "\\fileserver\Diagnostics\Floor6\Floor6_Diagnostics_*.json" | 
    ForEach-Object { Get-Content $_ | ConvertFrom-Json } | 
    Select-Object RunMetadata, Summary
```

---

### Example 4: Rollback (Clean Up Previous Artifacts)
**Scenario:** Remove diagnostic files from a previous run.

```powershell
# Remove artifacts from the run with RunId "20240115-102345"
.\finbridge-floor6-deployment-diagnostics-enhanced.ps1 `
    -Rollback $true `
    -RunId "20240115-102345" `
    -Force $true
```

**Output:** Console summary showing number of artifacts removed.

**Important:** Rollback only removes diagnostic reports and logs created by the script. It does NOT:
- Uninstall applications
- Restore service configurations
- Undo registry changes
- Reverse any system modifications
- Remove application deployment manifests

---

### Example 5: Relative Date Specification
**Scenario:** Use relative dates (e.g., "5 days ago") instead of absolute dates.

```powershell
# Investigate deployment that occurred 5 days before today
.\finbridge-floor6-deployment-diagnostics-enhanced.ps1 `
    -ApplicationName "Document Manager" `
    -DeploymentDate "-5" `
    -LookbackDays 3
```

---

## Output Structure

All diagnostic results are saved in structured JSON format for programmatic parsing and analysis.

### Main Report: `Floor6_Diagnostics_<RunId>.json`

```json
{
  "RunMetadata": {
    "RunId": "20240115-102345",
    "Timestamp": "2024-01-15T10:23:45Z",
    "ComputerName": "FL6-USER01",
    "ApplicationName": "ShareFile",
    "DeploymentWindowStart": "2024-01-12T12:00:00Z",
    "DeploymentWindowEnd": "2024-01-12T20:00:00Z",
    "LookbackDays": 3
  },
  "Diagnostics": {
    "Device-Info": {
      "CheckName": "Device-Info",
      "Status": "Success",
      "Evidence": {
        "ComputerName": "FL6-USER01",
        "OSCaption": "Microsoft Windows 11 Enterprise",
        "OSBuild": "22621",
        "LastBootTime": "2024-01-12T16:45:00Z",
        "UptimeDays": 2.75,
        "BootedDuringDeploymentWindow": true
      },
      "SupportingEvidence": "Device rebooted during/immediately after deployment window",
      "ConfirmsCause": "Device rebooted shortly after Friday deployment suggests installation triggered restart",
      "RuleOutCause": "Device uptime significantly exceeds deployment window; no restart from installation likely",
      "RecommendedAction": "Cross-reference boot time with Intune deployment logs for restart requirements"
    },
    "Application-Inventory": { ... },
    "Intune-Management-Extension": { ... },
    "Windows-Event-Logs": { ... },
    "Startup-Services-Tasks": { ... },
    "Performance-Metrics": { ... }
  },
  "Summary": {
    "TotalCheckAttempts": 6,
    "ChecksPassed": 5,
    "ChecksFailed": 0,
    "ChecksSkipped": 0,
    "ChecksInconclusive": 1,
    "Evidence": {
      "Supporting": ["Device-Info", "Application-Inventory"],
      "Contradicting": [],
      "Inconclusive": ["Intune-Management-Extension"]
    },
    "OverallConclusion": "Supported",
    "ConclusionDetail": "Multiple independent evidence points support the deployment as the likely cause",
    "NextSteps": [...]
  }
}
```

### Check Status Codes

Each diagnostic check returns one of these status codes:

| Status | Meaning | Interpretation |
|--------|---------|-----------------|
| **Success** | Check completed and collected evidence | Review evidence; not necessarily confirmation |
| **Failed** | Check completed but found no evidence of target app | May contradict deployment as cause |
| **Skipped** | Check was intentionally skipped | Normal for optional checks |
| **AccessDenied** | Access to data source denied (permissions) | Escalate with proper admin privileges |
| **Inconclusive** | Check could not determine status (missing data) | Do NOT assume this rules out cause |

### Evidence Categories

Each diagnostic result includes evidence categorized as:

- **Supporting Evidence:** Directly supports deployment as the cause
- **Contradicting Evidence:** Suggests deployment was NOT the cause
- **Inconclusive Evidence:** Neither supports nor contradicts (missing or ambiguous data)

---

## Diagnostic Checks Explained

### 1. Device-Info (Device and Boot Information)
Collects OS version, build, boot time, and uptime. A device that rebooted during the deployment window (Friday afternoon + 2 hours) suggests the installation triggered a restart.

**Confirms Cause If:** Device rebooted immediately after Friday deployment  
**Rules Out If:** Device hasn't rebooted since before deployment window

---

### 2. Application-Inventory (Installed Applications)
Scans registry for installed applications and filters for the target application. Checks if applications were installed within the deployment window.

**Confirms Cause If:** Target application installed during Friday afternoon window; multiple dependencies installed simultaneously  
**Rules Out If:** Target application not installed; no recent installs matching deployment timing

---

### 3. Intune-Management-Extension (IME Logs)
Parses Intune Management Extension logs for installation errors, detection loops, retries, timeouts, and failures.

**Confirms Cause If:** IME logs show install failures, repeated retries, or detection loops  
**Rules Out If:** Clean IME logs with successful completion, no errors

---

### 4. Windows-Event-Logs (System and Application Logs)
Examines System, Application, User Profile Service, Group Policy, and Winlogon event logs for errors during the lookback period. High error counts near deployment suggest app installation impacted login.

**Confirms Cause If:** User Profile Service or Group Policy errors during/after deployment window  
**Rules Out If:** Minimal errors in event logs; no correlation with deployment time

---

### 5. Startup-Services-Tasks (Startup Configuration)
Enumerates startup registry entries, auto-start services, and scheduled tasks. New entries from the deployed application could delay login or cause hangs.

**Confirms Cause If:** New startup entries or auto-start services from deployed app; services hanging or looping  
**Rules Out If:** No new startup entries; no services related to deployed app

---

### 6. Performance-Metrics (System Performance)
Captures CPU load, memory usage, disk space, and top processes at collection time. High resource usage or deployed app in top processes suggests performance impact.

**Confirms Cause If:** High sustained CPU/memory usage; deployed app in top processes  
**Rules Out If:** Normal resource utilization; deployed app not consuming resources

---

## Interpreting Results

### Overall Conclusion Logic

The script reaches one of three conclusions:

#### ✅ **Supported**
- 3+ independent evidence points support deployment as the cause
- Recommended action: Escalate to Infrastructure Engineering; prepare for remediation (redeploy, adjust settings, rollback if needed)

#### ✅ **Not Supported**
- 2+ evidence points contradict deployment as the cause
- No supporting evidence
- Recommended action: Investigation should focus on other root causes (Windows updates, network, user configuration)

#### ⚠️ **Inconclusive**
- Mixed evidence or insufficient data collected
- Missing access to critical data (IME logs, event logs inaccessible)
- Recommended action: Escalate with note that permission escalation or deeper investigation needed

### Missing Evidence is NOT Proof

If Intune logs are inaccessible or Event logs unavailable, this does NOT mean the deployment was not responsible. Mark such checks as "Inconclusive" and escalate for investigation with elevated privileges.

---

## Rollback and Idempotency

### Rollback Behavior

The `-Rollback` parameter removes ONLY diagnostic artifacts created by a previous collection run:

- `Floor6_Diagnostics_<RunId>.json` - Main report file
- `Floor6_Log_<RunId>.txt` - Event log from collection
- `Floor6_Manifest_<RunId>.json` - Run metadata

**Rollback does NOT:**
- Uninstall or modify the deployed application
- Stop or restart services
- Clear Windows event logs
- Modify registry or system configuration
- Reverse Intune deployments
- Restore system to previous state

To reverse an application deployment, use Intune console or manual uninstall procedures.

### Idempotency

Running the script multiple times produces consistent results:

- Each run gets a unique `RunId` (auto-generated or specified)
- Previous reports are not overwritten (use different RunIds)
- Re-running same collection command produces new report with new RunId
- No duplicate entries in logs or manifests
- Already-collected data is not re-processed

---

## Permissions and Access

### Required Permissions

The script operates read-only and requires:

- **User Context:** Administrator (for event log access)
- **File System:** Read access to event log locations and registry
- **Registry:** Read access to `HKEY_LOCAL_MACHINE` and `HKEY_CURRENT_USER`
- **WMI/CIM:** Read access to Win32_OperatingSystem, Win32_Processor, Win32_LogicalDisk
- **Services:** Read access to query service status (no start/stop)
- **Intune:** Read access to IME log files (typically in `C:\Program Files\...`)

### Access Denied Handling

If a check encounters access denied:

1. Status is marked as "AccessDenied" or "Skipped"
2. Error detail is logged
3. Script continues with remaining checks
4. Execution does NOT stop
5. Summary indicates how many checks were inaccessible

**Resolution:** Re-run with elevated Administrator privileges or escalate to Infrastructure Engineering.

---

## Performance Considerations

The enhanced script optimizes performance by:

- **Event Logs:** Using `Get-WinEvent` with filtered queries (specific IDs, time ranges, max 100 events per log)
- **Large Logs:** Reading only the last 1000 lines of Intune IME logs
- **Processes:** Limiting to top 10 by memory usage
- **Registry:** Excluding unnecessary branches
- **Lookback Period:** Configurable (default 3 days) to limit data volume

**Typical Execution Time:** 30-60 seconds on modern hardware with standard permissions.

---

## Log File Locations

All outputs are saved to the OutputPath (default: `C:\ProgramData\DWP-Diagnostics\`):

```
C:\ProgramData\DWP-Diagnostics\
├── Floor6_Diagnostics_20240115-102345.json   # Main report (structured evidence)
├── Floor6_Log_20240115-102345.txt            # Timestamped event log
├── Floor6_Manifest_20240115-102345.json      # Run metadata for rollback
├── Floor6_Diagnostics_20240116-143022.json   # Previous run (different RunId)
└── ...
```

### JSON Report Schema

```json
{
  "RunMetadata": {
    "RunId": "unique-id",
    "Timestamp": "ISO-8601 datetime",
    "ApplicationName": "deployed app name",
    "DeploymentWindowStart": "ISO-8601 datetime",
    "DeploymentWindowEnd": "ISO-8601 datetime"
  },
  "Diagnostics": {
    "<CheckName>": {
      "Status": "Success|Failed|Skipped|AccessDenied|Inconclusive",
      "Evidence": { ... },
      "SupportingEvidence": "string or null",
      "ContradictingEvidence": "string or null",
      "ConfirmsCause": "string",
      "RuleOutCause": "string",
      "RecommendedAction": "string",
      "ErrorDetail": "string or null"
    }
  },
  "Summary": {
    "OverallConclusion": "Supported|Not Supported|Inconclusive",
    "Evidence": {
      "Supporting": ["CheckName1", ...],
      "Contradicting": ["CheckName2", ...],
      "Inconclusive": ["CheckName3", ...]
    },
    "NextSteps": [...]
  }
}
```

---

## Limitations

1. **Read-Only:** The script cannot modify endpoint state or reverse deployments
2. **Timing:** Collection happens at script execution time; historical snapshots require previous logs
3. **IME Logs:** Only available if Intune Management Extension is installed
4. **Event Logs:** Some log providers may not be available on all systems (normal)
5. **Scheduled Tasks:** Creation date not directly accessible; only last-run time
6. **Services:** Registry-based service creation timestamps may not be reliable

---

## Troubleshooting

### Script requires Administrator privileges
**Symptom:** Access denied when querying event logs  
**Solution:** Right-click PowerShell, select "Run as Administrator", then run script

### "DryRun cannot be combined with Rollback"
**Symptom:** Script exits with parameter validation error  
**Solution:** Choose one mode: `-DryRun $true` OR `-Rollback $true`, not both

### "-RunId is required for rollback mode"
**Symptom:** Rollback fails with missing parameter  
**Solution:** Specify `-RunId` when using `-Rollback`, e.g., `-RunId "20240115-102345"`

### "Event logs not found or inaccessible"
**Symptom:** Event log check marked as "AccessDenied"  
**Solution:** This is normal on some systems; escalate with admin privileges or check whether log providers are enabled

### Output files not created
**Symptom:** JSON reports missing after collection  
**Solution:** Check that OutputPath is writable; verify disk space; review log file for errors

---

## Change Summary: v1.0 → v2.0

| Improvement | Impact |
|------------|--------|
| Added `-ApplicationName` parameter | Focused investigation on specific deployed applications |
| Added `-DeploymentDate` and `-LookbackDays` | Flexible time window configuration |
| Added `-RunId` tracking | Idempotency, deduplication, rollback capability |
| Enhanced `-DryRun` mode | Clear display of all checks without data collection |
| Implemented `-Rollback` | Safe cleanup of diagnostic artifacts only |
| Restructured JSON output | Supporting/Contradicting/Inconclusive evidence categorization |
| Per-check try/catch | Failure of one check doesn't stop others |
| Performance optimizations | Get-WinEvent filters, event limits, tail-read logs |
| Improved conclusion logic | "Supported", "Not Supported", "Inconclusive" |
| Added inline comments | L1/L2 engineers can understand each section |
| Missing evidence handling | Inconclusive rather than false proof |
| Execution timing | Tracks actual collection duration |

---

## Support and Escalation

If investigation results are inconclusive or you need assistance:

1. **First Run:** Execute with `-DryRun $true` to validate configuration
2. **Collect Evidence:** Run without `-DryRun` to gather actual diagnostics
3. **Review Report:** Open JSON report and examine Supporting/Contradicting evidence
4. **Escalate:** Forward JSON report to Infrastructure Engineering with:
   - Device name
   - Application name
   - Deployment date
   - When issue was first reported
   - Number of affected users/devices
5. **With Elevated Access:** Re-run as Domain Admin or System if access denied on event logs

---

## Examples of Analysis

### Scenario 1: Clear Cause
**Evidence:**
- ✅ Application installed during deployment window
- ✅ Device rebooted immediately after
- ✅ User Profile Service errors in event logs during/after deployment
- ✅ Intune IME logs show repeated retries

**Conclusion:** **Supported** → Recommend escalation for remediation

### Scenario 2: Likely Not the Cause
**Evidence:**
- ❌ Application not found in installed programs
- ❌ No applications installed during deployment window
- ✅ Event logs show minimal errors
- ✅ Device performance normal

**Conclusion:** **Not Supported** → Investigate other root causes

### Scenario 3: Need More Investigation
**Evidence:**
- ✅ Application installed during deployment window
- ❌ Event logs inaccessible (access denied)
- ⚠️ Intune IME logs missing
- ✅ Device rebooted during window

**Conclusion:** **Inconclusive** → Escalate with elevated privileges for full analysis

---

## Version History

- **v2.0** (2024-01): Enhanced with application-focused parameters, rollback, improved JSON output, performance optimizations
- **v1.0** (2023-12): Initial release with diagnostic collection baseline

---

**Last Updated:** 2024-01-15  
**Compatibility:** Windows PowerShell 5.1+  
**License:** Internal Use - DWP Engineering

