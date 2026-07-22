# Managed by dotfiles.

# set to log times
$DEBUG = 0

if ($DEBUG -eq 1) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $swTotal = [System.Diagnostics.Stopwatch]::StartNew()
}

# Load the Z module so `z` is available in new PowerShell sessions.
# if (Get-Module -ListAvailable -Name Z -ErrorAction SilentlyContinue) {
#   Import-Module Z -ErrorAction SilentlyContinue
# }
# if ($DEBUG -eq 1) {
#     "Import Z: $($sw.ElapsedMilliseconds) ms"
#     $sw.Restart()
# }

if (Get-Command -Name z -ErrorAction SilentlyContinue) {
  Set-Alias -Name cd -Value z -Option AllScope -Force
}

Set-Alias -Name cat -Value bat -Option AllScope -Force

# Path to the cached carapace completion init script. Kept in LOCALAPPDATA
# (not TEMP) so Windows Storage Sense / Disk Cleanup never wipes it -- a wiped
# cache forces a ~750ms regeneration on the next new shell (the intermittent
# "Loading personal and system profiles took ..." slow tab).
function Get-CarapaceCachePath
{
	return Join-Path $env:LOCALAPPDATA 'carapace\init.ps1'
}

# Regenerates the cached carapace init script. Call this after carapace is
# upgraded (the winget DSC config does it automatically on `winget configure`),
# or any time completions look stale. The profile also self-heals: if the
# cache file is missing on startup it is generated once.
function Update-CarapaceCache
{
	[CmdletBinding()]
	param()

	if (-not (Get-Command carapace -ErrorAction SilentlyContinue)) {
		Write-Host "carapace not found on PATH; cannot build completion cache." -ForegroundColor Red
		return
	}

	$cachePath = Get-CarapaceCachePath
	$cacheDir = Split-Path $cachePath -Parent
	if (-not (Test-Path $cacheDir)) {
		New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
	}

	carapace _carapace | Out-String | Set-Content -LiteralPath $cachePath
	Write-Host "carapace cache written to: $cachePath" -ForegroundColor Green
}

# PSReadLine key-handler entry point: opens the history picker and
# replaces the current input line with the selected command.
function Set-HistoryCommandLine
{
	$currentLine = $null
	$cursor = $null
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$currentLine, [ref]$cursor)

	$command = Select-HistoryCommand -Query $currentLine

	[Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()

	if ($command) {
		[Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
		[Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
	}
}

# Picks a command from PSReadLine's saved history via fzf.
#
# Implementation notes:
# - Uses temp files + `cmd /c` redirection because piping directly into
#   `fzf` from a PSReadLine key handler was unreliable in our setup.
# - Skips `--height` on purpose: fzf rejects it when stdin/stdout are
#   redirected ("--height option is currently not supported on this
#   platform"), causing a silent exit and a blank picker.
function Select-HistoryCommand
{
	param (
		[string]$Query
	)

	if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
		return $null
	}

	$historyPath = (Get-PSReadLineOption).HistorySavePath
	if (-not (Test-Path -LiteralPath $historyPath)) {
		return $null
	}

	$lines = [System.IO.File]::ReadAllLines($historyPath)
	$history = [System.Collections.Generic.List[string]]::new()
	$seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
	for ($i = $lines.Length - 1; $i -ge 0; $i--) {
		$line = $lines[$i]
		if (-not [string]::IsNullOrWhiteSpace($line) -and $seen.Add($line)) {
			$history.Add($line)
		}
	}

	if ($history.Count -eq 0) {
		return $null
	}

	$tempIn = [System.IO.Path]::GetTempFileName()
	$tempOut = [System.IO.Path]::GetTempFileName()
	try {
		$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
		[System.IO.File]::WriteAllLines($tempIn, $history, $utf8NoBom)

		$queryPart = ''
		if (-not [string]::IsNullOrEmpty($Query)) {
			$escaped = $Query -replace '"', '\"'
			$queryPart = " --query=`"$escaped`""
		}

		$cmdLine = "fzf --layout=reverse --border --no-sort$queryPart < `"$tempIn`" > `"$tempOut`""
		& cmd /c $cmdLine | Out-Null

		if (Test-Path -LiteralPath $tempOut) {
			$selection = [System.IO.File]::ReadAllText($tempOut).TrimEnd("`r", "`n")
			if ($selection) {
				return $selection
			}
		}

		return $null
	}
	finally {
		Remove-Item -LiteralPath $tempIn, $tempOut -ErrorAction SilentlyContinue
	}
}

if ($host.Name -eq 'ConsoleHost')
{
	$psReadLineCommand = Get-Command -Name Set-PSReadLineOption -ErrorAction SilentlyContinue
	if ($psReadLineCommand) {
		Set-PSReadLineOption -EditMode Windows

		if ($psReadLineCommand.Parameters.ContainsKey("PredictionViewStyle")) {
			Set-PSReadLineOption -PredictionViewStyle ListView
		}

		if ($psReadLineCommand.Parameters.ContainsKey("PredictionSource")) {
			Set-PSReadLineOption -PredictionSource HistoryAndPlugin
		}

		try {
			Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
		} catch {
		}

		Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
        Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock { Set-HistoryCommandLine }
	}

    if ($DEBUG -eq 1) {
	   "PSReadLine: $($sw.ElapsedMilliseconds) ms"
	   $sw.Restart()
    }

    # Fast path: if the cache exists, just load it -- no per-startup staleness
	# check (the old Get-Command + two Get-Item calls cost ~100ms every shell).
	# Freshness is handled out-of-band by Update-CarapaceCache (manual or via the
	# winget DSC config). If the cache is missing, generate it once here.
	# NOTE: this dot-source is intentionally synchronous. Deferring it via an
	# OnIdle engine event was tried and rejected: event actions run in a child
	# job scope, so carapace's Register-ArgumentCompleter calls never reach the
	# session, breaking Tab completion.
	$carapaceCache = Get-CarapaceCachePath
	if (-not (Test-Path -LiteralPath $carapaceCache)) {
		Update-CarapaceCache
	}
	if (Test-Path -LiteralPath $carapaceCache) {
		. $carapaceCache
	}

    if ($DEBUG -eq 1) {
	   "Carapace: $($sw.ElapsedMilliseconds) ms"
	   $sw.Restart()
    }
}

function OpenGlazeConfig {

    if (-not $env:DEV_ENV) {
        throw "DEV_ENV environment variable is not set."
    }

    nvim $env:DEV_ENV\dotfiles\config\glazewm\config.yaml
}

Set-Alias ogc OpenGlazeConfig


function OpenVimConfig {
    if (-not $env:DEV_ENV) {
        throw "DEV_ENV environment variable is not set."
    }

    nvim $env:DEV_ENV\dotfiles\config\vim\init.vim
}

Set-Alias ovc OpenVimConfig

if ($DEBUG -eq 1) {
    "PS Profile load: $($swTotal.ElapsedMilliseconds) ms"
}
