#!/usr/bin/env bash
set -euo pipefail

sudo apt update && sudo apt full-upgrade -y

sudo apt install -y build-essential git curl wget unzip ca-certificates \
  ripgrep fd-find fontconfig stow neovim tmux zsh \
  zsh-autosuggestions zsh-syntax-highlighting \
  fastfetch btop htop

# Build deps for compiling PHP from source via mise/php-build (dev.sh)
sudo apt install -y autoconf bison libcurl4-openssl-dev libedit-dev \
  libonig-dev libqdbm-dev libreadline-dev libsodium-dev libsqlite3-dev \
  libssl-dev libxml2-dev pkg-config re2c zlib1g-dev

# No Ubuntu o binario do fd chama fdfind; o LazyVim espera fd
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
