#!/bin/sh
# Install the nscc CLI for the current user.
#
# Recommended (repo IS the install dir — no copying, no drift):
#   git clone <repo-url> ~/.nscc
#   sh ~/.nscc/install.sh
#
# Also works from a clone/zip anywhere else (copies into ~/.nscc):
#   git clone <repo-url> nscc-src && sh nscc-src/install.sh

set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME/.nscc"

if [ "$HERE" != "$TARGET" ]; then
    mkdir -p "$TARGET"
    cp "$HERE/nscc" "$TARGET/nscc"
    chmod +x "$TARGET/nscc"
    echo "copied script to $TARGET/nscc"
fi

# pick a bin dir that exists and is on PATH
BIN=""
for dir in /opt/homebrew/bin /usr/local/bin "$HOME/.local/bin" "$HOME/bin"; do
    if [ -d "$dir" ]; then BIN="$dir"; break; fi
done
if [ -z "$BIN" ]; then
    echo "no bin directory found — add $TARGET to PATH manually"
    exit 1
fi
mkdir -p "$BIN"
ln -sf "$TARGET/nscc" "$BIN/nscc"

if [ ! -f "$TARGET/config" ]; then
    "$TARGET/nscc" init || true
fi

echo ""
echo "installed: $BIN/nscc -> $TARGET/nscc"
echo "next: edit $TARGET/config to set your NSCC username,"
echo "      and export \$MYPASS_XL='your-password' in ~/.zshrc"
command -v expect >/dev/null 2>&1 || echo "NOTE: install expect first: brew install expect"
