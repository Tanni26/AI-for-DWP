<#
.SYNOPSIS
Safely removes old temp files from common Windows temp locations.

.DESCRIPTION
This script is designed for DWP engineers to clean up temp files on Windows endpoints.
It supports dry run mode, age filtering, per-file error handling, locked-file skipping,
logging, summary reporting, and rollback through a backup stash.

The script is intentionally conservative:
- It targets temp locations only.
- It deletes only files older than the configured age.
- It skips locked files and logs the reason.
- It backs up deleted files so they can be restored if needed.

.NOTES
PowerShell version: 5.1
Read-only mode: use -DryRun to list actions without deleting anything.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    # This controls how old a file must be before it is eligible for cleanup.
    [Parameter()]
    [ValidateRange(0, 3650)]
    [int]$OlderThanDays = 0,

    # This prints the files that would be deleted without changing the endpoint.
    [Parameter()]
    [switch]$DryRun,

    # This restores files that were previously backed up by a cleanup run.
    [Parameter()]
    [switch]$Rollback,

    # This sets the log directory used for timestamped run logs and rollback files.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$LogRoot = "$env:ProgramData\DWP-TempCleanup"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# This section prepares run-specific folders and a timestamped log file.
$runStamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$logDirectory = Join-Path -Path $LogRoot -ChildPath 'Logs'
$backupDirectory = Join-Path -Path $LogRoot -ChildPath 'Rollback'
$runBackupDirectory = Join-Path -Path $backupDirectory -ChildPath $runStamp
$logFile = Join-Path -Path $logDirectory -ChildPath "temp-cleanup-$runStamp.log"

New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null
New-Item -Path $backupDirectory -ItemType Directory -Force | Out-Null
if (-not $Rollback) {
    New-Item -Path $runBackupDirectory -ItemType Directory -Force | Out-Null
}

# This section starts a transcript-style log so every action is written to a timestamped file.
Start-Transcript -Path $logFile -Force | Out-Null

# This helper writes a message to both the console and the log transcript.
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR', 'SUCCESS')]
        [string]$Level = 'INFO'
    )

    $entry = '[{0}] [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    Write-Output $entry
}

# This helper checks whether a file is locked by trying to open it exclusively.
function Test-FileLocked {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$File
    )

    try {
        $stream = [System.IO.File]::Open($File.FullName, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
        $stream.Close()
        return $false
    }
    catch {
        return $true
    }
}

# This helper copies a file to the rollback stash while preserving its relative path.
function Copy-ToRollbackStash {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$File,
        [Parameter(Mandatory = $true)]
        [string]$SourceRoot,
        [Parameter(Mandatory = $true)]
        [string]$DestinationRoot
    )

    $relativePath = $File.FullName.Substring($SourceRoot.Length).TrimStart('\')
    $targetPath = Join-Path -Path $DestinationRoot -ChildPath $relativePath
    $targetFolder = Split-Path -Path $targetPath -Parent
    $backupPath = [System.IO.Path]::ChangeExtension($targetPath, '.bin')

    New-Item -Path $targetFolder -ItemType Directory -Force | Out-Null
    Copy-Item -Path $File.FullName -Destination $backupPath -Force

    return $backupPath
}

# This helper restores files from a previous rollback stash back to their original temp locations.
function Restore-FromRollbackStash {
    param(
        [Parameter(Mandatory = $true)]
        [string]$StashRoot
    )

    $manifestFiles = Get-ChildItem -Path $StashRoot -Recurse -File -Filter '*.restore.txt' -ErrorAction SilentlyContinue | Sort-Object FullName
    if (-not $manifestFiles) {
        Write-Log -Level 'WARN' -Message 'No rollback manifest found. Nothing to restore.'
        return [pscustomobject]@{ Restored = 0; Failed = 0 }
    }

    $restored = 0
    $failed = 0

    foreach ($manifest in $manifestFiles) {
        try {
            $originalPath = Get-Content -Path $manifest.FullName -ErrorAction Stop | Select-Object -First 1
            $backupFile = [System.IO.Path]::ChangeExtension($manifest.FullName, '.bin')

            if (-not (Test-Path -Path $backupFile)) {
                Write-Log -Level 'WARN' -Message "Rollback file missing for manifest: $($manifest.FullName)"
                $failed++
                continue
            }

            $restoreFolder = Split-Path -Path $originalPath -Parent
            New-Item -Path $restoreFolder -ItemType Directory -Force | Out-Null
            Copy-Item -Path $backupFile -Destination $originalPath -Force
            Write-Log -Level 'SUCCESS' -Message "Restored: $originalPath"
            $restored++
        }
        catch {
            Write-Log -Level 'ERROR' -Message "Rollback failed for $($manifest.FullName): $($_.Exception.Message)"
            $failed++
        }
    }

    return [pscustomobject]@{ Restored = $restored; Failed = $failed }
}

# This section defines the temp locations that the script will inspect.
$tempRoots = @(
    $env:TEMP,
    $env:TMP,
    (Join-Path -Path $env:WINDIR -ChildPath 'Temp')
) | Where-Object { $_ -and (Test-Path -Path $_) } | Select-Object -Unique

# This section handles rollback mode before any cleanup is attempted.
if ($Rollback) {
    Write-Log -Message 'Rollback mode selected. Restoring from backup stash only.'
    $restoreResult = Restore-FromRollbackStash -StashRoot $backupDirectory
    Write-Log -Level 'SUCCESS' -Message ("Rollback summary: Restored={0}, Failed={1}" -f $restoreResult.Restored, $restoreResult.Failed)
    Stop-Transcript | Out-Null
    return
}

# This section calculates the age threshold so only files older than the configured number of days are processed.
$cutoff = (Get-Date).AddDays(-$OlderThanDays)

# These counters track the final cleanup summary.
[int]$scanned = 0
[int]$eligible = 0
[int]$deleted = 0
[int]$lockedSkipped = 0
[int]$errorCount = 0

# This section scans each temp root and processes files one at a time for safe, idempotent cleanup.
foreach ($root in $tempRoots) {
    Write-Log -Message "Scanning temp root: $root"

    $files = Get-ChildItem -Path $root -Recurse -File -Force -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        $scanned++

        # This per-file block keeps failures isolated so one bad file cannot stop the run.
        try {
            if ($file.LastWriteTime -gt $cutoff) {
                continue
            }

            $eligible++

            if (Test-FileLocked -File $file) {
                $lockedSkipped++
                Write-Log -Level 'WARN' -Message "Skipped locked file: $($file.FullName)"
                continue
            }

            if ($DryRun) {
                Write-Log -Message "Dry run: would delete $($file.FullName)"
                continue
            }

            if ($PSCmdlet.ShouldProcess($file.FullName, 'Delete temp file after backup')) {
                # This section creates a rollback copy before deleting the file so recovery is possible.
                $backupPath = Copy-ToRollbackStash -File $file -SourceRoot $root -DestinationRoot $runBackupDirectory
                $manifestPath = [System.IO.Path]::ChangeExtension($backupPath, '.restore.txt')
                @(
                    $file.FullName
                ) | Set-Content -Path $manifestPath -Force
                Remove-Item -Path $file.FullName -Force
                $deleted++
                Write-Log -Level 'SUCCESS' -Message "Deleted: $($file.FullName)"
            }
        }
        catch {
            # This catch block logs file-specific failures and then continues with the next file.
            $errorCount++
            Write-Log -Level 'ERROR' -Message "Failed on $($file.FullName): $($_.Exception.Message)"
            continue
        }
    }
}

# This section reports the outcome so an engineer can quickly see what happened.
Write-Host ''
Write-Host '=== Summary ==='
Write-Host ("Temp roots scanned : {0}" -f $tempRoots.Count)
Write-Host ("Files scanned      : {0}" -f $scanned)
Write-Host ("Files eligible     : {0}" -f $eligible)
Write-Host ("Files deleted      : {0}" -f $deleted)
Write-Host ("Locked files skipped: {0}" -f $lockedSkipped)
Write-Host ("Errors logged      : {0}" -f $errorCount)
Write-Host ("Log file           : {0}" -f $logFile)
if (-not $DryRun) {
    Write-Host ("Rollback stash     : {0}" -f $runBackupDirectory)
}
Write-Host 'Report complete.'

# This section ends the transcript cleanly after all actions are complete.
Stop-Transcript | Out-Null
