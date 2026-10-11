#!/usr/bin/env bash
# ==============================================================================
# Installer for paste2save (Linux)
# Creates a symlink in ~/.local/bin/paste2save
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
TARGET="${BIN_DIR}/paste2save"

mkdir -p "$BIN_DIR"
chmod +x "${SCRIPT_DIR}/paste2save.sh"
ln -sf "${SCRIPT_DIR}/paste2save.sh" "$TARGET"

echo "[+] paste2save installed successfully to: $TARGET"
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "[!] Notice: $BIN_DIR is not currently in your PATH."
    echo "    Add it by running:"
    echo "    echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc && source ~/.bashrc"
fi
echo "[+] You can now run 'paste2save' from any terminal!"
