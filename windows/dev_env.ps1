#!/usr/bin/env pwsh

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path
$devEnv = $projectRoot
$configDir = Join-Path $projectRoot "config"
$scriptsDir = Join-Path $projectRoot "windows\scripts"

$env:DEV_ENV = $devEnv
$env:XDG_HOME = $configDir
$env:XDG_CONFIG_HOME = $configDir

function Set-UserEnvVar {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Value
    )
    try {
        [Environment]::SetEnvironmentVariable($Name, $Value, "User")
    } catch {
        Write-Warning "Could not persist user env var '$Name'. Current session value was still set."
    }
}

function Add-ToUserPath {
    param(
        [Parameter(Mandatory = $true)][string]$Entry
    )

    $currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if (-not $currentUserPath) {
        $currentUserPath = ""
    }

    $parts = @($currentUserPath -split ";" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $normalizedEntry = $Entry.TrimEnd("\")
    $alreadyPresent = $false
    foreach ($part in $parts) {
        if ($part.TrimEnd("\").Equals($normalizedEntry, [System.StringComparison]::OrdinalIgnoreCase)) {
            $alreadyPresent = $true
            break
        }
    }

    if (-not $alreadyPresent) {
        $newPath = if ($currentUserPath) { "$currentUserPath;$Entry" } else { $Entry }
        try {
            [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        } catch {
            Write-Warning "Could not persist user PATH. Current session PATH was still updated."
        }
    }
}

Set-UserEnvVar -Name "DEV_ENV" -Value $devEnv
Set-UserEnvVar -Name "XDG_HOME" -Value $configDir
Set-UserEnvVar -Name "XDG_CONFIG_HOME" -Value $configDir
Add-ToUserPath -Entry $scriptsDir

# Keep current session in sync with user-level PATH update.
$env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")

Write-Host "DEV_ENV=$($env:DEV_ENV)"
Write-Host "XDG_HOME=$($env:XDG_HOME)"
Write-Host "XDG_CONFIG_HOME=$($env:XDG_CONFIG_HOME)"
Write-Host "Added to user PATH (if missing): $scriptsDir"
