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

# dev.sh installs Ruby precompiled (no build needed), but common gems'
# native extensions still want these (ffi, psych, etc.). sqlite3 (the
# CLI, not just libsqlite3-dev above) is also here since Rails defaults
# to SQLite.
sudo apt install -y patch libyaml-dev libgmp-dev libncurses-dev libffi-dev \
  libgdbm-dev libgdbm-compat-dev libdb-dev uuid-dev sqlite3

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

# GNOME tools + Flatpak (gnome.sh handles the rest: Flathub remote,
# extensions, dconf).
sudo apt install -y gnome-tweaks gnome-shell-extension-manager \
  dconf-editor gnome-sushi flatpak gnome-software-plugin-flatpak

# Everyday apps: office suite, video player, and Ubuntu's codec/font
# bundle (VLC bundles its own codecs, but this covers GNOME's default
# players, Firefox, etc. too).
sudo apt install -y libreoffice vlc ubuntu-restricted-extras

# Google Chrome: own apt repo, their recommended install method.
wget -qO- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /tmp/google-chrome.gpg
sudo install -D -o root -g root -m 644 /tmp/google-chrome.gpg /etc/apt/keyrings/google-chrome.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
  | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
rm -f /tmp/google-chrome.gpg

sudo apt update
sudo apt install -y google-chrome-stable

# 1Password + CLI: their own apt repo (not a standalone .deb, so it
# auto-updates via apt like everything else here). Includes their
# debsig signature policy, per their official install instructions.
wget -qO- https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor > /tmp/1password-archive-keyring.gpg
sudo install -D -o root -g root -m 644 /tmp/1password-archive-keyring.gpg /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" \
  | sudo tee /etc/apt/sources.list.d/1password.list > /dev/null
rm -f /tmp/1password-archive-keyring.gpg

sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22
wget -qO- https://downloads.1password.com/linux/debian/debsig/1password.pol \
  | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol > /dev/null

sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
wget -qO- https://downloads.1password.com/linux/keys/1password.asc \
  | gpg --dearmor | sudo tee /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg > /dev/null

sudo apt update
sudo apt install -y 1password 1password-cli

# No Ubuntu o binario do fd chama fdfind; o LazyVim espera fd
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
