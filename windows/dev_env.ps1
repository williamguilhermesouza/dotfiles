#!/usr/bin/env pwsh

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path
$devEnv = (Resolve-Path (Join-Path $projectRoot "..")).Path
$configDir = Join-Path $projectRoot "config"

$env:DEV_ENV = $devEnv
$env:XDG_HOME = $configDir
$env:XDG_CONFIG_HOME = $configDir

Write-Host "DEV_ENV=$($env:DEV_ENV)"
Write-Host "XDG_HOME=$($env:XDG_HOME)"
