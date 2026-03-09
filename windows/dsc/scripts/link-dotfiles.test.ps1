Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$sharedPairsPath = Join-Path $PSScriptRoot "..\..\scripts\shared\dotfile-pairs.ps1"
. $sharedPairsPath

$pairs = Get-ManagedLinkPairs

foreach ($pair in $pairs) {
  if (-not (Test-Path -LiteralPath $pair.Source)) { continue }
  if (-not (Test-Path -LiteralPath $pair.Target)) { return $false }
  $item = Get-Item -LiteralPath $pair.Target -Force

  if ($item.LinkType -eq "SymbolicLink" -or $item.LinkType -eq "Junction") {
    try {
      $resolvedTarget = (Resolve-Path -LiteralPath $pair.Target).Path
    } catch {
      return $false
    }
    $resolvedSource = (Resolve-Path -LiteralPath $pair.Source).Path
    if ($resolvedTarget -ne $resolvedSource) { return $false }
    continue
  }

  if ($item.LinkType -eq "HardLink") {
    $resolvedSource = (Resolve-Path -LiteralPath $pair.Source).Path
    $hardLinks = @(Get-Item -LiteralPath $pair.Target -Force | Select-Object -ExpandProperty Target)
    if ($hardLinks -notcontains $resolvedSource) { return $false }
    continue
  }

  return $false
}

return $true
