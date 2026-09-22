#!/bin/bash
# Shanmukha Kumar Karra — validate config sources in repo

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HYPR="${ROOT}/.config/hypr"
FAIL=0

while IFS= read -r line; do
    path=$(echo "$line" | sed -n 's/.*= *//p' | tr -d ' ')
    [ -z "$path" ] && continue
    expanded="${path//\$HOME/${HOME}}"
    expanded="${expanded/#\~/$HOME}"
    if [[ "$expanded" != /* ]]; then
        expanded="${HYPR}/${expanded}"
    fi
    if [ ! -f "$expanded" ] && [[ "$line" == *"source"* ]]; then
        # paths relative to deployed home — check repo equivalents
        repo_path="${ROOT}/.config${expanded#"$HOME/.config"}"
        if [ ! -f "$repo_path" ] && [ ! -f "$expanded" ]; then
            echo "WARN: source may be generated at runtime: $expanded"
        fi
    fi
done < <(grep -rh '^source' "$HYPR" --include='*.conf' 2>/dev/null || true)

for f in \
    "$HYPR/hyprland.conf" \
    "$HYPR/UserConfigs/Paths.conf" \
    "$HYPR/UserConfigs/Startup_Apps.conf" \
    "$HYPR/generated/matugen-hyprland.conf" \
    "$HYPR/wallpapers/default.jpg" \
    "$HYPR/UserScripts/skkarra-theme-switch.sh" \
    "$HYPR/UserScripts/wallpaper-bootstrap.sh" \
    "$HYPR/UserScripts/hyprmaster-ui.sh"; do
    [ -f "$f" ] || { echo "FAIL: missing $f"; FAIL=1; }
done

bash -n "$HYPR/UserScripts/skkarra-theme-switch.sh" || FAIL=1

[ "$FAIL" -eq 0 ] && echo "Repo config structure OK" || exit 1
