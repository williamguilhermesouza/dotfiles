Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

function New-SafeSymlink {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][bool]$IsDirectory
    )

    $targetParent = Split-Path -Path $Target -Parent
    if (-not [string]::IsNullOrWhiteSpace($targetParent)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }

    if (Test-Path -LiteralPath $Target) {
        $item = Get-Item -LiteralPath $Target -Force
        if ($item.LinkType -eq "SymbolicLink" -and $item.Target -eq $Source) {
            Write-Host "Already linked: $Target -> $Source"
            return
        }

        $backup = "$Target.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Move-Item -LiteralPath $Target -Destination $backup
        Write-Host "Backed up existing target: $Target -> $backup"
    }

    $itemType = if ($IsDirectory) { "SymbolicLink" } else { "SymbolicLink" }
    New-Item -ItemType $itemType -Path $Target -Target $Source | Out-Null
    Write-Host "Linked: $Target -> $Source"
}

$nvimSource = Join-Path $repoRoot "nvim"
$ideaVimSource = Join-Path $repoRoot "ideavim\.ideavimrc"
$vsVimSource = Join-Path $repoRoot "vsvim\.vsvimrc"

$nvimTarget = Join-Path $env:LOCALAPPDATA "nvim"
$ideaVimTarget = Join-Path $HOME ".ideavimrc"
$vsVimTargetDot = Join-Path $HOME ".vsvimrc"
$vsVimTargetUnderscore = Join-Path $HOME "_vsvimrc"

New-SafeSymlink -Source $nvimSource -Target $nvimTarget -IsDirectory $true
New-SafeSymlink -Source $ideaVimSource -Target $ideaVimTarget -IsDirectory $false
New-SafeSymlink -Source $vsVimSource -Target $vsVimTargetDot -IsDirectory $false
New-SafeSymlink -Source $vsVimSource -Target $vsVimTargetUnderscore -IsDirectory $false

Write-Host "Done."
