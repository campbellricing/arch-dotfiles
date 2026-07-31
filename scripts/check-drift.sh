#!/usr/bin/env bash
# Read-only drift report between this repo and the live system.
# Run after every system update (pacman -Syu) and after editing system
# configs directly, to catch differences before they get lost.
#
# Exits 0 when everything matches, 1 when drift was found.
#
# To resolve drift:
#   repo is right  -> sudo scripts/deploy-system.sh
#   system is right-> copy the file back into the repo and commit
#
# Usage: scripts/check-drift.sh

set -uo pipefail

REPO="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
THEME_DEST=/usr/share/sddm/themes/silent-caelestia
drift=0

report() { # <label> <repo-file> <system-file>
    local label="$1" src="$2" dest="$3"
    if [[ ! -e "$dest" ]]; then
        echo "MISSING  $label ($dest not deployed)"
        drift=1
    elif ! diff -q "$src" "$dest" >/dev/null 2>&1; then
        echo "DIFF     $label"
        diff -u "$dest" "$src" | sed 's/^/         /' | head -30
        drift=1
    fi
}

# --- tracked system files ---------------------------------------------------
while IFS= read -r -d '' src; do
    rel="${src#"$REPO"/etc/}"
    report "etc/$rel" "$src" "/etc/$rel"
done < <(find "$REPO/etc" -type f -print0)

while IFS= read -r -d '' src; do
    rel="${src#"$REPO"/usr/local/bin/}"
    report "usr/local/bin/$rel" "$src" "/usr/local/bin/$rel"
done < <(find "$REPO/usr/local/bin" -type f -print0)

# --- SDDM theme (runtime files excluded) ------------------------------------
while IFS= read -r -d '' src; do
    rel="${src#"$REPO"/sddm/silent/}"
    [[ "$rel" == backgrounds/current-wallpaper.png ]] && continue
    report "sddm/silent/$rel" "$src" "$THEME_DEST/$rel"
done < <(find "$REPO/sddm/silent" -type f -print0)

# --- pacnew/pacsave leftovers for tracked /etc files -------------------------
while IFS= read -r -d '' src; do
    rel="${src#"$REPO"/etc/}"
    for suffix in pacnew pacsave; do
        if [[ -e "/etc/$rel.$suffix" ]]; then
            echo "PACNEW   /etc/$rel.$suffix exists — merge it, update the repo copy, then delete it"
            drift=1
        fi
    done
done < <(find "$REPO/etc" -type f -print0)

# --- required services -------------------------------------------------------
for unit in sddm keyd tlp throttled bluetooth NetworkManager \
            python3-validity sddm-wallpaper-sync.path; do
    state="$(systemctl is-enabled "$unit" 2>/dev/null || true)"
    if [[ "$state" != enabled && "$state" != static && "$state" != alias ]]; then
        echo "SERVICE  $unit is not enabled (state: ${state:-not-found})"
        drift=1
    fi
done
state="$(systemctl --user is-enabled caelestia-term-scheme.path 2>/dev/null || true)"
if [[ "$state" != enabled ]]; then
    echo "SERVICE  caelestia-term-scheme.path (user) is not enabled (state: ${state:-not-found})"
    drift=1
fi

if [[ $drift -eq 0 ]]; then
    echo "No drift — system matches repo."
fi
exit $drift
