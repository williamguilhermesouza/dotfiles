Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$sharedPairsPath = Join-Path $PSScriptRoot "..\..\scripts\shared\dotfile-pairs.ps1"
. $sharedPairsPath

$repoRoot = Resolve-RepoRoot
$profileSource = Join-Path $repoRoot "config\powershell\profile.ps1"
$profileDirectory = Split-Path -Path $profileSource -Parent
$allowedPolicies = @("RemoteSigned", "Unrestricted", "Bypass")

$managedBlock = @'
# Managed by dotfiles.
# Load the Z module so `z` is available in new PowerShell sessions.
if (Get-Module -ListAvailable -Name Z -ErrorAction SilentlyContinue) {
  Import-Module Z -ErrorAction SilentlyContinue
}

if (Get-Command -Name z -ErrorAction SilentlyContinue) {
  Set-Alias -Name cd -Value z -Option AllScope -Force
}

Set-Alias -Name bat -Value cat -Option AllScope -Force
'@

New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null

if (-not (Test-Path -LiteralPath $profileSource)) {
  Set-Content -Path $profileSource -Value $managedBlock -NoNewline
} else {
  $profileSourceContent = Get-Content -Path $profileSource -Raw
  if ($profileSourceContent -notmatch "Import-Module\s+Z") {
    Add-Content -Path $profileSource -Value "`r`n`r`n$managedBlock"
  }
}

$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($allowedPolicies -notcontains $currentPolicy) {
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
}

$profileTargets = @(
  (Join-Path $HOME "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"),
  (Join-Path $HOME "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1")
)

foreach ($profileTarget in $profileTargets) {
  if (-not (Test-Path -LiteralPath $profileTarget)) {
    $parent = Split-Path -Path $profileTarget -Parent
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
      New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    Set-Content -Path $profileTarget -Value ". '$profileSource'" -NoNewline
  }
}
