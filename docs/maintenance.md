# Maintenance

How to keep the system and this repo in sync so updates never silently break
the setup.

## After every system update (`yay -Syu`)

```sh
scripts/check-drift.sh        # 1. report differences repo ↔ system
sudo scripts/deploy-system.sh # 2. re-apply repo configs if drift was ours
scripts/diff-shell.sh         # 3. if caelestia-shell was updated: review upstream changes
```

`check-drift.sh` flags four kinds of problems:

- **DIFF** — a deployed file no longer matches the repo. Decide which side is
  right: repo right → `sudo scripts/deploy-system.sh`; system right → copy the
  file back into the repo and commit.
- **MISSING** — a tracked system file was never deployed (or an update removed
  it). Run `deploy-system.sh`.
- **PACNEW** — pacman shipped a new default for a config we override
  (`/etc/foo.pacnew`). Merge anything relevant into the repo copy, redeploy,
  then delete the `.pacnew`.
- **SERVICE** — a required unit got disabled (e.g. a package reinstall reset
  it). Re-enable it (`install.sh` also re-enables everything).

## After `caelestia update`

`caelestia update` does two things: a full system update (same as `yay -Syu`,
so the routine above applies), then it deploys the caelestia *dots* — it
manages ~24 files in this repo (`hypr/hyprland.lua`, `hypr/hyprland/*.lua`,
`fish/config.fish`, `foot/foot.ini`, `fastfetch/config.jsonc`, `btop/`, …).

It will **not** overwrite a file you've customized. Per file it does a
three-way comparison (your copy vs the version it last deployed vs the new
upstream version):

- you never touched it, upstream changed it → **updated in place**
- you changed it, upstream didn't → **left alone**
- you changed it AND upstream changed it → your file is left alone and the
  new upstream version is written next to it as **`<file>.new`**

So after every `caelestia update`, the reapply workflow is just:

```sh
git status                 # ~/.config IS the repo, so nothing escapes:
                           #   modified  = upstream fast-forwarded a file you never customized
                           #   untracked *.new = conflict: upstream + you both changed it
git diff                   # review what upstream changed in-place; commit if ok
find ~/.config -name '*.new'   # for each: merge what you want into your file, delete the .new
```

Because the repo is git, even a worst-case overwrite is recoverable:
`git diff` shows it, `git checkout -- <file>` restores your version.

Note: the *shell* (`quickshell/caelestia/`) is not part of these dots — it
comes from the `caelestia-shell` package and is shadowed by your fork; that
workflow stays `scripts/diff-shell.sh` (see docs/shell-fork.md).

## What updates can and cannot break

| Area | Can an update break it? |
|---|---|
| Everything in `~/.config` (fish, foot, hypr, tmux, …) | No — pacman never touches `$HOME`. Only config-format changes in new program versions can bite. |
| `/etc` configs (grub, keyd, tlp, throttled, logind, sddm) | Yes — packages ship `.pacnew` (normally safe) or, rarely, overwrite. `check-drift.sh` catches both. |
| SDDM theme | No — deployed as `silent-caelestia`, which no package owns. |
| Running caelestia shell | No — `~/.config/quickshell/caelestia` shadows the package. Flip side: upstream updates don't arrive; use `scripts/diff-shell.sh` to cherry-pick (see `docs/shell-fork.md`). |
| `usr/local/bin/sddm-wallpaper-sync` | No package owns `/usr/local/bin`. Depends on `imagemagick` staying installed. |
| GRUB | `grub` package updates may want `grub-mkconfig` (deploy-system.sh runs it when our config changes; after a grub *package* update run it manually once). |

## Changing things

- **Edit a system config** (keyd layer, TLP threshold, kernel params …):
  change the copy in the repo (`etc/...`), then `sudo scripts/deploy-system.sh`.
  Never edit `/etc` directly — if you do anyway, `check-drift.sh` will show it
  and you can copy it back.
- **Install/remove packages** you care about: run `scripts/save-pkglist.sh`
  and commit the updated `packages/*.txt`.
- **Change terminal colors**: edit `catppuccin/mocha.conf`, then run
  `catppuccin/sync-starship.sh` (regenerates the palette block in
  `starship.toml`); tmux picks the palette up on next start (or
  `tmux source ~/.config/tmux/tmux.conf`).
- **Modify the shell fork**: edit files under `quickshell/caelestia/`,
  `caelestia shell -d` restart to test, and record the change in
  `docs/shell-fork.md` so future upstream merges stay easy.
- **New wallpaper**: drop it in `images/wallpapers/` — the picker finds it;
  selection auto-syncs to the SDDM background.

## Custom automation reference

| Unit | Scope | Watches | Runs |
|---|---|---|---|
| `sddm-wallpaper-sync.path` | system | `~/.local/state/caelestia/wallpaper/path.txt` | `/usr/local/bin/sddm-wallpaper-sync` → converts wallpaper to PNG into the SDDM theme |
| `caelestia-term-scheme.path` | user | `~/.local/state/caelestia/scheme.json` | `caelestia/apply-term-scheme.py` → regenerates `sequences.txt`, recolors open terminals (dark-only, tmux-safe) |

Debugging: `journalctl -u sddm-wallpaper-sync.service` /
`journalctl --user -u caelestia-term-scheme.service`.

## Scripts index

| Script | Purpose |
|---|---|
| `scripts/install.sh` | Fresh-machine bootstrap (packages, deploy, services) |
| `scripts/deploy-system.sh` | Repo → system deployment (`--dry-run` supported) |
| `scripts/check-drift.sh` | Read-only repo ↔ system diff + service check |
| `scripts/diff-shell.sh` | Vendored caelestia shell fork vs installed package |
| `scripts/save-pkglist.sh` | Regenerate `packages/*.txt` from installed packages |
| `catppuccin/sync-starship.sh` | Regenerate starship palette from `mocha.conf` |
| `catppuccin/load-tmux.sh` | Load palette into tmux (called from tmux.conf) |
| `caelestia/apply-term-scheme.py` | Push caelestia scheme to terminals (called by path unit) |
| `sddm/silent/change_avatar.sh` | Set SDDM avatar for a user (crops/resizes) |
