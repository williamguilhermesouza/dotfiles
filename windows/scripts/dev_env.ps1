#!/usr/bin/env pwsh

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = $scriptDir
$parentOfClone = Split-Path -Parent $projectRoot
$configDir = Join-Path $projectRoot "config"

$env:DEV_ENV = $parentOfClone
$env:XDG_HOME = $configDir
$env:XDG_CONFIG_HOME = $configDir

Write-Host "DEV_ENV=$($env:DEV_ENV)"
Write-Host "XDG_HOME=$($env:XDG_HOME)"
