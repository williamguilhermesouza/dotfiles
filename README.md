# dotfiles
![Repo-size](https://img.shields.io/github/repo-size/williamguilhermesouza/dotfiles)
![Last-commit](https://img.shields.io/github/last-commit/williamguilhermesouza/dotfiles)

My personal dotfiles with plugins and configuration.

## Clone

```bash
git clone https://github.com/williamguilhermesouza/dotfiles.git
cd dotfiles
```

## Windows

### 1) Set up environment variables and PATH
Run the dev env bootstrap once in PowerShell to make `DEV_ENV` permanent and add `windows/scripts` to your user `PATH`:

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\dev_env.ps1
```

Open a new PowerShell session after this step.

### 2) Apply environment (set)
Use the run script from anywhere:

```powershell
run setenv
```

This runs `winget configure` with `windows/dsc/configuration.dev.dsc.yaml` (installs apps and links managed dotfiles).

### 3) Reset environment (unset)
To undo the applied environment safely:

```powershell
run unsetenv
```

This runs `winget configure` with `windows/dsc/configuration.reset.dsc.yaml` (removes managed config links, restores backups when available, and does not uninstall applications).
