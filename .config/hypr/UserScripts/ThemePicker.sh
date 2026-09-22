#!/bin/bash
# Shanmukha Kumar Karra — rofi theme picker

SWITCHER="${HOME}/.config/hypr/UserScripts/skkarra-theme-switch.sh"
cur=$("$SWITCHER" current)

mapfile -t themes < <("$SWITCHER" list)

menu() {
    local t label
    for t in "${themes[@]}"; do
        if [ "$t" = "$cur" ]; then
            label="● $t (current)"
        else
            label="  $t"
        fi
        printf '%s\n' "$label"
    done
}

choice=$(menu | rofi -dmenu -i -p "Theme" -config "${HOME}/.config/rofi/config.rasi")
[ -z "$choice" ] && exit 0

choice=$(echo "$choice" | sed 's/^● //; s/ (current)$//; s/^  //')
"$SWITCHER" apply "$choice"
