#!/usr/bin/env bash
set -euo pipefail

sudo apt update && sudo apt full-upgrade -y

sudo apt install -y build-essential git curl wget unzip ca-certificates \
  ripgrep fd-find fontconfig stow neovim tmux zsh \
  zsh-autosuggestions zsh-syntax-highlighting

# No Ubuntu o binario do fd chama fdfind; o LazyVim espera fd
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
