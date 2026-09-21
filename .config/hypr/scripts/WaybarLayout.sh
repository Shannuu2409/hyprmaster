#!/bin/bash
# Shanmukha Kumar Karra — waybar layout (minimal only)

SCRIPTSDIR="$HOME/.config/hypr/scripts"
WAYBAR_CONFIG="$HOME/.config/waybar/config"
WAYBAR_MINIMAL="$HOME/.config/waybar/config.minimal"

choice=$(printf '%s\n' 'Show minimal bar' 'Hide bar' | rofi -i -dmenu -config "$HOME/.config/rofi/config-waybar-layout.rasi" 2>/dev/null || printf '%s\n' 'Show minimal bar' 'Hide bar' | rofi -i -dmenu)

case "$choice" in
    'Hide bar')
        pkill -x waybar 2>/dev/null || true
        ;;
    'Show minimal bar')
        [ -f "$WAYBAR_MINIMAL" ] && cp "$WAYBAR_MINIMAL" "$WAYBAR_CONFIG"
        "${SCRIPTSDIR}/Refresh.sh" &
        ;;
esac
