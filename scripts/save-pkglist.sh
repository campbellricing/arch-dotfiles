#!/bin/sh
# Regenerate packages/pacman.txt and packages/aur.txt from the running system.
# Run after installing/removing packages you want a fresh install to include.

REPO="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

pacman -Qqen > "$REPO/packages/pacman.txt"
# Foreign (AUR) explicit packages; debug packages are build artifacts, skip them
pacman -Qqem | grep -v -- '-debug$' > "$REPO/packages/aur.txt"

echo "Wrote $(wc -l < "$REPO/packages/pacman.txt") repo packages to packages/pacman.txt"
echo "Wrote $(wc -l < "$REPO/packages/aur.txt") AUR packages to packages/aur.txt"
