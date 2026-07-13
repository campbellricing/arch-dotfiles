#!/usr/bin/env bash
# Fresh-machine bootstrap. Assumes:
#   - a base Arch install with networking, and this repo cloned AS ~/.config
#     (git clone <url> ~/.config), see docs/install.md for the full guide
#   - run as the regular user (it calls sudo where needed), NOT as root
#
# Idempotent: safe to re-run at any point; every step skips what's already done.

set -euo pipefail

REPO="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

if [[ $EUID -eq 0 ]]; then
    echo "Run as your normal user, not root." >&2
    exit 1
fi
if [[ "$REPO" != "$HOME/.config" ]]; then
    echo "warning: repo is at $REPO, expected $HOME/.config — dotfiles only work from ~/.config" >&2
fi
if [[ "$USER" != campbells ]]; then
    echo "warning: several system files hardcode user 'campbells' (sddm.conf FacesDir," >&2
    echo "         sddm-wallpaper-sync script + path unit). Adjust them for user '$USER'." >&2
fi

step() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }

# --- packages ----------------------------------------------------------------
step "Installing official packages (packages/pacman.txt)"
sudo pacman -S --needed --noconfirm - < "$REPO/packages/pacman.txt"

if ! command -v yay >/dev/null; then
    step "Bootstrapping yay"
    tmp="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp"
fi

step "Installing AUR packages (packages/aur.txt)"
yay -S --needed - < "$REPO/packages/aur.txt"

# --- shell ---------------------------------------------------------------------
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != /usr/bin/fish ]]; then
    step "Setting fish as login shell"
    chsh -s /usr/bin/fish
fi

# --- user-level files ----------------------------------------------------------
step "Deploying desktop-entry overrides to ~/.local/share/applications"
mkdir -p ~/.local/share/applications
cp -u "$REPO/.local/share/applications/"*.desktop ~/.local/share/applications/

step "Creating XDG user dirs"
xdg-user-dirs-update

# --- system files ----------------------------------------------------------------
step "Deploying system files (etc/, usr/, SDDM theme)"
sudo "$REPO/scripts/deploy-system.sh"

# --- services --------------------------------------------------------------------
step "Enabling system services"
sudo systemctl enable NetworkManager bluetooth sddm keyd tlp throttled \
    python3-validity sddm-wallpaper-sync.path

step "Enabling user services"
systemctl --user daemon-reload
systemctl --user enable caelestia-term-scheme.path

# --- reminders ---------------------------------------------------------------------
cat <<'EOF'

Done. Manual steps that can't be scripted:
  - enroll a fingerprint:            fprintd-enroll
  - log out/in (or reboot) so fish, keyd, SDDM theme and Hyprland session apply
  - first Hyprland start launches caelestia shell automatically (hypr execs.lua)
  - TLP/throttled/undervolt settings are tuned for THIS laptop (ThinkPad,
    Intel undervolting) — review etc/throttled.conf + etc/tlp.conf on new hardware
EOF
