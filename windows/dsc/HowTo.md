From the repo root, apply the Winget Configure YAML:

```powershell
winget configure -f .\windows\dsc\configuration.dev.dsc.yaml --accept-configuration-agreements
```

This configuration enforces:
- Winget packages: `Microsoft.WindowsTerminal`, `glzr-io.glazewm`, `sxyazi.yazi`
- Dotfile links for: Neovim, Vim, IdeaVim, VsVim, Windows Terminal settings

Run the same command again any time to converge back to the desired state.

To undo the dev configuration safely (idempotent reset):

```powershell
winget configure -f .\windows\dsc\configuration.reset.dsc.yaml --accept-configuration-agreements
```

Reset behavior:
- Removes only dotfile targets that are links managed by this repo.
- Restores previous backups (`*.backup.YYYYMMDDHHMMSS`) when available.
- Uninstalls packages managed by dev config if installed.
- If nothing was previously configured, it does nothing.
