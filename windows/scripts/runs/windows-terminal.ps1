Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$packageId = "Microsoft.WindowsTerminal"

$installedOutput = winget list --id $packageId --exact --accept-source-agreements 2>$null | Out-String
if ($LASTEXITCODE -eq 0 -and $installedOutput -match [regex]::Escape($packageId)) {
    Write-Host "Already installed: $packageId"
    exit 0
}

Write-Host "Installing: $packageId"
winget install --id $packageId -e --accept-source-agreements --accept-package-agreements
