<#
.SYNOPSIS
    Endpoint Health Summary Report

.DESCRIPTION
    Displays a quick health snapshot of the local machine:
      - Computer name and total RAM
      - Free space on the C: drive
      - Top 5 processes by memory consumption
      - Recent System event log errors (Level 2)
      - Count of user profiles unused for 90 or more days

.AUTHOR
    Unknown (inherited script — refactored for readability)

.HOW TO RUN
    Open PowerShell as Administrator, then run:
        .\Inherited.ps1

    No parameters required. Output is written to the console.

.NOTES
    Requires read access to the Windows Event Log (administrator or Event Log Readers group).
    This script is read-only — it makes no changes to the system.
#>

# Retrieve general computer details (name, total RAM, domain, manufacturer)
$computerSystem = Get-CimInstance Win32_ComputerSystem

# Get the number of free bytes remaining on the C: drive
$cDriveFreeBytes = Get-PSDrive C | Select-Object -ExpandProperty Free

# Collect all running processes, sort by working-set (RAM) usage, keep the top 5
$topMemoryProcesses = Get-Process | Sort-Object WS -Descending | Select-Object -First 5

# Read the last 10 System event log entries and filter to errors only (Level 2)
$recentSystemErrors = Get-WinEvent -LogName System -MaxEvents 10 | Where-Object { $_.Level -eq 2 }

# Find user profiles that are not system/special accounts and have not been used in 90+ days
$staleUserProfiles = Get-CimInstance Win32_UserProfile | Where-Object {
    -not $_.Special -and $_.LastUseTime -lt (Get-Date).AddDays(-90)
}

# Print the computer name and total physical RAM in bytes
Write-Host $computerSystem.Name $computerSystem.TotalPhysicalMemory

# Print the C: drive free space converted from bytes to GB, rounded to 2 decimal places
Write-Host ([math]::Round($cDriveFreeBytes / 1GB, 2)) 'GB free'

# Print the name and working-set (RAM) size for each of the top 5 memory processes
$topMemoryProcesses | ForEach-Object { Write-Host $_.Name $_.WS }

# Print the timestamp and message for each recent System log error
$recentSystemErrors | ForEach-Object { Write-Host $_.TimeCreated $_.Message }

# If any stale profiles were found, report how many
if ($staleUserProfiles.Count -gt 0) { Write-Host 'Stale profiles:' $staleUserProfiles.Count }