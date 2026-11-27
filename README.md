# Dotfiles

Personal WSL2 / Ubuntu configuration files managed with GNU Stow (configuration files only — no binaries, wrappers, or secrets).

## Stowed Packages

- `zsh`: `~/.zshrc` (shell options, aliases, functions, guarded tool/plugin initialization)
- `git`: `~/.gitconfig` and `~/.config/git/ignore` (global gitignore)
- `tmux`: `~/.tmux.conf` (prefix `C-a`, keybindings, statusline, TPM plugins)
- `starship`: `~/.config/starship.toml` (minimal prompt theme)
- `nvim`: `~/.config/nvim` (Neovim `>= 0.11` config with `lazy.nvim` & Mason)
- `vim`: `~/.vimrc` (minimal keymaps)
- `readline`: `~/.inputrc` (`\C-w` / `\C-h` readline bindings)
- `btop`: `~/.config/btop/btop.conf` (btop layout and process sorting settings)
- `gh`: `~/.config/gh/config.yml` only (`~/.config/gh/hosts.yml` stays untracked locally for auth tokens)

> **Security note:** Never commit credentials, tokens, or `hosts.yml` / `.git-credentials` / `~/.config/secrets/env.zsh`.

## Where Tool Configs Live

Tools without standalone config files are configured inside the stowed packages and local binaries:

- **eza**: `ls`, `ll`, `la`, `lt`, and `ltree` aliases in `zsh/.zshrc` (falls back to standard `ls` aliases if `eza` is missing).
- **fzf**: Completion and keybindings sourced in `zsh/.zshrc`; Neovim pickers configured in `nvim/.config/nvim/lua/plugins/fzf.lua` and `nvim/.config/nvim/lua/plugins/telescope.lua`.
- **ripgrep (`rg`)**: Used by Neovim's Telescope (`live_grep`) and `fzf-lua` (no standalone `~/.ripgreprc`).
- **fd-find (`fdfind` / `fd`)**: `~/.local/bin/fd` symlink (created by `install.sh` pointing to `fdfind`), plus a guarded `fd='fdfind'` fallback alias in `zsh/.zshrc`.

## Fresh-Machine Quickstart

`git` is a prerequisite on a brand-new machine. Clone the repository and run `./install.sh` from inside `~/dotfiles` (or from any directory):

```bash
git clone https://github.com/uday1402/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` installs required APT packages, upstream binaries (`neovim >= 0.11`, `starship`, `lazygit`, `uv`, `yazi`, `node`/`npm`), backs up any conflicting live files, stows all config packages, installs TPM plugins, and syncs Neovim plugins.

### `install.sh` Flags

| Flag | Description |
| --- | --- |
| `--configs-only` | Alias `--stow-only`. Skip package/binary/plugin installs and `chsh`; only ensure parent dirs, create the `fd` symlink if `fdfind` exists, back up conflicting targets, and stow all conf packages. |
| `--dry-run` | Print every action that would happen without modifying the filesystem, creating backup directories, or invoking `sudo`. |
| `--skip-nvim-sync` | Skip headless Neovim (`+Lazy! sync`) plugin bootstrap. |
| `--skip-chsh` | Skip changing the default login shell to `zsh`. |
| `--target DIR` | Override the target home directory (defaults to `$HOME`). |
| `-h`, `--help` | Print usage help and exit. |

## Changing Dotfiles

- All stowed files live in `~/dotfiles/<package>/...` and are symlinked into `$HOME`.
- Edit the files inside `~/dotfiles` (or through their symlinked target path) — both point to the same file.
- Run `./install.sh --configs-only` after adding new files to an existing package.
- Commit and push from `~/dotfiles` (`git status` first to ensure no secrets or stray artifacts are staged).
