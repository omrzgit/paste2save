#!/usr/bin/env bash
# Root launcher for paste2save (Linux Edition)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/paste2save_linux/paste2save.sh" "$@"
