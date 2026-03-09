Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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
    if (-not $isElevationError) { throw }
  }

  if ($IsDirectory) {
    New-Item -ItemType Junction -Path $Target -Target $Source | Out-Null
    return
  }

  $resolvedSource = (Resolve-Path -LiteralPath $Source).Path
  $sourceRoot = [System.IO.Path]::GetPathRoot($resolvedSource)
  $targetRoot = [System.IO.Path]::GetPathRoot($Target)
  if ($sourceRoot -eq $targetRoot) {
    try {
      New-Item -ItemType HardLink -Path $Target -Target $Source | Out-Null
      return
    } catch {
    }
  }

  Copy-Item -LiteralPath $Source -Destination $Target -Force
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$pairs = @(
  @{ Source = (Join-Path $repoRoot "config\nvim"); Target = (Join-Path $env:LOCALAPPDATA "nvim"); IsDirectory = $true }
  @{ Source = (Join-Path $repoRoot "config\vim"); Target = (Join-Path $HOME ".vim"); IsDirectory = $true }
  @{ Source = (Join-Path $repoRoot "config\ideavim\.ideavimrc"); Target = (Join-Path $HOME ".ideavimrc"); IsDirectory = $false }
  @{ Source = (Join-Path $repoRoot "config\vsvim\.vsvimrc"); Target = (Join-Path $HOME ".vsvimrc"); IsDirectory = $false }
  @{ Source = (Join-Path $repoRoot "config\vsvim\.vsvimrc"); Target = (Join-Path $HOME "_vsvimrc"); IsDirectory = $false }
  @{ Source = (Join-Path $repoRoot "config\windows-terminal\settings.json"); Target = (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"); IsDirectory = $false }
  @{ Source = (Join-Path $repoRoot "config\windows-terminal\settings.json"); Target = (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"); IsDirectory = $false }
)

foreach ($pair in $pairs) {
  Ensure-Link -Source $pair.Source -Target $pair.Target -IsDirectory $pair.IsDirectory
}
