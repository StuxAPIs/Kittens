#!/bin/bash
# Kittens - Local dev server
# Usage: ./dev-server.sh [port] [--no-dev-mode]
#   port            default: whatever's in config.json (falls back to 8080)
#   --no-dev-mode   don't force "localhost" mode on for this run (see below)
#
# "localhost" mode is forced ON in config.json for every run of this script,
# regardless of what config.json has it set to - that's what makes redirect/
# JSON URLs point at 127.0.0.1 without having to flip it by hand every time.
# Pass --no-dev-mode to test the app against your real config.json instead.
#
# This script also bootstraps config.json from config.json.example if it
# doesn't exist yet, installs Python dependencies if quart isn't importable,
# and drops in a placeholder images/ folder if none exists so the app doesn't
# crash on a fresh checkout (index.py errors out on an empty image folder).
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

PORT=
NO_DEV_MODE=0

while [ $# -gt 0 ]; do
    case "$1" in
        --no-dev-mode) NO_DEV_MODE=1; shift ;;
        ''|*[!0-9]*) echo "Unknown option: $1" >&2; exit 1 ;;
        *) PORT="$1"; shift ;;
    esac
done

if [ ! -f "$DIR/config.json" ]; then
    echo "No config.json found - copying config.json.example to get you started."
    cp "$DIR/config.json.example" "$DIR/config.json"
fi

PYTHON_BIN="$(command -v python3 || command -v python)"
if [ -z "$PYTHON_BIN" ]; then
    echo "Python is required but wasn't found on PATH." >&2
    exit 1
fi

if ! "$PYTHON_BIN" -c "import quart" >/dev/null 2>&1; then
    echo "Installing Python dependencies..."
    "$PYTHON_BIN" -m pip install -r "$DIR/requirements.txt"
fi

mkdir -p "$DIR/images"
if [ -z "$(ls -A "$DIR/images" 2>/dev/null)" ]; then
    echo "No images found - dropping in a placeholder so the app has something to serve."
    cp "$DIR/bin/placeholder_kitten.png" "$DIR/images/placeholder_kitten.png"
fi

"$PYTHON_BIN" "$DIR/bin/dev_configure.py" "$PORT" "$NO_DEV_MODE"

exec "$PYTHON_BIN" "$DIR/index.py"
