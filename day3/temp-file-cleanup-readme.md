# Temp File Cleanup Script

## Purpose
This PowerShell 5.1 script safely cleans up temp files on a Windows endpoint for DWP engineers.
It is designed to be conservative, traceable, and safe to rerun.

## Script
`dwp-temp-cleanup.ps1`

This wrapper runs the main cleanup logic in `temp-file-cleanup.ps1` from the same folder.

## What it does
- Targets common temp locations only.
- Deletes only files older than the configured number of days.
- Supports dry run mode so you can preview what will be deleted.
- Skips locked files and logs the error instead of stopping.
- Logs every action to a timestamped log file.
- Creates rollback copies before deletion.
- Prints a final summary at the end.

## Parameters

### `-OlderThanDays`
Controls the age threshold for cleanup.
- Default: `0`
- Meaning: only files older than the number of days you specify are eligible.
- Example: `-OlderThanDays 7`

### `-DryRun`
Shows the files that would be deleted without making any changes.
- Example: `-DryRun`

### `-Rollback`
Restores files from the rollback stash created by a previous cleanup run.
- Example: `-Rollback`

### `-LogRoot`
Sets the root folder used for logs and rollback files.
- Default: `C:\ProgramData\DWP-TempCleanup`
- Example: `-LogRoot 'D:\DWP-Cleanup'`

## Examples

### Preview what would be deleted
```powershell
.\dwp-temp-cleanup.ps1 -DryRun
```

### Remove temp files older than 7 days
```powershell
.\dwp-temp-cleanup.ps1 -OlderThanDays 7
```

### Restore files from the rollback stash
```powershell
.\dwp-temp-cleanup.ps1 -Rollback
```

### Use a custom log location
```powershell
.\dwp-temp-cleanup.ps1 -OlderThanDays 3 -LogRoot 'D:\DWP-Cleanup'
```

## Safety notes
- The script is read/write only when you run it without `-DryRun`.
- It is idempotent because already-deleted files are no longer eligible on the next run.
- Locked files are skipped and logged.
- Review the dry run output before doing a live cleanup.

## Rollback behavior
When the script deletes a file, it first copies that file to a rollback stash under the log root.
If you need to recover files, run the script with `-Rollback`.

## Notes for engineers
Before running in production, verify:
- The temp locations are appropriate for the endpoint scope.
- The rollback path has enough free disk space.
- You have permission to read and delete files in the target temp locations.
