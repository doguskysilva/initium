#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. /etc/os-release

case "$ID" in
  ubuntu|debian)
    "$SCRIPT_DIR/apt.sh"
    ;;
  fedora)
    "$SCRIPT_DIR/fedora.sh"
    ;;
  arch)
    "$SCRIPT_DIR/arch.sh"
    ;;
  *)
    echo "SO nao suportado: $ID" >&2
    exit 1
    ;;
esac

"$SCRIPT_DIR/dotfiles.sh"
"$SCRIPT_DIR/dev.sh"
"$SCRIPT_DIR/fonts.sh"
"$SCRIPT_DIR/gnome.sh"
