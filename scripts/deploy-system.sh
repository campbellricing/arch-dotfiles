#!/usr/bin/env bash
# Deploy the system-level files tracked in this repo to their real locations.
#
#   etc/**              -> /etc/**
#   usr/local/bin/**    -> /usr/local/bin/**
#   sddm/silent/        -> /usr/share/sddm/themes/silent-caelestia/
#
# Idempotent: only changed files are copied, and follow-up actions
# (grub-mkconfig, daemon-reload, service restarts) only run when the
# file they depend on actually changed. Run after every system update
# that touches /etc (pacman prints .pacnew warnings), or after editing
# any file under etc/ or usr/ in this repo.
#
# Usage: sudo scripts/deploy-system.sh [--dry-run]

set -euo pipefail

REPO="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
THEME_DEST=/usr/share/sddm/themes/silent-caelestia
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

if [[ $EUID -ne 0 && $DRY_RUN -eq 0 ]]; then
    echo "This script needs root. Re-run as: sudo $0" >&2
    exit 1
fi

changed_files=()
removed_count=0

# copy_file <repo-file> <dest> <mode>  — install only when content differs
copy_file() {
    local src="$1" dest="$2" mode="$3"
    if diff -q "$src" "$dest" >/dev/null 2>&1; then
        return 0
    fi
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "would update: $dest"
    else
        install -Dm "$mode" -- "$src" "$dest"
        echo "updated: $dest"
    fi
    changed_files+=("$dest")
}

changed() {
    local f
    for f in "${changed_files[@]:-}"; do
        [[ "$f" == "$1" ]] && return 0
    done
    return 1
}

# --- /etc ------------------------------------------------------------------
while IFS= read -r -d '' src; do
    copy_file "$src" "/etc/${src#"$REPO"/etc/}" 644
done < <(find "$REPO/etc" -type f -print0)

# --- /usr/local/bin --------------------------------------------------------
while IFS= read -r -d '' src; do
    copy_file "$src" "/usr/local/bin/${src#"$REPO"/usr/local/bin/}" 755
done < <(find "$REPO/usr/local/bin" -type f -print0)

# --- SDDM theme (sddm/silent/ -> silent-caelestia) --------------------------
# backgrounds/current-wallpaper.png is runtime state written by
# sddm-wallpaper-sync: deploy the repo copy only if it's missing.
# backgrounds/wallpaper.mp4 is an optional local-only asset: leave it alone.
while IFS= read -r -d '' src; do
    rel="${src#"$REPO"/sddm/silent/}"
    dest="$THEME_DEST/$rel"
    if [[ "$rel" == backgrounds/current-wallpaper.png && -f "$dest" ]]; then
        continue
    fi
    mode=644
    [[ "$src" == *.sh ]] && mode=755
    copy_file "$src" "$dest" "$mode"
done < <(find "$REPO/sddm/silent" -type f -print0)

# Remove theme files that no longer exist in the repo (keep runtime assets)
if [[ -d $THEME_DEST ]]; then
    while IFS= read -r -d '' dest; do
        rel="${dest#"$THEME_DEST"/}"
        case "$rel" in
            backgrounds/current-wallpaper.png|backgrounds/wallpaper.mp4) continue ;;
        esac
        if [[ ! -f "$REPO/sddm/silent/$rel" ]]; then
            if [[ $DRY_RUN -eq 1 ]]; then
                echo "would remove stale theme file: $dest"
            else
                rm -- "$dest"
                echo "removed stale theme file: $dest"
            fi
            removed_count=$((removed_count + 1))
        fi
    done < <(find "$THEME_DEST" -type f -print0)
fi

# --- follow-up actions, only for what changed -------------------------------
if [[ $DRY_RUN -eq 1 ]]; then
    [[ ${#changed_files[@]} -eq 0 && $removed_count -eq 0 ]] \
        && echo "Nothing to do — system matches repo."
    exit 0
fi

if changed /etc/default/grub; then
    echo "grub config changed -> regenerating /boot/grub/grub.cfg"
    grub-mkconfig -o /boot/grub/grub.cfg
fi

if changed /etc/systemd/system/sddm-wallpaper-sync.service \
   || changed /etc/systemd/system/sddm-wallpaper-sync.path; then
    systemctl daemon-reload
fi
systemctl enable --now sddm-wallpaper-sync.path >/dev/null 2>&1 || true

changed /etc/keyd/default.conf     && systemctl restart keyd
changed /etc/tlp.conf              && systemctl restart tlp
changed /etc/throttled.conf        && systemctl restart throttled
changed /etc/systemd/logind.conf   && systemctl restart systemd-logind
if changed /etc/sddm.conf; then
    echo "note: /etc/sddm.conf changed — takes effect at next login screen."
fi

if [[ ${#changed_files[@]} -eq 0 && $removed_count -eq 0 ]]; then
    echo "Nothing to do — system matches repo."
else
    echo "Done: ${#changed_files[@]} file(s) deployed, $removed_count removed."
fi
