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
| `ia.sh`        | Cross-OS: Claude Code, Codex CLI, OpenCode, GitHub Copilot CLI.      |
| `fonts.sh`     | Cross-OS: installs JetBrainsMono/FiraCode Nerd Fonts + official JetBrains Mono. |
| `gnome.sh`     | Adds the Flathub remote. GNOME packages themselves (Tweaks, Extension Manager, dconf-editor, Sushi, Flatpak) are in `apt.sh`. Extensions/dconf/theming still to come. |

## Usage

```bash
./install.sh
```

This runs the OS-specific setup first, then the cross-OS steps
(`dotfiles.sh`, `dev.sh`, `ia.sh`, `fonts.sh`, `gnome.sh`) in that order.

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
- `starship`, `zoxide` and `fzf` are packaged on Ubuntu, so they're in
  `apt.sh` alongside lazygit/rlwrap. The dotfiles' zsh `init` already
  guards for their presence (`command -v ...`) before hooking them in, and
  `dotfiles.sh` already stows the `starship` config package — only the
  binaries themselves were missing.
- `dev.sh` explicitly runs `eval "$(mise activate bash)"` right after
  installing mise, so shims for everything installed afterward (composer,
  npm, ...) resolve within the script itself — previously they only
  resolved by accident, inherited from whatever shell happened to invoke
  the script.
- `ia.sh` installs each AI CLI the way its own platform recommends:
  Claude Code and OpenCode via their official install scripts, Codex and
  GitHub Copilot CLI via npm (`@openai/codex`, `@github/copilot`). Some of
  these installers append their own PATH line directly to the dotfiles'
  `.zshrc` (e.g. OpenCode) — expected, not something to revert.
- Ghostty and VS Code are desktop apps but still OS-package-manager
  installs, so they live in `apt.sh` like everything else there, not a
  separate script. Ghostty is packaged on Ubuntu directly; VS Code isn't,
  so `apt.sh` adds Microsoft's own apt repo (their recommended method for
  Debian/Ubuntu) instead of the snap build. Their GPG key moved from
  `keys/microsoft.gpg` to `keys/microsoft.asc` (the old URL now 404s) -
  worth re-checking if this breaks again.
- `gh` (GitHub CLI) also goes through its own apt repo (`cli.github.com/packages`),
  same reasoning as VS Code: Ubuntu's package (2.46.0) was ~50 releases
  behind upstream (2.96.0). Their signing key expires 2026-09-05 - if `gh`
  installs start failing after that, it's the key, re-fetch the URL.
- `eza` (packaged on Ubuntu) replaces `ls`/`lt` in the dotfiles' zsh
  `init`, guarded the same way as starship/zoxide/fzf there.
- Ruby is installed precompiled (`mise settings set ruby.compile false`
  before `mise use -g ruby@latest`) instead of via ruby-build's default
  compile-from-source - much faster, and becomes mise's own default in
  2026.8.0 anyway. `apt.sh` still installs the usual native-extension
  deps (`libffi-dev`, `libyaml-dev`, etc.) since gems like `nokogiri` or
  `sqlite3` need them regardless of how Ruby itself was installed.
  `dev.sh` then installs Rails via `gem install rails`.
- GNOME base: `apt.sh` installs `gnome-tweaks`, `gnome-shell-extension-manager`,
  `dconf-editor`, `gnome-sushi`, `flatpak` and `gnome-software-plugin-flatpak`.
  `gnome.sh` adds the Flathub remote (`flatpak remote-add`, not a package
  install, so it doesn't belong in `apt.sh`) — works without `sudo`, Ubuntu's
  polkit rules let the session user manage system Flatpak remotes.
