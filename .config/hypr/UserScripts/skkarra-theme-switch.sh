#!/bin/bash
# Shanmukha Kumar Karra — full theme pipeline (wallpaper → matugen → reload)

set -euo pipefail

THEMES_DIR="${HOME}/.config/hypr/themes"
CACHE_DIR="${HOME}/.cache/hyprmaster"
STATE_FILE="${CACHE_DIR}/theme"
WALL_STATE="${CACHE_DIR}/current-wallpaper"
GENERATED_HYPR="${HOME}/.config/hypr/generated/matugen-hyprland.conf"
GENERATED_DECO="${HOME}/.config/hypr/generated/theme-decoration.conf"
WAYBAR_STYLE="${HOME}/.config/waybar/style.css"
WAYBAR_CONFIG="${HOME}/.config/waybar/config"
MATUGEN_CFG="${HOME}/.config/matugen/config.toml"
WALLDIR="${WALLDIR:-$HOME/Pictures/wallpapers}"

THEME_CYCLE=(
    noir-minimal
    liquid-glass-dark
    liquid-glass-light
    noir
    catppuccin-mocha
    nord
    tokyo-night
    everforest
)

mkdir -p "$CACHE_DIR" "${HOME}/.config/hypr/generated" "${HOME}/.config/rofi/wallust"

load_meta() {
    local theme="$1"
    local meta="${THEMES_DIR}/${theme}/meta.env"
    BASE_COLOR=""
    MODE="dark"
    WALLPAPER=""
    SOURCE="matugen"
    WAYBAR_CONFIG_CHOICE="sane"
    GTK_THEME=""
    [ -f "$meta" ] && source "$meta"
}

resolve_wallpaper() {
    local theme="$1"
    local dir="${THEMES_DIR}/${theme}"
    local img="" f

    load_meta "$theme"

    if [ -n "${WALLPAPER:-}" ] && [ -f "${dir}/${WALLPAPER}" ]; then
        echo "${dir}/${WALLPAPER}"
        return 0
    fi
    for f in "${dir}"/wallpaper.{jpg,jpeg,png,webp}; do
        [ -f "$f" ] && { echo "$f"; return 0; }
    done
    if [ -d "${WALLDIR}/${theme}" ]; then
        img=$(find "${WALLDIR}/${theme}" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | head -n1)
        [ -n "$img" ] && { echo "$img"; return 0; }
    fi
    if [ -d "$WALLDIR" ]; then
        img=$(find "$WALLDIR" -maxdepth 2 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | head -n1)
        [ -n "$img" ] && { echo "$img"; return 0; }
    fi
    [ -f "${HOME}/.config/hypr/wallpapers/default.jpg" ] && echo "${HOME}/.config/hypr/wallpapers/default.jpg"
}

ensure_swww() {
    pgrep -x swww-daemon >/dev/null 2>&1 || swww-daemon --format xrgb >>"${CACHE_DIR}/wallpaper.log" 2>&1 &
    local i
    for i in $(seq 1 50); do
        compgen -G "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/wayland-*-swww*.sock" >/dev/null 2>&1 && return 0
        sleep 0.1
    done
    return 1
}

apply_wallpaper_swww() {
    local img="$1"
    [ -f "$img" ] || return 1
    command -v swww >/dev/null 2>&1 || return 1
    ensure_swww || true
    sleep 0.2
    swww img "$img" --transition-type grow --transition-duration 1 2>>"${CACHE_DIR}/wallpaper.log" \
        || swww img "$img" 2>>"${CACHE_DIR}/wallpaper.log"
    echo "$img" >"$WALL_STATE"
}

apply_static_fallback() {
    local theme="$1"
    local dir="${THEMES_DIR}/${theme}"
    cp "${dir}/hypr-colors.conf" "$GENERATED_HYPR"
    if [ -f "${dir}/waybar.css" ]; then
        rm -f "$WAYBAR_STYLE"
        cp "${dir}/waybar.css" "$WAYBAR_STYLE"
    fi
}

run_matugen() {
    local theme="$1"
    local img="${2:-}"
    load_meta "$theme"

    if ! command -v matugen >/dev/null 2>&1; then
        apply_static_fallback "$theme"
        return 1
    fi

    if [ -f "$img" ]; then
        if matugen image "$img" -c "$MATUGEN_CFG" >>"${CACHE_DIR}/matugen.log" 2>&1; then
            rm -f "$WAYBAR_STYLE"
            return 0
        fi
    fi
    if [ -n "${BASE_COLOR:-}" ]; then
        if matugen color hex "$BASE_COLOR" -c "$MATUGEN_CFG" >>"${CACHE_DIR}/matugen.log" 2>&1; then
            rm -f "$WAYBAR_STYLE"
            return 0
        fi
    fi
    apply_static_fallback "$theme"
    return 1
}

apply_decoration() {
    local theme="$1"
    local dir="${THEMES_DIR}/${theme}"
    if [ -f "${dir}/decoration.conf" ]; then
        cp "${dir}/decoration.conf" "$GENERATED_DECO"
    elif [ -f "${THEMES_DIR}/noir-minimal/decoration.conf" ]; then
        cp "${THEMES_DIR}/noir-minimal/decoration.conf" "$GENERATED_DECO"
    fi
}

apply_waybar_config() {
    local theme="$1"
    load_meta "$theme"
    local cfg="sane"
    case "${WAYBAR_CONFIG_CHOICE:-sane}" in
        minimal) cfg="minimal" ;;
        sane|*) cfg="sane" ;;
    esac
    if [ "$theme" = "liquid-glass-dark" ] || [ "$theme" = "liquid-glass-light" ]; then
        cfg="minimal"
    fi
    local src="${HOME}/.config/waybar/config.${cfg}"
    [ -f "$src" ] && cp "$src" "$WAYBAR_CONFIG"
}

reload_desktop() {
    [ "${HYPRMASTER_RELOAD_UI:-1}" = "0" ] && return 0

    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        hyprctl reload >/dev/null 2>&1 || true
    fi

    if command -v kitty >/dev/null 2>&1 && pgrep -x kitty >/dev/null 2>&1; then
        kitty @ set-colors --all -c "${HOME}/.config/kitty/kitty-colors.conf" 2>/dev/null || true
    fi

    pkill -x waybar 2>/dev/null || true
    sleep 0.25
    waybar >>"${CACHE_DIR}/waybar.log" 2>&1 &

    pkill -x swaync 2>/dev/null || true
    sleep 0.2
    swaync >>"${CACHE_DIR}/swaync.log" 2>&1 &
}

apply_theme() {
    local theme="$1"
    local dir="${THEMES_DIR}/${theme}"
    [ -d "$dir" ] || { echo "Unknown theme: $theme" >&2; exit 1; }

    local wall
    wall=$(resolve_wallpaper "$theme" || true)

    if [ -n "${wall:-}" ] && [ -f "$wall" ]; then
        apply_wallpaper_swww "$wall" || true
    fi

    run_matugen "$theme" "${wall:-}" || true
    apply_decoration "$theme"
    apply_waybar_config "$theme"

    bash "${HOME}/.config/hypr/UserScripts/gtk-theme-apply.sh" "$theme" || true

    echo "$theme" >"$STATE_FILE"
    reload_desktop
    notify-send -u low "hyprmaster" "Theme: $theme" 2>/dev/null || true
}

apply_wallpaper() {
    local img="$1"
    [ -f "$img" ] || { echo "Missing wallpaper: $img" >&2; exit 1; }
    local cur
    cur=$(current_theme)

    apply_wallpaper_swww "$img"
    run_matugen "$cur" "$img" || true
    reload_desktop
}

list_themes() {
    basename -a "$THEMES_DIR"/* 2>/dev/null | sort
}

current_theme() {
    [ -f "$STATE_FILE" ] && cat "$STATE_FILE" || echo "noir-minimal"
}

next_in_cycle() {
    local cur i found=0
    cur=$(current_theme)
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
    apply) apply_theme "${2:-noir-minimal}" ;;
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
