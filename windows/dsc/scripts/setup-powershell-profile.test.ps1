Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$sharedPairsPath = Join-Path $PSScriptRoot "..\..\scripts\shared\dotfile-pairs.ps1"
. $sharedPairsPath

$repoRoot = Resolve-RepoRoot
$profileSource = Join-Path $repoRoot "config\powershell\profile.ps1"
$allowedPolicies = @("RemoteSigned", "Unrestricted", "Bypass")
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser

if (-not (Test-Path -LiteralPath $profileSource)) {
  return $false
}

$profileSourceContent = Get-Content -Path $profileSource -Raw
if ($profileSourceContent -notmatch "Import-Module\s+Z") {
  return $false
}

if ($allowedPolicies -notcontains $currentPolicy) {
  return $false
}

$profileTargets = @(
  (Join-Path $HOME "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"),
  (Join-Path $HOME "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1")
)

foreach ($profileTarget in $profileTargets) {
  if (-not (Test-Path -LiteralPath $profileTarget)) {
    return $false
  }
}

return $true