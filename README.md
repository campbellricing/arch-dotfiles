# dotfiles

Arch Linux + Hyprland + [caelestia shell](https://github.com/caelestia-dots/shell)
desktop. This repo **is** `~/.config` — configs work in place; system-level
files live under `etc/` + `usr/` and are deployed by script.

## Fresh install (short version)

```sh
# clone as ~/.config (see docs/install.md for the safe way onto a non-empty dir)
git clone <repo-url> /tmp/dotfiles && mv /tmp/dotfiles/.git ~/.config/.git
cd ~/.config && git checkout .

scripts/install.sh     # packages, system files, services — idempotent
# reboot, then: fprintd-enroll, fcitx5-configtool, fnm install --lts
```

Full guide with all manual steps and hardware caveats: **[docs/install.md](docs/install.md)**

## After a system update

```sh
scripts/check-drift.sh          # anything clobbered or .pacnew'd?
sudo scripts/deploy-system.sh   # re-apply our configs
scripts/diff-shell.sh           # review caelestia-shell upstream changes
```

Details: **[docs/maintenance.md](docs/maintenance.md)**

## Layout

| Path | What |
|---|---|
| `fish/`, `foot/`, `tmux/`, `starship.toml`, `fastfetch/` | terminal stack |
| `hypr/` | Hyprland config in Lua, split by topic |
| `caelestia/` | shell/CLI settings + scheme→terminal sync script + hypr override hooks |
| `quickshell/caelestia/` | **vendored fork** of the caelestia shell — see [docs/shell-fork.md](docs/shell-fork.md) |
| `sddm/silent/` | **vendored fork** of SilentSDDM, deployed as theme `silent-caelestia` |
| `catppuccin/` | single palette source (`mocha.conf`) + generators for starship/tmux |
| `nvim/` | LazyVim config (plugins pinned via `lazy-lock.json`) |
| `etc/`, `usr/` | system files, deployed to `/etc`, `/usr` by `scripts/deploy-system.sh` |
| `systemd/user/` | user units (terminal scheme sync) — in place, just enable |
| `.local/share/applications/` | desktop-entry overrides, copied to `~/.local/share/applications` |
| `images/` | wallpapers + SDDM avatar |
| `packages/` | package lists (`pacman.txt`, `aur.txt`), regenerate with `scripts/save-pkglist.sh` |
| `scripts/` | install / deploy / drift-check / fork-diff / pkglist tooling |
| `docs/` | [install](docs/install.md) · [maintenance](docs/maintenance.md) · [shell-fork](docs/shell-fork.md) |

## Custom automation

- **Login screen follows the wallpaper** — root path unit watches caelestia's
  wallpaper state and re-renders the SDDM background
  (`etc/systemd/system/sddm-wallpaper-sync.*` + `usr/local/bin/sddm-wallpaper-sync`).
- **Terminals follow the color scheme** — user path unit watches
  `scheme.json` and pushes OSC sequences to all open ptys, dark-mode-only and
  tmux-safe (`systemd/user/caelestia-term-scheme.*` + `caelestia/apply-term-scheme.py`).
- **One palette, many tools** — `catppuccin/mocha.conf` generates the starship
  palette and feeds tmux at runtime.
