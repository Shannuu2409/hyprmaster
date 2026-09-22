#!/bin/bash
# Shanmukha Kumar Karra — first login

MARKER="${HOME}/.config/hypr/.initial_startup_done"
[ -f "$MARKER" ] && exit 0

"${HOME}/.config/hypr/UserScripts/skkarra-theme-switch.sh" apply noir-minimal
cp "${HOME}/.config/waybar/config.minimal" "${HOME}/.config/waybar/config" 2>/dev/null || true
touch "$MARKER"
