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

$allowedPolicies = @("RemoteSigned", "Unrestricted", "Bypass")
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($allowedPolicies -notcontains $currentPolicy) {
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
}

function Ensure-Link {
  param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Target
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
  } catch {
    $isElevationError = $_.FullyQualifiedErrorId -like "*NewItemSymbolicLinkElevationRequired*" -or
      $_.Exception -is [System.UnauthorizedAccessException]
    if ($isElevationError) {
      throw "Failed to create symbolic link '$Target' -> '$Source'. Symbolic link privileges are required. Re-run PowerShell elevated or enable Developer Mode."
    }
    throw
  }
}

foreach ($pair in $pairs) {
  Ensure-Link -Source $pair.Source -Target $pair.Target
}
