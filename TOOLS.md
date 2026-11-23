This file contains an extensive description of the complete tooling setup for my configuration.

CONTENTS:
[Terminal](#Terminal)

# Terminal
Native Windows Terminal used, with WSL2 as the default profile.

zsh Shell is used, along with secondary bash shell.

# eza for listing
use la, ls, ll, ltree, which are aliased to run the eza commands

# Using fd-find Tool
fd main                  # Find files containing 'main'
fd '\.c$'                # Find C files
fd -e py                 # Find Python files
fd -t d                  # Find directories only
fd -H                    # Include hidden files
fd -I                    # Include ignored files
fd -e c -x wc -l         # Count lines in every C file

# Obsidian
Wrapper for Obsidian CLI was built with the help of Opus 4.6, and `obcp` command copies the argument file into the vault location on Windows, so you can access it with CLI or Obsidian app itself.
