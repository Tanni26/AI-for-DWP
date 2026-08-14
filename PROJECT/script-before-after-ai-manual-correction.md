# Script Before/After: AI-Generated and Hand-Corrected

## Script
- File: finbridge-floor6-deployment-diagnostics.ps1
- Context: Installed application evidence output structure

## Why This Was Corrected
The AI-generated version converted application collections to JSON strings too early. That made downstream analysis harder because arrays became text blobs instead of structured objects.

## Before (AI-Generated)
```powershell
$Results.InstalledApplications = @{
    DocumentManagementApps = @($docMgmtApps | ConvertTo-Json -Depth 2)
    RecentInstallations = @($recentInstalls | ConvertTo-Json -Depth 2)
    TotalInstalledApps = $apps.Count
    DocumentManagementAppCount = $docMgmtApps.Count
    RecentInstallCount = $recentInstalls.Count
}
```

## After (Hand-Corrected)
```powershell
$Results.InstalledApplications = @{
    DocumentManagementApps = @($docMgmtApps)
    RecentInstallations = @($recentInstalls)
    TotalInstalledApps = $apps.Count
    DocumentManagementAppCount = $docMgmtApps.Count
    RecentInstallCount = $recentInstalls.Count
}
```

## Impact of the Correction
- Preserves object structure for reliable filtering and comparison.
- Avoids double-serialization problems in later export steps.
- Keeps evidence machine-readable for engineering review and audit traceability.
