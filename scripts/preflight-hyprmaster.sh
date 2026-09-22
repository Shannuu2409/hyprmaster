#!/bin/bash
# Shanmukha Kumar Karra — pre-push checks (no Hyprland session required)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HYPR="${ROOT}/.config/hypr"
FAIL=0

echo "=== hyprmaster preflight ==="

if Hyprland --verify-config -c "${HYPR}/hyprland.conf" 2>&1 | grep -q 'config ok'; then
    echo "OK: Hyprland --verify-config"
else
    echo "FAIL: Hyprland config"
    Hyprland --verify-config -c "${HYPR}/hyprland.conf" 2>&1 | tail -20
    FAIL=1
fi

for f in \
    "${HYPR}/wallpapers/default.jpg" \
    "${HYPR}/UserScripts/wallpaper-bootstrap.sh" \
    "${HYPR}/UserScripts/hyprmaster-ui.sh"; do
    if [ ! -f "$f" ]; then
        echo "FAIL: missing $f"
        FAIL=1
    fi
done

while IFS= read -r -d '' script; do
    case "$(basename "$script")" in
        RofiEmoji.sh) continue ;;
    esac
    bash -n "$script" || { echo "FAIL: bash -n $script"; FAIL=1; }
done < <(find "${HYPR}/UserScripts" "${HYPR}/scripts" "${ROOT}/scripts" -name '*.sh' -print0 2>/dev/null)

for json in "${ROOT}/.config/waybar/config" "${ROOT}/.config/waybar/config.minimal"; do
    if command -v jq >/dev/null 2>&1; then
        jq empty "$json" || { echo "FAIL: invalid JSON $json"; FAIL=1; }
    fi
done

if grep -rqE '^\s*backdrop-filter\s*:' "${ROOT}/.config/hypr/themes" --include='waybar.css' 2>/dev/null; then
    echo "FAIL: backdrop-filter in waybar.css (breaks Waybar 0.15 on Ubuntu)"
    FAIL=1
else
    echo "OK: waybar CSS compatible with Waybar 0.15"
fi

if env -u WAYLAND_DISPLAY -u HYPRLAND_INSTANCE_SIGNATURE bash "${HYPR}/UserScripts/wallpaper-bootstrap.sh"; then
    echo "OK: wallpaper-bootstrap (dry/no display ok)"
else
    echo "FAIL: wallpaper-bootstrap"
    FAIL=1
fi

bash "${ROOT}/scripts/validate-repo-config.sh" || FAIL=1

[ "$FAIL" -eq 0 ] && echo "=== preflight PASS ===" || { echo "=== preflight FAIL ==="; exit 1; }
