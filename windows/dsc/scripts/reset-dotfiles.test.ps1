Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-LinkPairs {
  $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
  @(
    @{ Source = (Join-Path $repoRoot "config\nvim"); Target = (Join-Path $env:LOCALAPPDATA "nvim"); IsDirectory = $true }
    @{ Source = (Join-Path $repoRoot "config\vim"); Target = (Join-Path $HOME ".vim"); IsDirectory = $true }
    @{ Source = (Join-Path $repoRoot "config\ideavim\.ideavimrc"); Target = (Join-Path $HOME ".ideavimrc"); IsDirectory = $false }
    @{ Source = (Join-Path $repoRoot "config\vsvim\.vsvimrc"); Target = (Join-Path $HOME ".vsvimrc"); IsDirectory = $false }
    @{ Source = (Join-Path $repoRoot "config\vsvim\.vsvimrc"); Target = (Join-Path $HOME "_vsvimrc"); IsDirectory = $false }
    @{ Source = (Join-Path $repoRoot "config\windows-terminal\settings.json"); Target = (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"); IsDirectory = $false }
    @{ Source = (Join-Path $repoRoot "config\windows-terminal\settings.json"); Target = (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"); IsDirectory = $false }
  )
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
  $resolvedSource = $null
  try {
    $resolvedSource = (Resolve-Path -LiteralPath $Source).Path
  } catch {
    return $false
  }

  if ($item.LinkType -eq "SymbolicLink" -or $item.LinkType -eq "Junction") {
    try {
      $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    } catch {
      return $false
    }
    return ($resolvedTarget -eq $resolvedSource)
  }

  if ($item.LinkType -eq "HardLink") {
    $hardLinks = @(Get-Item -LiteralPath $Target -Force | Select-Object -ExpandProperty Target)
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

  if ((-not (Test-Path -LiteralPath $pair.Target)) -and (Get-LatestBackupPath -Target $pair.Target)) {
    return $false
  }
}

return $true
