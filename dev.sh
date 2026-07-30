#!/usr/bin/env bash
set -euo pipefail

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ "$(basename "$SHELL")" != "zsh" ]; then
  sudo chsh -s "$(command -v zsh)" "$USER"
fi

if ! command -v mise &> /dev/null; then
  curl https://mise.run | sh
fi

export PATH="$HOME/.local/bin:$PATH"

mise use -g node@lts

# Ubuntu's libgd-dev ships no gdlib pkg-config file, which PHP's configure
# needs to detect the system GD library, so the gd extension is disabled.
PHP_EXTRA_CONFIGURE_OPTIONS="--disable-gd" mise use -g php@8.4

mise use -g rust@latest
mise use -g go@latest

# Clojure's CLI just shells out to java, and Leiningen needs it too.
mise use -g java@temurin-25
mise use -g clojure@latest
mise use -g leiningen@latest

# The lein script mise installs ships with a hardcoded LEIN_VERSION that
# doesn't match the jar it actually downloaded, pointing at a snapshot
# build that no longer exists upstream. Patch it to the real version.
lein_bin="$(mise which lein)"
lein_dir="$(dirname "$(dirname "$lein_bin")")"
jar_file="$(ls "$lein_dir"/self-installs/*-standalone.jar | head -1)"
actual_version="$(basename "$jar_file" | sed -E 's/^leiningen-(.+)-standalone\.jar$/\1/')"
sed -i "s/^export LEIN_VERSION=.*/export LEIN_VERSION=\"${actual_version}\"/" "$lein_bin"

if ! command -v uv &> /dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

uv python install 3.14
uv python pin --global 3.14

# COMPOSER_HOME is pinned via dotfiles' zsh envs so it doesn't move when
# mise bumps the PHP patch version (see readme notes).
export COMPOSER_HOME="$HOME/.config/composer"
composer global show laravel/installer &> /dev/null || composer global require laravel/installer

# Podman's user-level API socket is what docker-compose-v2 (installed by
# podman-compose, and delegated to by both `podman compose` and the
# podman-docker `docker compose` alias) talks to. Needed for Sail etc.
systemctl --user enable --now podman.socket

# lazydocker isn't packaged on Ubuntu, so it's downloaded directly like
# fonts.sh does for Nerd Fonts, keeping it identical across distros.
LAZYDOCKER_VERSION="0.25.2"
if ! command -v lazydocker &> /dev/null; then
  tmp_dir="$(mktemp -d)"
  curl -fLo "$tmp_dir/lazydocker.tar.gz" \
    "https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
  tar -xzf "$tmp_dir/lazydocker.tar.gz" -C "$tmp_dir" lazydocker
  mv "$tmp_dir/lazydocker" "$HOME/.local/bin/lazydocker"
  rm -rf "$tmp_dir"
fi
