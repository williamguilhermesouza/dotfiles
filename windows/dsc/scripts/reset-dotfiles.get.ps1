Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$sharedPairsPath = Join-Path $PSScriptRoot "..\..\scripts\shared\dotfile-pairs.ps1"
. $sharedPairsPath

$repoRoot = Resolve-RepoRoot
@{
  Result = "repoRoot=$repoRoot; mode=reset"
}
