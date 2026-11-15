#!/bin/bash
# Kittens - Local dev server
# Usage: ./dev-server.sh [port] [--no-dev-mode] [--lan]
#   port            default: whatever's in config.json (falls back to 8080)
#   --no-dev-mode   don't force "localhost" mode on for this run (see below)
#   --lan           listen on all interfaces so phones/tablets on your network can
#                   connect (prints the addresses to open); default is 127.0.0.1 only.
#                   In dev mode, the app's links then use this machine's LAN address
#                   instead of 127.0.0.1, so they work from the other device too.
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
LAN=0

while [ $# -gt 0 ]; do
    case "$1" in
        --no-dev-mode) NO_DEV_MODE=1; shift ;;
        --lan) LAN=1; shift ;;
        ''|*[!0-9]*) echo "Unknown option: $1" >&2; echo "Usage: ./dev-server.sh [port] [--no-dev-mode] [--lan]" >&2; exit 1 ;;
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

if [ "$LAN" = "1" ]; then
    PORT="$("$PYTHON_BIN" -c 'import json; print(json.load(open("config.json"))["port"])')"
    # This machine's IPv4 addresses (Windows, macOS or Linux), minus loopback
    case "$OSTYPE" in
        msys*|cygwin*|win32*) ADDRS="$(ipconfig | awk -F': *' '/IPv4/{print $2}' | tr -d '\r')" ;;
        darwin*) ADDRS="$(ifconfig | awk '/inet /{print $2}')" ;;
        *) ADDRS="$(hostname -I 2>/dev/null)" ;;
    esac
    LAN_ADDR=
    echo "On your local network (--lan), open one of these on the other device:"
    for a in $ADDRS; do
        case "$a" in
            127.*|'') ;;
            *) echo "    http://$a:$PORT/"
               case "$a" in 192.168.*) case "$LAN_ADDR" in 192.168.*) ;; *) LAN_ADDR="$a" ;; esac ;; esac
               [ -z "$LAN_ADDR" ] && LAN_ADDR="$a" ;;
        esac
    done
    echo "  (usually the 192.168.x.x one; allow Python through the firewall if asked)"
    export KITTENS_DEV_HOST=0.0.0.0
    # The app's own links use the 192.168.x.x address if there is one, else the first one found
    [ -n "$LAN_ADDR" ] && export KITTENS_DEV_ADDR="$LAN_ADDR"
fi

exec "$PYTHON_BIN" "$DIR/index.py"
