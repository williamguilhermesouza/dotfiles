Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$sharedPairsPath = Join-Path $PSScriptRoot "..\..\scripts\shared\dotfile-pairs.ps1"
. $sharedPairsPath

function Get-LinkPairs {
  return Get-ManagedLinkPairs
}

function Convert-ToAbsolutePath {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$BasePath
  )

  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }

  return [System.IO.Path]::GetFullPath((Join-Path $BasePath $Path))
}

function Normalize-PathForCompare {
  param(
    [Parameter(Mandatory = $true)][string]$Path
  )

  $normalized = $Path.Trim()
  if ($normalized.StartsWith("\\?\")) {
    $normalized = $normalized.Substring(4)
  } elseif ($normalized.StartsWith("\??\")) {
    $normalized = $normalized.Substring(4)
  }

  $normalized = [System.IO.Path]::GetFullPath($normalized)
  return $normalized.TrimEnd("\")
}

function Test-IsManagedTarget {
  param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Target
  )

  if (-not (Test-Path -LiteralPath $Target)) {
    return $false
  }

  $item = Get-Item -LiteralPath $Target -Force
  $expectedSource = Normalize-PathForCompare -Path (Convert-ToAbsolutePath -Path $Source -BasePath (Get-Location).Path)

  if ($item.LinkType -eq "SymbolicLink" -or $item.LinkType -eq "Junction") {
    $linkedPath = $item.Target
    if ($linkedPath -is [array]) {
      $linkedPath = $linkedPath[0]
    }

    if (-not [string]::IsNullOrWhiteSpace($linkedPath)) {
      $actualSource = Normalize-PathForCompare -Path (Convert-ToAbsolutePath -Path $linkedPath -BasePath (Split-Path -Path $Target -Parent))
      if ($actualSource -ieq $expectedSource) {
        return $true
      }
    }

    if (Test-Path -LiteralPath $Source) {
      try {
        $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
        $resolvedSource = (Resolve-Path -LiteralPath $Source).Path
        $resolvedTarget = Normalize-PathForCompare -Path $resolvedTarget
        $resolvedSource = Normalize-PathForCompare -Path $resolvedSource
        return ($resolvedTarget -eq $resolvedSource)
      } catch {
        return $false
      }
    }
  }

  if ($item.LinkType -eq "HardLink" -and (Test-Path -LiteralPath $Source)) {
    $resolvedSource = Normalize-PathForCompare -Path (Resolve-Path -LiteralPath $Source).Path
    $hardLinks = @(
      Get-Item -LiteralPath $Target -Force |
      Select-Object -ExpandProperty Target |
      ForEach-Object { Normalize-PathForCompare -Path ([string]$_) }
    )
    return ($hardLinks -contains $resolvedSource)
  }

  return $false
}

function Get-LatestBackupPath {
  param(
    [Parameter(Mandatory = $true)][string]$Target
  )

  $parent = Split-Path -Path $Target -Parent
  if (-not (Test-Path -LiteralPath $parent)) {
    return $null
  }

  $name = Split-Path -Path $Target -Leaf
  $pattern = "$name.backup.*"
  $latest = Get-ChildItem -LiteralPath $parent -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like $pattern } |
    Sort-Object Name -Descending |
    Select-Object -First 1

  if ($null -eq $latest) {
    return $null
  }

  return $latest.FullName
}

foreach ($pair in (Get-LinkPairs)) {
  if (Test-IsManagedTarget -Source $pair.Source -Target $pair.Target) {
    return $false
  }

  $backup = Get-LatestBackupPath -Target $pair.Target
  if ((-not (Test-Path -LiteralPath $pair.Target)) -and $backup) {
    return $false
  }

  if ((Test-Path -LiteralPath $pair.Target) -and $backup) {
    $item = Get-Item -LiteralPath $pair.Target -Force
    if (-not $item.LinkType) {
      return $false
    }
  }
}

return $true
