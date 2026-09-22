#!/bin/bash
# Shanmukha Kumar Karra — theme switcher

set -euo pipefail

THEMES_DIR="${HOME}/.config/hypr/themes"
CACHE_DIR="${HOME}/.cache/hyprmaster"
STATE_FILE="${CACHE_DIR}/theme"
GENERATED_HYPR="${HOME}/.config/hypr/generated/matugen-hyprland.conf"
GENERATED_DECO="${HOME}/.config/hypr/generated/theme-decoration.conf"
WAYBAR_STYLE="${HOME}/.config/waybar/style.css"
WAYBAR_CONFIG="${HOME}/.config/waybar/config"
WALLDIR="${WALLDIR:-$HOME/Downloads/Wallpapers}"
BOOTSTRAP="${HOME}/.config/hypr/UserScripts/wallpaper-bootstrap.sh"

# Preferred cycle order (Super+Alt+D / WaybarStyles)
THEME_CYCLE=(
    liquid-glass-dark
    liquid-glass-light
    noir
    catppuccin-mocha
    nord
    tokyo-night
    everforest
)

mkdir -p "$CACHE_DIR" "${HOME}/.config/hypr/generated" "${HOME}/.config/rofi/wallust"

list_themes() {
    basename -a "$THEMES_DIR"/* 2>/dev/null | sort
}

current_theme() {
    [ -f "$STATE_FILE" ] && cat "$STATE_FILE" || echo "liquid-glass-dark"
}

apply_preset_files() {
    local theme="$1"
    local dir="${THEMES_DIR}/${theme}"
    if [ ! -d "$dir" ]; then
        echo "Unknown theme: $theme" >&2
        exit 1
    fi
    cp "${dir}/hypr-colors.conf" "$GENERATED_HYPR"
    if [ -f "${dir}/decoration.conf" ]; then
        cp "${dir}/decoration.conf" "$GENERATED_DECO"
    elif [ -f "${THEMES_DIR}/noir/decoration.conf" ]; then
        cp "${THEMES_DIR}/noir/decoration.conf" "$GENERATED_DECO"
    fi
    if [ -f "${dir}/waybar.css" ]; then
        ln -sf "${dir}/waybar.css" "$WAYBAR_STYLE"
    elif [ -f "${THEMES_DIR}/liquid-glass-dark/waybar.css" ]; then
        ln -sf "${THEMES_DIR}/liquid-glass-dark/waybar.css" "$WAYBAR_STYLE"
    fi
    echo "$theme" > "$STATE_FILE"
}

run_matugen_color() {
    local theme="$1"
    local meta="${THEMES_DIR}/${theme}/meta.env"
    [ -f "$meta" ] || return 0
    # shellcheck disable=SC1090
    source "$meta"
    if command -v matugen >/dev/null 2>&1 && [ -n "${BASE_COLOR:-}" ]; then
        matugen color hex "$BASE_COLOR" -c "${HOME}/.config/matugen/config.toml" 2>/dev/null || true
    fi
}

reload_ui() {
    [ "${HYPRMASTER_RELOAD_UI:-1}" = "0" ] && return 0
    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        hyprctl reload >/dev/null 2>&1 || true
    fi
    pkill -x waybar 2>/dev/null || true
    sleep 0.2
    waybar >/dev/null 2>&1 &
    pkill -x swaync 2>/dev/null || true
    sleep 0.2
    swaync >/dev/null 2>&1 &
}

apply_theme() {
    local theme="$1"
    apply_preset_files "$theme"
    run_matugen_color "$theme"
    if [ -f "${HOME}/.config/waybar/config.minimal" ]; then
        cp "${HOME}/.config/waybar/config.minimal" "$WAYBAR_CONFIG"
    fi
    [ -x "$BOOTSTRAP" ] && bash "$BOOTSTRAP" || true
    reload_ui
    notify-send -u low "hyprmaster" "Theme: $theme" 2>/dev/null || true
}

apply_wallpaper() {
    local img="$1"
    [ -f "$img" ] || { echo "Missing wallpaper: $img" >&2; exit 1; }
    swww-daemon --format xrgb 2>/dev/null || true
    swww img "$img" --transition-type grow --transition-duration 1 2>/dev/null || swww img "$img"
    if command -v matugen >/dev/null 2>&1; then
        matugen image "$img" -c "${HOME}/.config/matugen/config.toml" 2>/dev/null || true
    fi
    reload_ui
}

next_in_cycle() {
    local cur
    cur=$(current_theme)
    local i found=0
    for i in "${!THEME_CYCLE[@]}"; do
        if [ "${THEME_CYCLE[$i]}" = "$cur" ]; then
            apply_theme "${THEME_CYCLE[$(( (i + 1) % ${#THEME_CYCLE[@]} ))]}"
            found=1
            break
        fi
    done
    [ "$found" = "1" ] || apply_theme "${THEME_CYCLE[0]}"
}

cmd="${1:-}"
case "$cmd" in
    list) list_themes ;;
    current) current_theme ;;
    apply) apply_theme "${2:-liquid-glass-dark}" ;;
    next) next_in_cycle ;;
    wallpaper) apply_wallpaper "${2:-}" ;;
    random-wallpaper)
        mapfile -t pics < <(find "$WALLDIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) 2>/dev/null)
        [ "${#pics[@]}" -gt 0 ] && apply_wallpaper "${pics[$RANDOM % ${#pics[@]}]}"
        ;;
    *)
        echo "Usage: $0 list|current|apply <name>|next|wallpaper <path>|random-wallpaper"
        exit 1
        ;;
esac
