[CmdletBinding()]
param(
    [Parameter()]
    [ValidateRange(0, 3650)]
    [int]$OlderThanDays = 0,

    [Parameter()]
    [switch]$DryRun,

    [Parameter()]
    [switch]$Rollback,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$LogRoot = "$env:ProgramData\DWP-TempCleanup"
)

$scriptPath = Join-Path -Path $PSScriptRoot -ChildPath 'temp-file-cleanup.ps1'
& $scriptPath @PSBoundParameters