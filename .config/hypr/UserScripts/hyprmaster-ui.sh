#!/bin/bash
# Shanmukha Kumar Karra — theme, wallpaper, bar, notifications (ordered startup)

UserScripts="${HOME}/.config/hypr/UserScripts"
CACHE="${HOME}/.cache/hyprmaster"
mkdir -p "$CACHE"

log() { echo "$(date -Iseconds) $*" >>"${CACHE}/ui-startup.log"; }

log "hyprmaster-ui start WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-unset}"

bash "${UserScripts}/wallpaper-bootstrap.sh" || log "wallpaper-bootstrap pass1 failed"

if [ -f "${UserScripts}/skkarra-theme-switch.sh" ]; then
    env HYPRMASTER_RELOAD_UI=0 bash "${UserScripts}/skkarra-theme-switch.sh" apply liquid-glass-dark || \
        log "theme apply failed"
fi

bash "${UserScripts}/wallpaper-bootstrap.sh" || log "wallpaper-bootstrap pass2 failed"

pkill -x waybar 2>/dev/null || true
pkill -x swaync 2>/dev/null || true
sleep 0.3

if ! waybar >"${CACHE}/waybar.log" 2>&1 & then
    log "waybar failed to launch"
fi
sleep 0.5
if ! pgrep -x waybar >/dev/null; then
    log "waybar not running; see ${CACHE}/waybar.log"
    tail -5 "${CACHE}/waybar.log" >>"${CACHE}/ui-startup.log" 2>/dev/null || true
fi

swaync >"${CACHE}/swaync.log" 2>&1 &

log "hyprmaster-ui done"
