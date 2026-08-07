# Created by newuser for 5.9
#the line below sources the openrouter api key which is stored inside a local file
# ----------------------------
# History
# ----------------------------
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY
setopt AUTO_CD
# Show directories with a trailing slash in filename generation and completion.
setopt MARK_DIRS
setopt INTERACTIVE_COMMENTS

# ----------------------------
# Completion
# ----------------------------
autoload -Uz compinit
compinit

# ----------------------------
# Better navigation
# ---------------------------
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# ----------------------------
# Editor
# ----------------------------
export EDITOR=nvim
export VISUAL=nvim

# ----------------------------
# Aliases
# ----------------------------
alias vim="nvim"
alias vi="nvim"
alias ls="ls -p"
alias ll="ls -lah"
alias la="ls -A"
alias l="ls -C"
alias notes='cd "/mnt/c/Users/udays_5dfwue0/Developer/Obsidian Vault/ApexOS/" && nvim'

# TaskCLI project
alias task='cd "/home/ud_1402/projects/TaskCLI" && uv run main.py'

# ----------------------------
# help (bash-like help for shell builtins)
# ---------------------------
# zsh has no `help` builtin (it is bash-specific), and on WSL the Windows
# directory /mnt/c/Windows/Help shadows the name via the case-insensitive
# /mnt/c mount, so `help` fails with "permission denied". This function
# resolves before PATH lookup, defeating the shadow, and prints zsh's
# per-builtin help text from $HELPDIR (falling back to run-help/man).
autoload -Uz run-help
autoload -Uz run-help-btrfs run-help-git run-help-ip run-help-openssl \
    run-help-p4 run-help-sudo run-help-svk run-help-svn
HELPDIR=${HELPDIR:-/usr/share/zsh/help}
help() {
    emulate -L zsh
    if [[ $# -eq 0 ]]; then
        print -- "Usage: help [pattern ...]"
        print -- "Builtins with help text:"
        print -rC1 $HELPDIR/*(:t)
        return 0
    fi
    local t="$1"
    [[ $t == "." ]] && t=dot
    [[ $t == ":" ]] && t=colon
    if [[ -r "$HELPDIR/$t" ]]; then
        cat "$HELPDIR/$t"
        return 0
    fi
    run-help "$@"
}

# ----------------------------
# Prompt
# ---------------------------
autoload -Uz colors
colors

# eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# fzf
source /usr/share/doc/fzf/examples/completion.zsh
source /usr/share/doc/fzf/examples/key-bindings.zsh

# zsh plugins
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

autoload -Uz select-word-style
select-word-style shell

bindkey '^H' backward-kill-word

# Ctrl+Arrow key bindings for word-by-word navigation
bindkey '^[[1;5D' backward-word # Ctrl+Left
bindkey '^[[1;5C' forward-word  # Ctrl+Right
# Alternative key codes for different terminals
bindkey '^[[5D' backward-word   # Ctrl+Left (alternative)
bindkey '^[[5C' forward-word    # Ctrl+Right (alternative)
bindkey '^[[1;3D' backward-word # Alt+Left (some terminals)
bindkey '^[[1;3C' forward-word  # Alt+Right (some terminals)

. "$HOME/.local/bin/env"

# openrouter claude cli integration
export PATH="$HOME/.npm-global/bin:$PATH"
[[ -f "$HOME/.config/secrets/env.zsh" ]] &&
    source "$HOME/.config/secrets/env.zsh"
