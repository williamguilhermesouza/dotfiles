Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-RepoRoot {
  $candidates = @()

  if (-not [string]::IsNullOrWhiteSpace($env:DEV_ENV)) {
    $candidates += $env:DEV_ENV
  }

  if (-not [string]::IsNullOrWhiteSpace($env:XDG_CONFIG_HOME)) {
    $xdgConfigRoot = Split-Path -Path $env:XDG_CONFIG_HOME -Parent
    if (-not [string]::IsNullOrWhiteSpace($xdgConfigRoot)) {
      $candidates += $xdgConfigRoot
    }
  }

  $candidates += (Join-Path $PSScriptRoot "..\..\..")
  $candidates += (Join-Path $PSScriptRoot "..\..")

  foreach ($candidate in $candidates) {
    try {
      $resolved = (Resolve-Path -LiteralPath $candidate).Path
    } catch {
      continue
    }

    if (Test-Path -LiteralPath (Join-Path $resolved "config")) {
      return $resolved
    }
  }

  throw "Could not resolve repository root. Set DEV_ENV or XDG_CONFIG_HOME."
}

function Get-ManagedLinkPairs {
  param(
    [string]$RepoRoot = (Resolve-RepoRoot)
  )

  return @(
    @{ Source = (Join-Path $RepoRoot "config\nvim"); Target = (Join-Path $env:LOCALAPPDATA "nvim"); IsDirectory = $true }
    @{ Source = (Join-Path $RepoRoot "config\vim"); Target = (Join-Path $HOME ".vim"); IsDirectory = $true }
    @{ Source = (Join-Path $RepoRoot "config\ideavim\.ideavimrc"); Target = (Join-Path $HOME ".ideavimrc"); IsDirectory = $false }
    @{ Source = (Join-Path $RepoRoot "config\vsvim\.vsvimrc"); Target = (Join-Path $HOME ".vsvimrc"); IsDirectory = $false }
    @{ Source = (Join-Path $RepoRoot "config\vsvim\.vsvimrc"); Target = (Join-Path $HOME "_vsvimrc"); IsDirectory = $false }
    @{ Source = (Join-Path $RepoRoot "config\windows-terminal\settings.json"); Target = (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"); IsDirectory = $false }
    @{ Source = (Join-Path $RepoRoot "config\windows-terminal\settings.json"); Target = (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"); IsDirectory = $false }
    @{ Source = (Join-Path $RepoRoot "config\yazi"); Target = (Join-Path $env:APPDATA "yazi\config"); IsDirectory = $true }
    @{ Source = (Join-Path $RepoRoot "config\glazewm"); Target = (Join-Path $HOME ".glzr\glazewm"); IsDirectory = $true }
    @{ Source = (Join-Path $RepoRoot "config\zebar"); Target = (Join-Path $HOME ".glzr\zebar"); IsDirectory = $true }
    @{ Source = (Join-Path $RepoRoot "config\powershell\profile.ps1"); Target = (Join-Path $HOME "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"); IsDirectory = $false }
    @{ Source = (Join-Path $RepoRoot "config\powershell\profile.ps1"); Target = (Join-Path $HOME "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"); IsDirectory = $false }
  )
}
