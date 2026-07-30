#!/usr/bin/env bash
set -euo pipefail

sudo apt update && sudo apt full-upgrade -y

sudo apt install -y build-essential git curl wget unzip ca-certificates \
  ripgrep fd-find fontconfig stow neovim tmux zsh \
  zsh-autosuggestions zsh-syntax-highlighting \
  fastfetch btop htop lazygit

# Build deps for compiling PHP from source via mise's php plugin (dev.sh).
# libgd-dev pulls in libpng/libjpeg/libwebp/libxpm/libfreetype for --enable-gd.
sudo apt install -y autoconf bison gettext libcurl4-openssl-dev libedit-dev \
  libgd-dev libicu-dev libmysqlclient-dev libonig-dev libqdbm-dev \
  libreadline-dev libsodium-dev libsqlite3-dev libssl-dev libxml2-dev \
  libzip-dev pkg-config re2c zlib1g-dev

# Podman instead of Docker: works the same across Ubuntu/Fedora/Arch,
# rootless by default, and Fedora doesn't ship Docker Engine in its repos.
# podman-docker aliases the docker CLI to podman for tools that expect it.
sudo apt install -y podman podman-docker podman-compose

# Silences podman-docker's "Emulate Docker CLI using podman" notice on
# every docker command.
sudo touch /etc/containers/nodocker

# No Ubuntu o binario do fd chama fdfind; o LazyVim espera fd
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
