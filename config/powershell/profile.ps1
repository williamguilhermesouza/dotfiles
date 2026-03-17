# Managed by dotfiles.
# Load the Z module so `z` is available in new PowerShell sessions.
if (Get-Module -ListAvailable -Name Z -ErrorAction SilentlyContinue) {
  Import-Module Z -ErrorAction SilentlyContinue
}

if (Get-Command -Name z -ErrorAction SilentlyContinue) {
  Set-Alias -Name cd -Value z -Option AllScope -Force
}

Set-Alias -Name bat -Value cat -Option AllScope -Force
