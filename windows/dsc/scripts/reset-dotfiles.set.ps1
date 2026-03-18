Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\..")).Path
$pairs = @(
  @{ Source = (Join-Path $repoRoot "config\nvim"); Target = (Join-Path $env:LOCALAPPDATA "nvim") }
  @{ Source = (Join-Path $repoRoot "config\vim"); Target = (Join-Path $HOME ".vim") }
  @{ Source = (Join-Path $repoRoot "config\ideavim\.ideavimrc"); Target = (Join-Path $HOME ".ideavimrc") }
  @{ Source = (Join-Path $repoRoot "config\vsvim\.vsvimrc"); Target = (Join-Path $HOME ".vsvimrc") }
  @{ Source = (Join-Path $repoRoot "config\vsvim\.vsvimrc"); Target = (Join-Path $HOME "_vsvimrc") }
  @{ Source = (Join-Path $repoRoot "config\windows-terminal\settings.json"); Target = (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json") }
  @{ Source = (Join-Path $repoRoot "config\windows-terminal\settings.json"); Target = (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json") }
  @{ Source = (Join-Path $repoRoot "config\yazi"); Target = (Join-Path $env:APPDATA "yazi\config") }
  @{ Source = (Join-Path $repoRoot "config\glazewm"); Target = (Join-Path $HOME ".glzr\glazewm") }
  @{ Source = (Join-Path $repoRoot "config\zebar"); Target = (Join-Path $HOME ".glzr\zebar") }
  @{ Source = (Join-Path $repoRoot "config\powershell\profile.ps1"); Target = (Join-Path $HOME "Documents\PowerShell\Microsoft.PowerShell_profile.ps1") }
  @{ Source = (Join-Path $repoRoot "config\powershell\profile.ps1"); Target = (Join-Path $HOME "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1") }
)

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

foreach ($pair in $pairs) {
  $targetExists = Test-Path -LiteralPath $pair.Target
  $managed = Test-IsManagedTarget -Source $pair.Source -Target $pair.Target
  $backup = Get-LatestBackupPath -Target $pair.Target

  if ($managed -or ($targetExists -and $backup)) {
    Remove-Item -LiteralPath $pair.Target -Force -Recurse
  }

  if (-not (Test-Path -LiteralPath $pair.Target) -and $backup) {
    Move-Item -LiteralPath $backup -Destination $pair.Target
  }
}
