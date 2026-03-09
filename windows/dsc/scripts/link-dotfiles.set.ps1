Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$sharedPairsPath = Join-Path $PSScriptRoot "..\..\scripts\shared\dotfile-pairs.ps1"
. $sharedPairsPath

function Ensure-Link {
  param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Target,
    [Parameter(Mandatory = $true)][bool]$IsDirectory
  )

  if (-not (Test-Path -LiteralPath $Source)) {
    Write-Host "Skipping missing source: $Source"
    return
  }

  $targetParent = Split-Path -Path $Target -Parent
  if (-not [string]::IsNullOrWhiteSpace($targetParent)) {
    New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
  }

  if (Test-Path -LiteralPath $Target) {
    $item = Get-Item -LiteralPath $Target -Force
    $resolvedSource = (Resolve-Path -LiteralPath $Source).Path
    $resolvedTargetLink = $null

    if ($item.LinkType -eq "SymbolicLink" -or $item.LinkType -eq "Junction") {
      try {
        $resolvedTargetLink = (Resolve-Path -LiteralPath $Target).Path
      } catch {
        $resolvedTargetLink = $null
      }
    }

    if (($item.LinkType -eq "SymbolicLink" -or $item.LinkType -eq "Junction") -and $resolvedTargetLink -eq $resolvedSource) {
      return
    }

    if ($item.LinkType -eq "HardLink") {
      $hardLinks = @(Get-Item -LiteralPath $Target -Force | Select-Object -ExpandProperty Target)
      if ($hardLinks -contains $resolvedSource) {
        return
      }
    }

    $backup = "$Target.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Move-Item -LiteralPath $Target -Destination $backup
  }

  try {
    New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
    return
  } catch {
    $isElevationError = $_.FullyQualifiedErrorId -like "*NewItemSymbolicLinkElevationRequired*" -or
      $_.Exception -is [System.UnauthorizedAccessException]
    if ($isElevationError) {
      throw "Failed to create symbolic link '$Target' -> '$Source'. Symbolic link privileges are required. Re-run PowerShell elevated or enable Developer Mode."
    }
    throw
  }
}

$pairs = Get-ManagedLinkPairs

foreach ($pair in $pairs) {
  Ensure-Link -Source $pair.Source -Target $pair.Target -IsDirectory $pair.IsDirectory
}
