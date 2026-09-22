#!/bin/bash
# Shanmukha Kumar Karra — theme, wallpaper, bar, notifications (ordered startup)

set -euo pipefail

UserScripts="${HOME}/.config/hypr/UserScripts"
scriptsDir="${HOME}/.config/hypr/scripts"

bash "${UserScripts}/wallpaper-bootstrap.sh" || true

if [ -f "${UserScripts}/skkarra-theme-switch.sh" ]; then
    env HYPRMASTER_RELOAD_UI=0 bash "${UserScripts}/skkarra-theme-switch.sh" apply liquid-glass-dark || true
fi

bash "${UserScripts}/wallpaper-bootstrap.sh" || true

pkill -x waybar 2>/dev/null || true
pkill -x swaync 2>/dev/null || true
sleep 0.2

waybar >/dev/null 2>&1 &
swaync >/dev/null 2>&1 &
