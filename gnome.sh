#!/usr/bin/env bash
set -euo pipefail

# Flathub, for day-to-day GUI apps.
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Podman Desktop: native Podman support (no Docker API emulation asterisks
# like lazydocker has), see readme notes.
flatpak install -y --noninteractive flathub io.podman_desktop.PodmanDesktop
