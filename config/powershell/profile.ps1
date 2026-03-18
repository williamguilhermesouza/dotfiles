# Managed by dotfiles.
# Load the Z module so `z` is available in new PowerShell sessions.
if (Get-Module -ListAvailable -Name Z -ErrorAction SilentlyContinue) {
  Import-Module Z -ErrorAction SilentlyContinue
}

if (Get-Command -Name z -ErrorAction SilentlyContinue) {
  Set-Alias -Name cd -Value z -Option AllScope -Force
}

Set-Alias -Name bat -Value cat -Option AllScope -Force

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
	}

	$carapaceCommand = Get-Command -Name carapace -ErrorAction SilentlyContinue
	if ($carapaceCommand) {
		$carapaceCache = "$env:TEMP\carapace_init.ps1"
		try {
			if (-not (Test-Path $carapaceCache) -or (Get-Item $carapaceCache).LastWriteTime -lt (Get-Item $carapaceCommand.Source).LastWriteTime) {
				carapace _carapace | Out-String | Set-Content $carapaceCache
			}

			if (Test-Path $carapaceCache) {
				. $carapaceCache
			}
		} catch {
		}
	}
}
