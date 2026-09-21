#!/bin/bash
# Shanmukha Kumar Karra — refresh UI

SCRIPTSDIR="$HOME/.config/hypr/scripts"

for _prs in waybar rofi swaync; do
    pkill -x "${_prs}" 2>/dev/null || true
done

if command -v ags >/dev/null 2>&1; then
    ags -q 2>/dev/null || true
fi

sleep 0.3
waybar >/dev/null 2>&1 &
sleep 0.3
swaync >/dev/null 2>&1 &
if command -v ags >/dev/null 2>&1; then
    ags >/dev/null 2>&1 &
fi

exit 0
