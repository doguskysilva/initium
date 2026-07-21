#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Developer/dotfiles}"

if [ ! -d "$DOTFILES_DIR" ]; then
  git clone git@github.com:doguskysilva/dotfiles.git "$DOTFILES_DIR"
else
  git -C "$DOTFILES_DIR" pull --ff-only
fi

cd "$DOTFILES_DIR"
stow -t ~ nvim tmux zshrc starship scripts git
