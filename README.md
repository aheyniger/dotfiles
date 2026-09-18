# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/), targeting Windows, macOS, Linux, and WSL from a single source repo.

## Overview

- **Prompt:** [starship](https://starship.rs/) everywhere — PowerShell, Git Bash, WSL, Linux, macOS — styled to match the repo's original `[time] user@host path (git-branch)` blue/purple look. Config: [dot_config/starship.toml](dot_config/starship.toml).
- **Shell:** bash on Windows (Git Bash) and as a fallback everywhere; [zsh](https://www.zsh.org/) + [oh-my-zsh](https://ohmyz.sh/) as the primary interactive shell on Linux, macOS, and WSL.
- **Aliases/functions:** a single [dot_bash_aliases](dot_bash_aliases) file, sourced by both bash and zsh, so aliases stay consistent across shells and platforms.
- **Editor config:** shared VS Code `settings.json`, applied to whichever OS-specific path VS Code actually reads it from.
- **Git:** one templated [dot_gitconfig.tmpl](dot_gitconfig.tmpl), with `core.autocrlf` set per-OS (`true` on Windows, `input` elsewhere) so line endings don't get mangled on either side.

## Layout by OS

chezmoi applies every file below `$HOME` on every machine, but `.chezmoiignore` (see [.chezmoiignore](.chezmoiignore)) skips whole OS-specific subtrees that don't apply to the current platform, so no dead/empty directories get left behind.

### Windows

| Source | Applied to | Purpose |
|---|---|---|
| [dot_bash_aliases](dot_bash_aliases) | `~/.bash_aliases` | aliases/functions (Git Bash) |
| [dot_bash_prompt](dot_bash_prompt) | `~/.bash_prompt` | starship init for Git Bash |
| [dot_gitconfig.tmpl](dot_gitconfig.tmpl) | `~/.gitconfig` | git config (`autocrlf = true`) |
| [dot_config/starship.toml](dot_config/starship.toml) | `~/.config/starship.toml` | prompt config (read by starship on every platform, including native Windows) |
| [AppData/Roaming/Code/User/settings.json.tmpl](AppData/Roaming/Code/User/settings.json.tmpl) | `%APPDATA%\Code\User\settings.json` | VS Code settings |
| [Documents/Powershell/Microsoft.PowerShell_profile.ps1](Documents/Powershell/Microsoft.PowerShell_profile.ps1) | `$PROFILE` | starship init for PowerShell |

`Library`, `.config/Code`, and `.zshrc` are ignored on Windows.

### macOS (darwin)

| Source | Applied to | Purpose |
|---|---|---|
| [dot_bash_aliases](dot_bash_aliases) | `~/.bash_aliases` | aliases/functions |
| [dot_bash_prompt](dot_bash_prompt) | `~/.bash_prompt` | starship init for bash |
| [dot_zshrc](dot_zshrc) | `~/.zshrc` | oh-my-zsh + aliases + starship init for zsh |
| [dot_gitconfig.tmpl](dot_gitconfig.tmpl) | `~/.gitconfig` | git config (`autocrlf = input`) |
| [dot_config/starship.toml](dot_config/starship.toml) | `~/.config/starship.toml` | prompt config |
| [Library/Application Support/Code/User/settings.json.tmpl](Library/Application%20Support/Code/User/settings.json.tmpl) | `~/Library/Application Support/Code/User/settings.json` | VS Code settings |

`AppData`, `Documents`, and `.config/Code` are ignored on macOS.

### Linux / WSL

| Source | Applied to | Purpose |
|---|---|---|
| [dot_bash_aliases](dot_bash_aliases) | `~/.bash_aliases` | aliases/functions |
| [dot_bash_prompt](dot_bash_prompt) | `~/.bash_prompt` | starship init for bash |
| [dot_zshrc](dot_zshrc) | `~/.zshrc` | oh-my-zsh + aliases + starship init for zsh |
| [dot_gitconfig.tmpl](dot_gitconfig.tmpl) | `~/.gitconfig` | git config (`autocrlf = input`) |
| [dot_config/starship.toml](dot_config/starship.toml) | `~/.config/starship.toml` | prompt config |
| [dot_config/Code/User/settings.json.tmpl](dot_config/Code/User/settings.json.tmpl) | `~/.config/Code/User/settings.json` | VS Code settings |

`AppData`, `Documents`, and `Library` are ignored on Linux/WSL. chezmoi reports WSL as `linux`, so it's treated identically to a native Linux install.

### Automated on `chezmoi apply`

[.chezmoiscripts/run_once_before_install-zsh-and-starship.sh.tmpl](.chezmoiscripts/run_once_before_install-zsh-and-starship.sh.tmpl) runs once per machine, before other files are applied:

- Installs **starship** everywhere it's missing (via `winget` on Windows, `brew` on macOS/Linux if present, otherwise the official install script).
- On Linux/macOS/WSL only: installs **zsh** (via `apt`/`dnf`/`pacman`/`brew`, whichever is found) and **oh-my-zsh** (unattended, doesn't touch `.zshrc` or your default shell).

[.chezmoiscripts/run_onchange_after_setup-bash-hooks.sh](.chezmoiscripts/run_onchange_after_setup-bash-hooks.sh) runs on every apply where its content changes, and idempotently adds `source ~/.bash_aliases` / `source ~/.bash_prompt` lines to `~/.bashrc` if they're not already there.

## Setup NOT automated by chezmoi

A few things are deliberately left as manual, one-time steps rather than scripted, because they're either irreversible-ish, environment-specific, or best done with your eyes on it:

1. **Installing WSL itself** (Windows only, one-time):
   ```powershell
   wsl --install
   ```
   Run in an elevated PowerShell, then reboot when prompted.

2. **Installing chezmoi** on a new machine:
   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)"
   ```
   Note: this installs to `./bin/chezmoi`, relative to wherever you run it — not to a directory on `PATH` automatically. Move it somewhere durable, e.g.:
   ```bash
   sudo install -m 755 ./bin/chezmoi /usr/local/bin/chezmoi
   ```

3. **Pulling this repo down** on a new machine:
   ```bash
   chezmoi init --apply aheyniger/dotfiles
   ```

4. **Switching your default shell to zsh** (Linux/macOS/WSL). The install script deliberately does *not* run `chsh` automatically, so a bad shell install can't lock you out of a login shell on a fresh machine:
   ```bash
   chsh -s $(which zsh)
   ```
   Close and reopen your terminal for it to take effect.

5. **SSH keys for GitHub**, if you want to push from a new machine (not needed just to `chezmoi init --apply`, since this repo is public and clones over HTTPS). Reusing your existing key by copying it into the new machine's own `~/.ssh` is fine for WSL specifically, since it shares the same physical machine/trust boundary as Windows:
   ```bash
   mkdir -p ~/.ssh
   cp /mnt/c/Users/<you>/.ssh/id_ed25519 /mnt/c/Users/<you>/.ssh/id_ed25519.pub ~/.ssh/
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_ed25519
   chmod 644 ~/.ssh/id_ed25519.pub
   ```
   Don't reference the key directly from `/mnt/c/...` — NTFS-derived permissions there make OpenSSH refuse to use it.

6. **Installing VS Code itself**, and its `code` CLI (`Shell Command: Install 'code' command in PATH` from the command palette) — needed for `dot_gitconfig.tmpl`'s `editor = code --wait` and for `chezmoi edit` to work with the VS Code editor.

## Basic chezmoi usage

| Command | What it does |
|---|---|
| `chezmoi init --apply <github-user>/<repo>` | Clone this repo and apply it, in one step (first-time setup) |
| `chezmoi diff` | Preview what `chezmoi apply` would change, without changing anything |
| `chezmoi apply` | Apply the source state to your home directory |
| `chezmoi update` | `git pull` in the source dir, then `apply` — the normal way to pick up changes pushed from elsewhere |
| `chezmoi edit <file>` | Open the *source* file for a target (e.g. `chezmoi edit ~/.zshrc`) in your configured editor |
| `chezmoi cd` | Open a shell in the source directory (`~/.local/share/chezmoi`) |
| `chezmoi cat <target>` | Print what a target file would render to, without writing it |
| `chezmoi ignored` | List every path currently ignored on this machine |
| `chezmoi status` | Show a short summary of what `apply` would change |
| `chezmoi add <file>` | Start tracking an existing dotfile in the source state |

Typical day-to-day loop: edit files under `chezmoi cd`'s directory (or via `chezmoi edit`), run `chezmoi diff` to sanity-check, `chezmoi apply`, then commit and push from the source directory like any normal git repo. On other machines, `chezmoi update` picks the changes up.
