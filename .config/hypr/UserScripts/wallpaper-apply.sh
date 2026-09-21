#!/bin/bash
# Shanmukha Kumar Karra — unified wallpaper + colors

set -euo pipefail

img="${1:-}"
[ -n "$img" ] && [ -f "$img" ] || { echo "Usage: $0 /path/to/wallpaper" >&2; exit 1; }

SWITCHER="${HOME}/.config/hypr/UserScripts/skkarra-theme-switch.sh"
exec "$SWITCHER" wallpaper "$img"
