Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path

function New-SafeSymlink {
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
            Write-Host "Already linked: $Target -> $Source"
            return
        }

        if ($item.LinkType -eq "HardLink") {
            $hardLinks = @(Get-Item -LiteralPath $Target -Force | Select-Object -ExpandProperty Target)
            if ($hardLinks -contains $resolvedSource) {
                Write-Host "Already linked: $Target -> $Source"
                return
            }
        }

        $backup = "$Target.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Move-Item -LiteralPath $Target -Destination $backup
        Write-Host "Backed up existing target: $Target -> $backup"
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
        Write-Host "Linked: $Target -> $Source"
        return
    } catch {
        $isElevationError = $_.FullyQualifiedErrorId -like "*NewItemSymbolicLinkElevationRequired*" -or
            $_.Exception -is [System.UnauthorizedAccessException]

        if (-not $isElevationError) {
            throw
        }
    }

    if ($IsDirectory) {
        New-Item -ItemType Junction -Path $Target -Target $Source | Out-Null
        Write-Host "Linked with junction fallback: $Target -> $Source"
        return
    }

    $resolvedSource = (Resolve-Path -LiteralPath $Source).Path
    $sourceRoot = [System.IO.Path]::GetPathRoot($resolvedSource)
    $targetRoot = [System.IO.Path]::GetPathRoot($Target)

    if ($sourceRoot -eq $targetRoot) {
        try {
            New-Item -ItemType HardLink -Path $Target -Target $Source | Out-Null
            Write-Host "Linked with hardlink fallback: $Target -> $Source"
            return
        } catch {
            # Continue to copy fallback below.
        }
    }

    Copy-Item -LiteralPath $Source -Destination $Target -Force
    Write-Host "Copied (fallback, no symlink privileges): $Target <= $Source"
}

$nvimSource = Join-Path $repoRoot "config\nvim"
$vimSource = Join-Path $repoRoot "config\vim"
$ideaVimSource = Join-Path $repoRoot "config\ideavim\.ideavimrc"
$vsVimSource = Join-Path $repoRoot "config\vsvim\.vsvimrc"
$windowsTerminalSource = Join-Path $repoRoot "config\windows-terminal\settings.json"
$yaziSource = Join-Path $repoRoot "config\yazi"
$glazeWmSource = Join-Path $repoRoot "config\glazewm"
$zebarSource = Join-Path $repoRoot "config\zebar"
$powershellSource = Join-Path $repoRoot "config\powershell\profile.ps1"

$nvimTarget = Join-Path $env:LOCALAPPDATA "nvim"
$vimTarget = Join-Path $HOME ".vim"
$ideaVimTarget = Join-Path $HOME ".ideavimrc"
$vsVimTargetDot = Join-Path $HOME ".vsvimrc"
$vsVimTargetUnderscore = Join-Path $HOME "_vsvimrc"
$yaziTarget = Join-Path $env:APPDATA "yazi\config"
$glazeWmTarget = Join-Path $HOME ".glzr\glazewm"
$zebarTarget = Join-Path $HOME ".glzr\zebar"
$powershellTargetPwsh = Join-Path $HOME "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$powershellTargetWindowsPowerShell = Join-Path $HOME "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

$windowsTerminalTargets = @(
    (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json")
    (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json")
)

New-SafeSymlink -Source $nvimSource -Target $nvimTarget -IsDirectory $true
New-SafeSymlink -Source $vimSource -Target $vimTarget -IsDirectory $true
New-SafeSymlink -Source $ideaVimSource -Target $ideaVimTarget -IsDirectory $false
New-SafeSymlink -Source $vsVimSource -Target $vsVimTargetDot -IsDirectory $false
New-SafeSymlink -Source $vsVimSource -Target $vsVimTargetUnderscore -IsDirectory $false
foreach ($windowsTerminalTarget in $windowsTerminalTargets) {
    New-SafeSymlink -Source $windowsTerminalSource -Target $windowsTerminalTarget -IsDirectory $false
}
New-SafeSymlink -Source $yaziSource -Target $yaziTarget -IsDirectory $true
New-SafeSymlink -Source $glazeWmSource -Target $glazeWmTarget -IsDirectory $true
New-SafeSymlink -Source $zebarSource -Target $zebarTarget -IsDirectory $true
New-SafeSymlink -Source $powershellSource -Target $powershellTargetPwsh -IsDirectory $false
New-SafeSymlink -Source $powershellSource -Target $powershellTargetWindowsPowerShell -IsDirectory $false

Write-Host "Done."
