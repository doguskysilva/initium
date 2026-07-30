#!/usr/bin/env bash
set -euo pipefail

NERD_FONTS_VERSION="v3.4.0"
JETBRAINS_MONO_VERSION="2.304"
FONTS_DIR="$HOME/.local/share/fonts"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

install_nerd_font() {
  local name="$1"
  local dir="$FONTS_DIR/${name}NerdFont"
  [ -d "$dir" ] && return

  curl -fLo "$tmp_dir/${name}.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}/${name}.zip"
  mkdir -p "$dir"
  unzip -q -o "$tmp_dir/${name}.zip" -d "$dir"
}

install_nerd_font "JetBrainsMono"
install_nerd_font "FiraCode"

official_dir="$FONTS_DIR/JetBrainsMono"
if [ ! -d "$official_dir" ]; then
  curl -fLo "$tmp_dir/JetBrainsMono-official.zip" \
    "https://github.com/JetBrains/JetBrainsMono/releases/download/v${JETBRAINS_MONO_VERSION}/JetBrainsMono-${JETBRAINS_MONO_VERSION}.zip"
  mkdir -p "$official_dir"
  unzip -q -o "$tmp_dir/JetBrainsMono-official.zip" -d "$official_dir"
fi

fc-cache -f "$FONTS_DIR"
