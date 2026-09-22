#!/bin/bash
# Shanmukha Kumar Karra — optional GTK theme from preset meta.env

theme="${1:-}"
[ -n "$theme" ] || exit 0
command -v gsettings >/dev/null 2>&1 || exit 0

meta="${HOME}/.config/hypr/themes/${theme}/meta.env"
[ -f "$meta" ] || exit 0
# shellcheck disable=SC1090
source "$meta"
[ -n "${GTK_THEME:-}" ] || exit 0

gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true
