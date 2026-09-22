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

find_images() {
    local dir="$1"
    [ -d "$dir" ] || return 0
    find "$dir" -maxdepth 2 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null
}

collect_candidates() {
    local -a all=()
    local dir img
    for dir in \
        "${WALLDIR:-$HOME/Pictures/wallpapers}" \
        "$HOME/Pictures/wallpapers" \
        "$HOME/Pictures/Wallpapers" \
        "$HOME/Downloads/Wallpapers"; do
        while IFS= read -r img; do
            [ -n "$img" ] && all+=("$img")
        done < <(find_images "$dir")
    done
    [ -f "$DEFAULT" ] && all+=("$DEFAULT")
    [ -f "$DEFAULT_PNG" ] && all+=("$DEFAULT_PNG")
    shopt -s nullglob
    local sys=( $HYPR_BG_GLOB )
    shopt -u nullglob
    all+=("${sys[@]}")
    printf '%s\n' "${all[@]}"
}

ensure_swww_daemon() {
    if pgrep -x swww-daemon >/dev/null 2>&1; then
        return 0
    fi
    swww-daemon --format xrgb >>"$LOG" 2>&1 &
    local i
    for i in $(seq 1 50); do
        if compgen -G "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/wayland-*-swww*.sock" >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.1
    done
    log "swww-daemon socket not ready"
    return 1
}

apply_swww_one() {
    local img="$1"
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

apply_swww() {
    if ! command -v swww >/dev/null 2>&1; then
        log "swww not installed"
        return 1
    fi
    ensure_swww_daemon || true
    sleep 0.2
    local img
    while IFS= read -r img; do
        [ -f "$img" ] || continue
        apply_swww_one "$img" && return 0
    done < <(collect_candidates | awk '!seen[$0]++')
    return 1
}

main() {
    if [ -z "${WAYLAND_DISPLAY:-}" ] && [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        local preview
        preview=$(collect_candidates | head -n1)
        log "no Wayland session; would use ${preview:-none}"
        exit 0
    fi
    apply_swww || exit 1
}

main "$@"
