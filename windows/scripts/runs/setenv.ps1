Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$configFile = (Resolve-Path (Join-Path $PSScriptRoot "..\..\dsc\configuration.dev.dsc.yaml")).Path

Write-Host "Applying dev environment from: $configFile"
winget configure -f $configFile --accept-configuration-agreements
if ($LASTEXITCODE -ne 0) {
  throw "winget configure failed with exit code $LASTEXITCODE"
}

$requiredPackages = @(
  "Microsoft.WindowsTerminal"
  "glzr-io.glazewm"
  "glzr-io.zebar"
  "sxyazi.yazi"
)

$missingPackages = @()
foreach ($packageId in $requiredPackages) {
  $installedOutput = winget list --id $packageId --exact --accept-source-agreements 2>$null | Out-String
  if ($LASTEXITCODE -ne 0 -or $installedOutput -notmatch [regex]::Escape($packageId)) {
    $missingPackages += $packageId
  }
}

if ($missingPackages.Count -gt 0) {
  $missingList = ($missingPackages -join ", ")
  throw "DSC completed but these packages are still missing: $missingList"
}

$glazeCandidates = @(
  (Join-Path $env:ProgramFiles "glzr.io\GlazeWM\glazewm.exe")
  (Join-Path $env:LOCALAPPDATA "Programs\glzr.io\GlazeWM\glazewm.exe")
)

$glazeInstalled = $false
foreach ($candidate in $glazeCandidates) {
  if (Test-Path -LiteralPath $candidate) {
    $glazeInstalled = $true
    break
  }
}

if (-not $glazeInstalled) {
  Write-Host "GlazeWM binary not found after DSC run. Retrying package install..."
  winget install --id glzr-io.glazewm -e --accept-source-agreements --accept-package-agreements --force
  if ($LASTEXITCODE -ne 0) {
    throw "GlazeWM install retry failed with exit code $LASTEXITCODE"
  }

  foreach ($candidate in $glazeCandidates) {
    if (Test-Path -LiteralPath $candidate) {
      $glazeInstalled = $true
      break
    }
  }
}

if (-not $glazeInstalled) {
  throw "GlazeWM package is reported installed, but glazewm.exe was not found in expected paths."
}
