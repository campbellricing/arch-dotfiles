#!/usr/bin/env bash
# Compare the vendored caelestia shell fork (~/.config/quickshell/caelestia,
# which is what actually runs) against the installed caelestia-shell package
# (/etc/xdg/quickshell/caelestia).
#
# Run after `caelestia-shell` gets updated by yay: the package update does NOT
# affect the running shell (the ~/.config copy shadows it), so use this to see
# what upstream changed and decide what to cherry-pick into the fork.
# The intentional local modifications are listed in docs/shell-fork.md.
#
# Usage:
#   scripts/diff-shell.sh            # list differing files
#   scripts/diff-shell.sh -u         # full unified diff
#   scripts/diff-shell.sh <file>     # diff a single file (path relative to the shell root)

set -uo pipefail

PKG=/etc/xdg/quickshell/caelestia
FORK="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/caelestia"

if [[ ! -d $PKG ]]; then
    echo "caelestia-shell package not installed ($PKG missing)" >&2
    exit 1
fi

echo "package: $(pacman -Q caelestia-shell 2>/dev/null || echo 'unknown version')"
echo

case "${1:-}" in
    "")
        diff -rq "$PKG" "$FORK" | sed "s|$PKG/||; s| and .* differ||; s|^Files |DIFF |; s|^Only in $FORK[:/] *|FORK-ONLY |; s|^Only in $PKG[:/] *|PKG-ONLY  |"
        ;;
    -u)
        diff -ru "$PKG" "$FORK"
        ;;
    *)
        diff -u "$PKG/$1" "$FORK/$1"
        ;;
esac
