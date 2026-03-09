#!/usr/bin/env pwsh

# Resolve script directory (equivalent to bash BASH_SOURCE logic)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not $env:DEV_ENV) {
    Write-Host "env var DEV_ENV needs to be present"
    exit 1
}

# Ensure DEV_ENV is exported to child processes
$env:DEV_ENV = $env:DEV_ENV

$grep = ""
$dryRun = $false

# Parse arguments
foreach ($arg in $args) {
    Write-Host "ARG: `"$arg`""
    if ($arg -eq "--dry") {
        $dryRun = $true
    } else {
        $grep = $arg
    }
}

function Log($msg) {
    if ($dryRun) {
        Write-Host "[DRY_RUN]: $msg"
    } else {
        Write-Host $msg
    }
}

Log "RUN: env: $env:DEV_ENV -- grep: $grep"

$runsDir = Join-Path $scriptDir "runs"

if (-not (Test-Path -LiteralPath $runsDir)) {
    Write-Host "runs directory not found: $runsDir"
    exit 1
}

# Get executable scripts (ps1 files). Run link script last.
$scripts = Get-ChildItem -Path $runsDir -File |
    Sort-Object @{ Expression = { if ($_.Name -eq "link-dotfiles.ps1") { 1 } else { 0 } } }, Name

foreach ($s in $scripts) {
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($s.Name)
    if ($grep -and $scriptName -ne $grep -and $s.Name -ne $grep) {
        Log "grep `"$grep`" filtered out $($s.FullName)"
        continue
    }

    Log "running script: $($s.FullName)"

    if (-not $dryRun) {
        & $s.FullName
    }
}
