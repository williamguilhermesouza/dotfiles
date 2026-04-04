Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-ConfigRoot {
  $configuredPath = [System.Environment]::GetEnvironmentVariable("DOTFILES_CONFIG_PATH", "Process")
  if ([string]::IsNullOrWhiteSpace($configuredPath)) {
    $configuredPath = [System.Environment]::GetEnvironmentVariable("DOTFILES_CONFIG_PATH", "User")
  }

  if (-not [string]::IsNullOrWhiteSpace($configuredPath)) {
    return (Resolve-Path -LiteralPath $configuredPath).Path
  }

  $repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\..\..")).Path
  return (Join-Path $repoRoot "config")
}

$configRoot = Resolve-ConfigRoot
$documentsPath = [System.Environment]::GetFolderPath("MyDocuments")
$windowsPowerShellProfilePath = Join-Path (Join-Path $documentsPath "WindowsPowerShell") "Microsoft.PowerShell_profile.ps1"
$powerShellProfilePath = Join-Path (Join-Path $documentsPath "PowerShell") "Microsoft.PowerShell_profile.ps1"
$weztermConfigDir = Join-Path $HOME ".config\wezterm"
$weztermSessionManagerRepoUrl = "https://github.com/danielcopper/wezterm-session-manager.git"
$weztermSessionManagerTarget = Join-Path $weztermConfigDir "wezterm-session-manager"

$pairs = @(
  @{ Source = (Join-Path $configRoot "nvim"); Target = (Join-Path $env:LOCALAPPDATA "nvim") }
  @{ Source = (Join-Path $configRoot "vim"); Target = (Join-Path $HOME ".vim") }
  @{ Source = (Join-Path $configRoot "ideavim\.ideavimrc"); Target = (Join-Path $HOME ".ideavimrc") }
  @{ Source = (Join-Path $configRoot "vsvim\.vsvimrc"); Target = (Join-Path $HOME ".vsvimrc") }
  @{ Source = (Join-Path $configRoot "vsvim\.vsvimrc"); Target = (Join-Path $HOME "_vsvimrc") }
  @{ Source = (Join-Path $configRoot "windows-terminal\settings.json"); Target = (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json") }
  @{ Source = (Join-Path $configRoot "windows-terminal\settings.json"); Target = (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json") }
  @{ Source = (Join-Path $configRoot "wezterm\wezterm.lua"); Target = (Join-Path $HOME ".wezterm.lua") }
  @{ Source = (Join-Path $configRoot "yazi"); Target = (Join-Path $env:APPDATA "yazi\config") }
  @{ Source = (Join-Path $configRoot "glazewm"); Target = (Join-Path $HOME ".glzr\glazewm") }
  @{ Source = (Join-Path $configRoot "zebar"); Target = (Join-Path $HOME ".glzr\zebar") }
  @{ Source = (Join-Path $configRoot "powershell\profile.ps1"); Target = $powerShellProfilePath }
  @{ Source = (Join-Path $configRoot "powershell\profile.ps1"); Target = $windowsPowerShellProfilePath }
)

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

function Ensure-GitClone {
  param(
    [Parameter(Mandatory = $true)][string]$RepositoryUrl,
    [Parameter(Mandatory = $true)][string]$TargetPath
  )

  $gitCommand = Get-Command git -ErrorAction SilentlyContinue
  if ($null -eq $gitCommand) {
    throw "Git is required to clone '$RepositoryUrl', but it was not found in PATH."
  }

  $targetParent = Split-Path -Path $TargetPath -Parent
  if (-not [string]::IsNullOrWhiteSpace($targetParent)) {
    New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
  }

  if (Test-Path -LiteralPath $TargetPath) {
    $gitDirectory = Join-Path $TargetPath ".git"
    if (-not (Test-Path -LiteralPath $gitDirectory)) {
      throw "Cannot manage '$TargetPath' because it already exists and is not a git repository."
    }

    $remoteUrl = (& git -C $TargetPath remote get-url origin 2>$null)
    if ($LASTEXITCODE -ne 0) {
      throw "Cannot determine the git remote for '$TargetPath'."
    }

    if ($remoteUrl.Trim() -ne $RepositoryUrl) {
      throw "Cannot manage '$TargetPath' because it points to '$($remoteUrl.Trim())' instead of '$RepositoryUrl'."
    }

    return
  }

  & git clone $RepositoryUrl $TargetPath
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to clone '$RepositoryUrl' into '$TargetPath'."
  }
}

foreach ($pair in $pairs) {
  Ensure-Link -Source $pair.Source -Target $pair.Target
}

Ensure-GitClone -RepositoryUrl $weztermSessionManagerRepoUrl -TargetPath $weztermSessionManagerTarget
