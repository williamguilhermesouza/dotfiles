Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$packages = @(
  "Microsoft.WindowsTerminal"
  "glzr-io.glazewm"
  "sxyazi.yazi"
)

foreach ($packageId in $packages) {
  $installedOutput = winget list --id $packageId --exact --accept-source-agreements 2>$null | Out-String
  if ($LASTEXITCODE -eq 0 -and $installedOutput -match [regex]::Escape($packageId)) {
    winget uninstall --id $packageId --exact --accept-source-agreements
    Write-Host "Uninstalled package: $packageId"
  } else {
    Write-Host "Package not installed, skipping: $packageId"
  }
}
