Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$configFile = (Resolve-Path (Join-Path $PSScriptRoot "..\..\dsc\configuration.dev.dsc.yaml")).Path

Write-Host "Applying dev environment from: $configFile"
winget configure -f $configFile --accept-configuration-agreements
if ($LASTEXITCODE -ne 0) {
  throw "winget configure failed with exit code $LASTEXITCODE"
}
