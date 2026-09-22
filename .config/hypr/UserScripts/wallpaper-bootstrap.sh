#!/bin/bash
# Shanmukha Kumar Karra — ensure a wallpaper is shown via swww

set -euo pipefail

LOG="${HOME}/.cache/hyprmaster/wallpaper.log"
DEFAULT="${HOME}/.config/hypr/wallpapers/default.jpg"
DEFAULT_PNG="${HOME}/.config/hypr/wallpapers/default.png"
HYPR_BG_GLOB="/usr/share/backgrounds/hyprland/*.{jpg,jpeg,png}"

mkdir -p "${HOME}/.cache/hyprmaster"

log() {
    echo "$(date -Iseconds) $*" >>"$LOG"
}

find_first_image() {
    local dir="$1"
    [ -d "$dir" ] || return 1
    find "$dir" -maxdepth 2 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | head -n1
}

pick_wallpaper() {
    local img=""
    for dir in \
        "${WALLDIR:-$HOME/Downloads/Wallpapers}" \
        "$HOME/Downloads/Wallpapers" \
        "$HOME/Pictures" \
        "$HOME/Pictures/Wallpapers"; do
        img=$(find_first_image "$dir") && [ -n "$img" ] && echo "$img" && return 0
    done
    if [ -f "$DEFAULT" ]; then
        echo "$DEFAULT"
        return 0
    fi
    if [ -f "$DEFAULT_PNG" ]; then
        echo "$DEFAULT_PNG"
        return 0
    fi
    shopt -s nullglob
    local candidates=( $HYPR_BG_GLOB )
    shopt -u nullglob
    if [ "${#candidates[@]}" -gt 0 ]; then
        echo "${candidates[0]}"
        return 0
    fi
    return 1
}

apply_swww() {
    local img="$1"
    if ! command -v swww >/dev/null 2>&1; then
        log "swww not installed"
        return 1
    fi
    swww-daemon --format xrgb 2>/dev/null || true
    sleep 0.3
    if swww img "$img" --transition-type grow --transition-duration 1 2>>"$LOG"; then
        log "applied $img"
        return 0
    fi
    if swww img "$img" 2>>"$LOG"; then
        log "applied (no transition) $img"
        return 0
    fi
    log "swww img failed for $img"
    return 1
}

main() {
    local img
    if ! img=$(pick_wallpaper); then
        log "no wallpaper candidate found"
        exit 1
    fi
    if [ -z "${WAYLAND_DISPLAY:-}" ] && [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        log "no Wayland session; selected $img (skip swww)"
        exit 0
    fi
    apply_swww "$img" || exit 1
}

main "$@"
