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
	Set-PSReadLineOption -EditMode Windows
	Set-PSReadLineOption -PredictionViewStyle ListView
	Set-PSReadLineOption -PredictionSource HistoryAndPlugin

	Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
	Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

	$carapaceCache = "$env:TEMP\carapace_init.ps1"
	if (-not (Test-Path $carapaceCache) -or (Get-Item $carapaceCache).LastWriteTime -lt (Get-Item (Get-Command carapace).Source).LastWriteTime) {
		carapace _carapace | Out-String | Set-Content $carapaceCache
	}
	. $carapaceCache
}
