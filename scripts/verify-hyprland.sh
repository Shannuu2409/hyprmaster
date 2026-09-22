#!/bin/bash
# Shanmukha Kumar Karra — zero-error Hyprland verification

set -euo pipefail

FAIL=0
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== hyprmaster verify-hyprland ==="

if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    if hyprctl configerrors 2>/dev/null | grep -q .; then
        echo "FAIL: hyprctl configerrors:"
        hyprctl configerrors
        FAIL=1
    else
        echo "OK: hyprctl configerrors empty"
    fi
else
    echo "SKIP: not inside Hyprland"
fi

for f in \
    "$HOME/.config/hypr/hyprland.conf" \
    "$HOME/.config/hypr/generated/matugen-hyprland.conf" \
    "$HOME/.config/hypr/generated/theme-decoration.conf" \
    "$HOME/.config/hypr/themes/liquid-glass-dark/hypr-colors.conf" \
    "$HOME/.config/hypr/themes/liquid-glass-light/hypr-colors.conf" \
    "$HOME/.config/hypr/UserScripts/skkarra-theme-switch.sh" \
    "$HOME/.config/hypr/UserScripts/wallpaper-apply.sh" \
    "$HOME/.config/hypr/UserScripts/wallpaper-bootstrap.sh" \
    "$HOME/.config/hypr/UserScripts/hyprmaster-ui.sh"; do
    if [ ! -f "$f" ]; then
        echo "FAIL: missing $f (run $REPO_ROOT/populate.sh)"
        FAIL=1
    fi
done

if grep -q 'launch_dashboard' "$HOME/.config/hypr/UserConfigs/Startup_Apps.conf" 2>/dev/null; then
    echo "FAIL: Startup_Apps references removed launch_dashboard.sh"
    FAIL=1
fi

for s in \
    "$HOME/.config/hypr/UserScripts/skkarra-theme-switch.sh" \
    "$HOME/.config/hypr/scripts/Polkit.sh"; do
    [ -x "$s" ] || { echo "FAIL: not executable: $s"; FAIL=1; }
done

if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    _jlog=$(journalctl --user -u hyprland -b -p warning..alert --no-pager 2>/dev/null || true)
    if echo "$_jlog" | grep -q . && ! echo "$_jlog" | grep -qi 'no entries'; then
        echo "$_jlog"
        FAIL=1
    else
        _scan=$(journalctl --user -b --no-pager 2>/dev/null | grep -iE 'hyprland|hypridle|swaync|waybar' | grep -iE 'error|failed|trace' | tail -20 || true)
        if [ -n "$_scan" ]; then
            echo "$_scan"
            FAIL=1
        else
            echo "OK: Hyprland session journal clean"
        fi
    fi
else
    echo "SKIP: journal checks (log into Hyprland, then re-run)"
fi

if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    if pgrep -x waybar >/dev/null; then
        echo "OK: waybar running"
    else
        echo "FAIL: waybar not running (check ~/.cache/hyprmaster/waybar.log)"
        FAIL=1
    fi
    if pgrep -x swww-daemon >/dev/null; then
        echo "OK: swww-daemon running"
    else
        echo "WARN: swww-daemon not running"
    fi
fi

[ "$FAIL" -eq 0 ] && echo "=== PASS ===" || { echo "=== FAIL ==="; exit 1; }
