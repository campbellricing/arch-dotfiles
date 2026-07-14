# Fresh Arch install guide

Step-by-step setup of this desktop on a new machine. Target state: Hyprland +
caelestia shell, SDDM with the Silent theme synced to the current wallpaper,
foot/fish/starship/tmux terminal stack, fingerprint unlock, ThinkPad power
tuning.

## Assumptions

- Base Arch install completed (archinstall or manual): disk, locale, network,
  bootloader **GRUB** on EFI, user created, `sudo` working.
- Username `campbells`. Several system files hardcode it — if the user differs,
  fix: `etc/sddm.conf` (`FacesDir`), `usr/local/bin/sddm-wallpaper-sync`
  (`STATE_FILE`, `OWNER`), `etc/systemd/system/sddm-wallpaper-sync.path`
  (`PathModified`).
- Hardware-specific bits (skip/review on other machines):
  - `etc/throttled.conf` — Intel undervolt + power limits for this ThinkPad.
    **Do not deploy blindly on other hardware.**
  - `etc/tlp.conf` — battery charge thresholds (ThinkPad).
  - `python-validity` fingerprint stack — for Validity sensors (ThinkPad
    T480/X1 gen and similar).
  - `intel-ucode`, `vulkan-intel`, `intel-media-driver` — Intel CPU/GPU.

## 1. Clone the repo as ~/.config

The repo root **is** `~/.config`. On a fresh system `~/.config` may already
contain a few generated files, so clone via a temp checkout:

```sh
git clone <repo-url> /tmp/dotfiles
mv /tmp/dotfiles/.git ~/.config/.git
cd ~/.config
git checkout .        # materialize tracked files over the fresh dir
git status            # untracked generated files are fine; tracked files must be clean
```

## 2. Run the bootstrap

```sh
~/.config/scripts/install.sh
```

What it does (idempotent, re-run any time):

1. Installs official packages from `packages/pacman.txt`.
2. Bootstraps `yay` if missing, installs AUR packages from `packages/aur.txt`
   (caelestia shell/CLI, quickshell, SDDM theme deps, fingerprint stack, …).
3. Sets fish as the login shell.
4. Copies desktop-entry overrides from `.local/share/applications/` in the repo
   to `~/.local/share/applications/` (hides noise apps from the launcher,
   tweaks Exec lines).
5. Creates XDG user dirs.
6. Runs `scripts/deploy-system.sh` (sudo): copies `etc/**` → `/etc`,
   `usr/local/bin/**` → `/usr/local/bin`, deploys the SDDM theme
   `silent/` → `/usr/share/sddm/themes/silent-caelestia`, regenerates
   `grub.cfg` if needed.
7. Enables system services: `NetworkManager`, `bluetooth`, `sddm`, `keyd`,
   `tlp`, `throttled`, `python3-validity`, `sddm-wallpaper-sync.path`.
8. Enables the user service `caelestia-term-scheme.path`.

## 3. Manual steps

In order, after the bootstrap:

1. **Reboot** — SDDM should come up with the Silent (Caelestia) theme.
2. **Log into the Hyprland session.** The caelestia shell, keyring, polkit
   agent, clipboard history and fcitx5 all start from
   `hypr/hyprland/execs.lua`.
3. **Fingerprint**: `fprintd-enroll` (uses open-fprintd/python-validity).
   Used by the caelestia lock screen (see `docs/shell-fork.md`) and available
   to PAM via `pam-fprint-grosshack`.
4. **fcitx5 / Vietnamese input**: fcitx5 config is *not* tracked (local state).
   Add the Unikey input method in `fcitx5-configtool`.
5. **Node.js**: `fnm install --lts` (fnm hooks into fish automatically).
6. **Neovim**: first `nvim` start installs plugins pinned by
   `nvim/lazy-lock.json` (LazyVim).
7. **Wallpaper**: pick one via the caelestia launcher/wallpaper picker
   (wallpapers live in `images/wallpapers/`). Selecting one also updates the
   SDDM background via the wallpaper-sync unit.
8. **Avatar**: `etc/sddm.conf` points `FacesDir` at `images/avatar/`, which
   already contains `campbells.face.icon` — nothing to do unless the username
   changed (then run `silent/change_avatar.sh <user> <image>` or rename the
   icon).
9. **Register the caelestia dots**: `caelestia update` only works after
   `caelestia install` has recorded its state once. Run `caelestia install` —
   it will NOT clobber the repo's customized files: where its files differ
   from ours it writes `<file>.new` alongside instead (delete those, or merge
   anything useful). Afterwards `git status` shows exactly what it touched.
10. **Verify**: `scripts/check-drift.sh` should print "No drift".

## 4. Component reference

### Boot & system tuning

| File | Deployed to | Notes |
|---|---|---|
| `etc/default/grub` | `/etc/default/grub` | quiet boot, watchdogs disabled via kernel cmdline. deploy-system.sh runs `grub-mkconfig` on change |
| `etc/keyd/default.conf` | `/etc/keyd/` | `muhenkan` held = hjkl arrow layer (`keyd` service) |
| `etc/systemd/logind.conf` | `/etc/systemd/logind.conf` | lid/power-button behaviour (suspend; long-press poweroff) |
| `etc/tlp.conf` | `/etc/tlp.conf` | governors + charge thresholds 79→80% |
| `etc/throttled.conf` | `/etc/throttled.conf` | power limits, trip temps 75/85 °C, undervolt (**machine-specific**) |

### Login screen (SDDM)

- Theme: repo `silent/` (fork of
  [SilentSDDM](https://github.com/uiriansan/SilentSDDM)) deployed to
  `/usr/share/sddm/themes/silent-caelestia`. Deployed under a name pacman
  doesn't own so package updates can never clobber it. The `sddm-silent-theme`
  AUR package is intentionally **not** installed — which means its Qt runtime
  deps must stay **explicitly** installed: `qt6-multimedia-ffmpeg` (pulls
  `qt6-multimedia`; theme fails to load without it) and `qt6-virtualkeyboard`
  (both in `packages/pacman.txt`).
- `etc/sddm.conf`: `Current=silent-caelestia`, `FacesDir` → repo avatar dir.
- **Wallpaper sync**: `sddm-wallpaper-sync.path` (root) watches
  `~/.local/state/caelestia/wallpaper/path.txt`; on change
  `/usr/local/bin/sddm-wallpaper-sync` converts the current wallpaper to PNG
  (needs `imagemagick`) and installs it as the theme's
  `backgrounds/current-wallpaper.png`, so the login screen always matches the
  desktop.

### Hyprland

Config is Lua (`hypr/hyprland.lua` + `hypr/hyprland/*.lua`), split by topic
(env, general, input, keybinds, rules, execs, …). Entry point also loads:

- `hypr/variables.lua` — cursor theme/size etc.; per-machine overrides go in
  `caelestia/hypr-vars.lua` (auto-created).
- `hypr/scheme/current.lua` — colors, written by caelestia; seeded from
  `hypr/scheme/default.lua`.
- `caelestia/hypr-user.lua` — extra user config (black background pre-shell).

Autostarted from `execs.lua`: gnome-keyring, polkit-gnome agent, cliphist
(clipboard history), trash-empty 30, cursor setup, mpris-proxy (bluetooth
media keys), fcitx5, `caelestia shell -d`.

### Caelestia shell & theming pipeline

- The running shell is the **vendored fork** `quickshell/caelestia/` — see
  `docs/shell-fork.md` for why and what was modified.
- `caelestia/shell.json` — shell settings (bar layout, launcher, wallpaper dir
  → `images/wallpapers/`).
- `caelestia/cli.json` — disables the CLI's own terminal theming
  (`theme.enableTerm=false`) because it's replaced by:
- **Terminal scheme sync**: user unit `caelestia-term-scheme.path` watches
  `~/.local/state/caelestia/scheme.json`; on change it runs
  `caelestia/apply-term-scheme.py`, which regenerates
  `~/.local/state/caelestia/sequences.txt` and pushes OSC color sequences to
  every open pty — dark mode only, and with the background sequence stripped
  inside tmux (tmux would render it as an opaque pane background).
  `fish/config.fish` applies the same sequences to new shells.

### Terminal stack

- `foot/foot.ini` — terminal; prompt-jump via OSC 133 emitted from fish.
- `fish/config.fish` — prompt (starship), direnv/zoxide/fnm hooks, abbrs,
  scheme sequence sourcing.
- `starship.toml` — prompt; the catppuccin palette block is **generated**:
  edit `catppuccin/mocha.conf`, then run `catppuccin/sync-starship.sh`.
- `tmux/tmux.conf` — loads the same palette at runtime via
  `catppuccin/load-tmux.sh` (`@ctp_*` options). Plugins in `tmux/plugins/` are
  gitignored; install TPM/plugins on first run if used.
- `fastfetch/config.jsonc`, `swappy/config`, `mimeapps.list`,
  `user-dirs.dirs` — plain configs, live in place.

### Fingerprint stack (AUR)

`python-validity` + `open-fprintd` + `fprintd-clients-git` +
`pam-fprint-grosshack`. Services `python3-validity` and
`python3-validity-suspend-hotfix` must be enabled. Enroll with
`fprintd-enroll`. The caelestia lock screen ships its own PAM config
(`quickshell/caelestia/assets/pam.d/fprint`); no `/etc/pam.d` edits required.

## Repo ↔ system map

Everything under `~/.config` works in place. Files needing deployment:

| Repo | System | Deployed by |
|---|---|---|
| `etc/**` | `/etc/**` (same relative path) | `scripts/deploy-system.sh` |
| `usr/local/bin/**` | `/usr/local/bin/**` | `scripts/deploy-system.sh` |
| `silent/` | `/usr/share/sddm/themes/silent-caelestia/` | `scripts/deploy-system.sh` |
| `.local/share/applications/*.desktop` | `~/.local/share/applications/` | `scripts/install.sh` |
| `systemd/user/*` | in place (`~/.config/systemd/user`) | just `systemctl --user enable` |
