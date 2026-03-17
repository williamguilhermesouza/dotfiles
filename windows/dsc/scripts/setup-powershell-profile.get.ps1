Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$sharedPairsPath = Join-Path $PSScriptRoot "..\..\scripts\shared\dotfile-pairs.ps1"
. $sharedPairsPath

$repoRoot = Resolve-RepoRoot
$profileSource = Join-Path $repoRoot "config\powershell\profile.ps1"
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser

@{
  RepoRoot = $repoRoot
  ProfileSource = $profileSource
  CurrentUserExecutionPolicy = $currentPolicy
}