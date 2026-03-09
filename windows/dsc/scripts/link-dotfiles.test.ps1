Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$pairs = @(
  @{ Source = (Join-Path $repoRoot "config\nvim"); Target = (Join-Path $env:LOCALAPPDATA "nvim") }
  @{ Source = (Join-Path $repoRoot "config\vim"); Target = (Join-Path $HOME ".vim") }
  @{ Source = (Join-Path $repoRoot "config\ideavim\.ideavimrc"); Target = (Join-Path $HOME ".ideavimrc") }
  @{ Source = (Join-Path $repoRoot "config\vsvim\.vsvimrc"); Target = (Join-Path $HOME ".vsvimrc") }
  @{ Source = (Join-Path $repoRoot "config\vsvim\.vsvimrc"); Target = (Join-Path $HOME "_vsvimrc") }
  @{ Source = (Join-Path $repoRoot "config\windows-terminal\settings.json"); Target = (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json") }
  @{ Source = (Join-Path $repoRoot "config\windows-terminal\settings.json"); Target = (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json") }
)

foreach ($pair in $pairs) {
  if (-not (Test-Path -LiteralPath $pair.Source)) { return $false }
  if (-not (Test-Path -LiteralPath $pair.Target)) { return $false }
  $item = Get-Item -LiteralPath $pair.Target -Force

  if ($item.LinkType -eq "SymbolicLink" -or $item.LinkType -eq "Junction") {
    try {
      $resolvedTarget = (Resolve-Path -LiteralPath $pair.Target).Path
    } catch {
      return $false
    }
    $resolvedSource = (Resolve-Path -LiteralPath $pair.Source).Path
    if ($resolvedTarget -ne $resolvedSource) { return $false }
    continue
  }

  if ($item.LinkType -eq "HardLink") {
    $resolvedSource = (Resolve-Path -LiteralPath $pair.Source).Path
    $hardLinks = @(Get-Item -LiteralPath $pair.Target -Force | Select-Object -ExpandProperty Target)
    if ($hardLinks -notcontains $resolvedSource) { return $false }
    continue
  }

  return $false
}

return $true
