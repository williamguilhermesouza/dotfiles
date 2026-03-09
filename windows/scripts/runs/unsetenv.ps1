Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$configFile = (Resolve-Path (Join-Path $PSScriptRoot "..\..\dsc\configuration.reset.dsc.yaml")).Path

Write-Host "Resetting environment from: $configFile"
winget configure -f $configFile --accept-configuration-agreements
