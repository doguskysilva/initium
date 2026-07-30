# initium

Personal bootstrap for setting up a fresh machine with a full dev + GNOME
desktop environment, regardless of the Linux distro. The goal: start from a
clean install and end up with an identical setup every time.

## Status

| OS      | Status      |
|---------|-------------|
| Ubuntu  | In progress |
| Fedora  | Planned     |
| Arch    | Planned     |

All three target GNOME as the desktop environment.

## Layout

| Script         | Purpose                                                              |
|----------------|-----------------------------------------------------------------------|
| `install.sh`   | Entry point. Detects the OS (via `/etc/os-release`) and dispatches.  |
| `apt.sh`       | Ubuntu/Debian: system update, essential packages, `fd` symlink.      |
| `fedora.sh`    | Fedora equivalent of `apt.sh` (not implemented yet).                 |
| `arch.sh`      | Arch equivalent of `apt.sh` (not implemented yet).                   |
| `dotfiles.sh`  | Clones/updates [dotfiles](https://github.com/doguskysilva/dotfiles) and applies it with GNU Stow. |
| `dev.sh`       | Cross-OS: Oh My Zsh, default shell, mise, Node.js (LTS) and PHP 8.4.  |
| `fonts.sh`     | Cross-OS: installs JetBrainsMono/FiraCode Nerd Fonts + official JetBrains Mono. |
| `gnome.sh`     | GNOME extensions, dconf settings, theming (not implemented yet).     |

## Usage

```bash
./install.sh
```

This runs the OS-specific setup first, then the cross-OS steps
(`dotfiles.sh`, `dev.sh`, `fonts.sh`, `gnome.sh`) in that order.

## Notes

- The actual dotfiles (Neovim/LazyVim, tmux, zsh, starship, git config) live
  in a separate private repo, [dotfiles](https://github.com/doguskysilva/dotfiles),
  managed with [GNU Stow](https://www.gnu.org/software/stow/). `dotfiles.sh`
  clones it and stows each package.
- On Ubuntu, the `fd` binary ships as `fdfind`. Since LazyVim expects `fd`,
  `apt.sh` symlinks it into `~/.local/bin/fd`.
- This repo grows incrementally: scripts and docs are added as each part of
  the setup gets built and tested on real hardware.
- Every script is idempotent: safe to re-run `install.sh` (or any individual
  script) on a machine that's already been set up, without duplicating work
  or failing on things that already exist.
- `zsh-autosuggestions` and `zsh-syntax-highlighting` are installed as system
  packages in `apt.sh` (`/usr/share/zsh/plugins/...`), which is the path the
  dotfiles' `zshrc/.config/zsh/init` already expects.
- `fonts.sh` downloads fonts directly from GitHub releases (pinned versions)
  instead of distro packages, since patched Nerd Fonts aren't packaged on
  every distro. This keeps it identical across Ubuntu/Fedora/Arch. It
  installs Nerd Font builds of JetBrainsMono and FiraCode (for
  terminal/tmux/nvim/starship), plus the official unpatched JetBrains Mono
  (kept in reserve, e.g. as a GNOME UI font, decided in `gnome.sh`).
- Node.js and PHP are installed via `mise` (not distro packages), so
  `dev.sh` stays identical across Ubuntu/Fedora/Arch. `mise` compiles PHP
  from source (via `php-build`), so `apt.sh` includes its build
  dependencies (`autoconf`, `libxml2-dev`, etc.) alongside the essentials.
  There is no Laravel Herd on Linux (macOS/Windows only), so don't
  reintroduce a `herd-lite` PATH entry in the dotfiles' `.zshrc`.
