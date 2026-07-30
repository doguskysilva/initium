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
| `apt.sh`       | Ubuntu/Debian: system update, essentials (incl. lazygit, Podman), `fd` symlink. |
| `fedora.sh`    | Fedora equivalent of `apt.sh` (not implemented yet).                 |
| `arch.sh`      | Arch equivalent of `apt.sh` (not implemented yet).                   |
| `dotfiles.sh`  | Clones/updates [dotfiles](https://github.com/doguskysilva/dotfiles) and applies it with GNU Stow. |
| `dev.sh`       | Cross-OS: Oh My Zsh, default shell, mise + language runtimes, Composer, Podman socket, lazydocker. |
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
  packages in `apt.sh`. The dotfiles' `zshrc/.config/zsh/init` checks both
  `/usr/share/<name>/` (this Ubuntu release) and `/usr/share/zsh/plugins/<name>/`
  (older/other distros), since the path isn't consistent.
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
- PHP's `gd` extension is disabled in `dev.sh` (`--disable-gd`): Ubuntu's
  `libgd-dev` ships no `gdlib` pkg-config file, which PHP's configure needs
  to detect the system GD library, so `--with-external-gd` can never
  succeed there. Revisit if a project actually needs GD.
- Rust, Go, Java (Temurin, LTS) and Clojure track `latest` in `mise`
  (like `node@lts`) rather than a pinned version, since they install from
  prebuilt binaries with no compile-time risk like PHP's. Java is only
  there because Clojure's CLI and Leiningen both shell out to it.
- The `lein` script mise/Leiningen installs ships with a hardcoded
  `LEIN_VERSION` pointing at a snapshot build that no longer exists
  upstream, unrelated to the jar actually downloaded. `dev.sh` patches
  that version string in place after install so `lein` works.
- Python is managed with `uv`, not `mise`, per preference. `uv` doesn't
  shim a global `python`/`python3` the way `mise` does for other
  languages — `uv python pin --global` only sets `uv`'s own fallback
  version. Use `uv run python`, `uv venv`, etc. to actually get it.
- Composer's global home (`COMPOSER_HOME`) is pinned to `~/.config/composer`
  via the dotfiles' zsh envs, instead of the version-nested default mise's
  PHP plugin picks (`.../php/8.4.24/.composer`). Otherwise every PHP patch
  bump would silently lose globally-required packages like the Laravel
  installer.
- Podman instead of Docker: Fedora doesn't ship Docker Engine in its repos
  while Podman is native there, and it works the same rootless way on all
  three targets. `podman-docker` aliases the `docker` CLI to Podman, and
  `podman-compose` pulls in the real `docker-compose-v2` plugin as an
  external compose provider — so `docker compose ...` (what Laravel Sail
  calls) works unmodified. This needs Podman's user API socket running
  (`systemctl --user enable --now podman.socket`, in `dev.sh`), which is
  what `docker-compose-v2` actually talks to. `apt.sh` also touches
  `/etc/containers/nodocker` to silence podman-docker's "Emulate Docker CLI
  using podman" notice on every `docker` invocation.
- Ubuntu wires apt's "command not found" suggestions into bash via
  `/etc/bash.bashrc` automatically, but not into zsh — `/etc/zsh_command_not_found`
  exists but needs an explicit `source`, which the dotfiles' `.zshrc` now
  does (guarded, since that file is Ubuntu/Debian-only).
- `lazygit` is packaged on Ubuntu, so it's in `apt.sh`. `lazydocker` isn't,
  so `dev.sh` downloads its binary directly from GitHub releases (pinned
  version), same approach as `fonts.sh`.
- PHP needs `libpq-dev` present *before* it's compiled to get `pdo_pgsql`
  (same "only if pkg-config/pg_config finds it" pattern as `gd`/`zip`), so
  it's in `apt.sh`'s PHP build deps alongside the others.
- Ubuntu's `neovim` package registers itself as the `vim` alternative, so
  plain `vim` opens nvim. `apt.sh` installs the real `vim` package and
  resets the alternative to it, since nvim/LazyVim and plain Vim are meant
  to stay separate (a `vim/.vimrc` dotfiles package holds a minimal,
  plugin-free config for quick edits).
- `dev.sh` also: clones TPM and installs tmux plugins (tmux.conf's own
  bootstrap only fetches TPM itself, not the plugins); runs `nvim --headless
  "+Lazy! sync"` so a fresh machine's LazyVim plugins are installed without
  opening nvim by hand; and force-installs `intelephense`/`pyright`/
  `clojure-lsp` via Mason, since LazyVim only installs LSP servers on
  demand when a matching filetype is opened (Mason itself is lazy-loaded,
  hence `require('lazy').load(...)` before `MasonInstall`).
