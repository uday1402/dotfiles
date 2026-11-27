# Tooling Reference

Complete reference for the terminal, shell, CLI, and editor tooling used in this WSL2 / Ubuntu setup.

## Terminal & Shell

- **Windows Terminal + WSL2**: Primary terminal environment running Ubuntu on WSL2 (recommended to configure a Nerd Font in Windows Terminal for Starship, `eza`, and Neovim icons).
- **zsh** (`zsh/.zshrc`): Default interactive shell with `zsh-autosuggestions` and `zsh-syntax-highlighting`, shared history, `AUTO_CD`/`AUTO_PUSHD`, WSL `help` builtin wrapper, `obcp` vault helper, and `y` Yazi cwd wrapper.
- **readline** (`readline/.inputrc`): Configures `\C-w` (`backward-kill-word`) and `\C-h` (`backward-delete-char`) across readline-based CLI tools.
- **starship** (`starship/.config/starship.toml`): Minimal single-line prompt showing directory, git branch/status, Python virtualenv, and prompt character; initialized in `zsh/.zshrc`.
- **tmux** (`tmux/.tmux.conf`): Terminal multiplexer with `C-a` prefix, mouse support, `|` / `-` splits preserving current path, `Alt+Arrow` pane navigation, `Ctrl+Arrow` resizing, vi copy-mode, and TPM plugins (`tmux-sensible`, `tmux-resurrect`, `tmux-continuum`).

## CLI Navigation, Search & Listing

- **eza**: Modern `ls` replacement configured via aliases in `zsh/.zshrc` (with standard `ls` fallbacks if `eza` is absent):
  - `ls` — `eza --icons --group-directories-first`
  - `ll` — `eza -lah --icons --group-directories-first --git`
  - `la` — `eza -a --icons --group-directories-first`
  - `lt` — `eza --tree --level=2 --icons`
  - `ltree` — `eza --tree --icons`
- **fzf**: Interactive fuzzy finder; shell completion and keybindings are sourced in `zsh/.zshrc` (via `/usr/share/doc/fzf/examples/` or `fzf --zsh` on newer builds), and integrated into Neovim via `fzf-lua` and `telescope-fzf-native.nvim`.
- **ripgrep (`rg`)**: Fast recursive search backend used by Neovim's Telescope (`<leader>fg`) and `fzf-lua` (no standalone `~/.ripgreprc`).
- **fd-find (`fdfind` / `fd`)**: Fast `find` alternative. Exposed as `fd` via `~/.local/bin/fd -> /usr/bin/fdfind` (with a guarded `fd='fdfind'` alias fallback in `zsh/.zshrc`):
  - `fd main` — Find files matching `main`
  - `fd '\.c$'` / `fd -e py` — Filter by regex or extension
  - `fd -t d` — Directories only
  - `fd -H` / `fd -I` — Include hidden / gitignored files
  - `fd -e c -x wc -l` — Execute command per match
- **zoxide**: Smarter `cd` (`z`) initialized in `zsh/.zshrc` and used by `vaultSync` and `ml` aliases.

## Editors, Git & File Management

- **neovim** (`nvim/.config/nvim/`): Primary editor (`>= 0.11`, installed from official release tarball because config uses `vim.lsp.config`). Bootstraps `lazy.nvim`, Mason (LSPs, formatters, linters, DAP adapters), Telescope, `fzf-lua`, Treesitter, and `toggleterm.nvim`.
- **vim** (`vim/.vimrc`): Lightweight fallback editor config with `jk -> <Esc>`, `H -> ^`, and `L -> $`.
- **lazygit**: Terminal UI for git, usable standalone or inside Neovim via `<leader>gg` (`toggleterm.lua` floating window).
- **yazi**: Terminal file manager, launched via the `y` shell function in `zsh/.zshrc` so exiting Yazi updates the shell's working directory.
- **gh**: GitHub CLI configured in `gh/.config/gh/config.yml` (`git_protocol: https`, `co: pr checkout`). Authentication state remains local in `~/.config/gh/hosts.yml`.

## System Monitoring, Runtimes & Local WSL Helpers

- **btop**: Resource monitor configured in `btop/.config/btop/btop.conf` (`proc_sorting = "command"`, `proc_tree = True`).
- **fastfetch**: Fast system information summary tool (stock defaults).
- **uv**: Fast Python package and project manager (`~/.local/bin/uv` + `~/.local/bin/env`), used by the `jupyter` alias (`uv run jupyter lab`) and Python/DAP tooling (`debugpy`).
- **obsidian (local WSL wrapper)**: `~/.local/bin/obsidian` is a local, non-stowed WSL wrapper script that translates Linux/WSL paths via `wslpath` and forwards arguments to Windows `Obsidian.com`. Alongside it, the `obcp` function in `zsh/.zshrc` copies files directly into the Windows AlphaOS vault inbox.
