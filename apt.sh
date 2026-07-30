#!/usr/bin/env bash
set -euo pipefail

sudo apt update && sudo apt full-upgrade -y

sudo apt install -y build-essential git curl wget unzip ca-certificates \
  ripgrep fd-find fontconfig stow neovim vim tmux zsh \
  zsh-autosuggestions zsh-syntax-highlighting \
  fastfetch btop htop lazygit rlwrap starship zoxide fzf ghostty eza

# Build deps for compiling PHP from source via mise's php plugin (dev.sh).
# libgd-dev pulls in libpng/libjpeg/libwebp/libxpm/libfreetype for --enable-gd.
# libpq-dev enables pdo_pgsql (mise only adds it if pg_config exists at
# compile time), so it has to be installed before php is built.
sudo apt install -y autoconf bison gettext libcurl4-openssl-dev libedit-dev \
  libgd-dev libicu-dev libmysqlclient-dev libonig-dev libpq-dev \
  libqdbm-dev libreadline-dev libsodium-dev libsqlite3-dev libssl-dev \
  libxml2-dev libzip-dev pkg-config re2c zlib1g-dev

# Podman instead of Docker: works the same across Ubuntu/Fedora/Arch,
# rootless by default, and Fedora doesn't ship Docker Engine in its repos.
# podman-docker aliases the docker CLI to podman for tools that expect it.
sudo apt install -y podman podman-docker podman-compose

# Silences podman-docker's "Emulate Docker CLI using podman" notice on
# every docker command.
sudo touch /etc/containers/nodocker

# Ubuntu's neovim package registers itself as the "vim" alternative, so
# plain `vim` opens nvim. Point it back at the real vim instead.
real_vim="$(update-alternatives --list vim 2>/dev/null | grep -v nvim | head -1)"
[ -n "$real_vim" ] && sudo update-alternatives --set vim "$real_vim"

# VS Code: not in Ubuntu's repos, official Microsoft-recommended install
# is their own apt repo (avoids the snap build).
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
  | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f /tmp/packages.microsoft.gpg

sudo apt update
sudo apt install -y code

# gh: Ubuntu's repo is far behind upstream, so use GitHub's own apt repo
# (their recommended install method) instead.
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor > /tmp/githubcli-archive-keyring.gpg
sudo install -D -o root -g root -m 644 /tmp/githubcli-archive-keyring.gpg /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
rm -f /tmp/githubcli-archive-keyring.gpg

sudo apt update
sudo apt install -y gh

# No Ubuntu o binario do fd chama fdfind; o LazyVim espera fd
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
