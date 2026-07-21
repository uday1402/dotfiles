#!/usr/bin/env bash

# check README.md for bootstrapping instructions

set -e

echo "Installing dotfiles..."

# Install stow if missing
if ! command -v stow &> /dev/null
then
    echo "Installing stow..."
    sudo apt update
    sudo apt install stow -y
fi


echo "Creating symlinks..."

stow zsh
stow git
stow tmux
stow starship
stow nvim


echo "Dotfiles installed successfully."
