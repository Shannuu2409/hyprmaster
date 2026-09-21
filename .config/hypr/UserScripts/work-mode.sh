#!/bin/bash
# Shanmukha Kumar Karra — work layout (optional)

notify-send -u low "hyprmaster" "Work mode: opening workspace layout" 2>/dev/null || true
hyprctl dispatch workspace 1
hyprctl dispatch exec "[float; size 48% 88%; move 1% 5%]" kitty --class work_term -e "$SHELL"
hyprctl dispatch workspace 2
hyprctl dispatch exec brave 2>/dev/null || hyprctl dispatch exec "$BROWSER" 2>/dev/null || true
hyprctl dispatch exec thunar 2>/dev/null || true
