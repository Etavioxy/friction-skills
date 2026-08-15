#!/bin/sh
# usage: ./install.sh ~/.claude/skills/             # install
#        ./install.sh ~/.claude/skills/ --uninstall # uninstall
set -e
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
TARGET="${1:?usage: install.sh <target-dir> [--uninstall]}"
MODE="${2:-install}"

if [ "$MODE" = "--uninstall" ] || [ "$MODE" = "uninstall" ]; then
  for d in "$SCRIPT_DIR"/skills/*/; do
    name="$(basename "$d")"
    rm -rf "$TARGET/$name"
    echo "Removed $name"
  done
else
  mkdir -p "$TARGET"
  for d in "$SCRIPT_DIR"/skills/*/; do
    name="$(basename "$d")"
    cp -r "$d" "$TARGET/$name"
    echo "Installed $name"
  done
fi
