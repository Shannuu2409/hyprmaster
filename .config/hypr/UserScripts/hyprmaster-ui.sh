#!/bin/bash
# Shanmukha Kumar Karra — ordered UI startup (theme pipeline)

UserScripts="${HOME}/.config/hypr/UserScripts"
CACHE="${HOME}/.cache/hyprmaster"
mkdir -p "$CACHE"

log() { echo "$(date -Iseconds) $*" >>"${CACHE}/ui-startup.log"; }

log "hyprmaster-ui start"

if [ -f "${UserScripts}/skkarra-theme-switch.sh" ]; then
    bash "${UserScripts}/skkarra-theme-switch.sh" apply noir-minimal || \
        log "theme apply failed"
else
    log "missing skkarra-theme-switch.sh"
fi

log "hyprmaster-ui done"
