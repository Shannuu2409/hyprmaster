#!/usr/bin/env bash
# ============================================================
#  populate.sh — Copy all rice configs into Hyprland-master
#  Run this ONCE from the Hyprland-master directory:
#      bash populate.sh
# ============================================================
set -euo pipefail

DEST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"
CONF="$HOME/.config"

mkdir -p "$DEST"

copy_if_exists() {
    local src="$1"
    local name="$2"
    if [ -d "$src" ]; then
        cp -r "$src" "$DEST/$name"
        echo "  ✓ $name"
    elif [ -f "$src" ]; then
        cp "$src" "$DEST/$name"
        echo "  ✓ $name"
    else
        echo "  ~ skipped: $name (not found)"
    fi
}

echo ""
echo "Copying rice configs into $DEST ..."
echo ""

copy_if_exists "$CONF/hypr"         hypr
copy_if_exists "$CONF/waybar"       waybar
copy_if_exists "$CONF/eww"          eww
copy_if_exists "$CONF/fish"         fish
copy_if_exists "$CONF/kitty"        kitty
copy_if_exists "$CONF/rofi"         rofi
copy_if_exists "$CONF/wofi"         wofi
copy_if_exists "$CONF/tofi"         tofi
copy_if_exists "$CONF/wallust"      wallust
copy_if_exists "$CONF/swaylock"     swaylock
copy_if_exists "$CONF/swaync"       swaync
copy_if_exists "$CONF/wlogout"      wlogout
copy_if_exists "$CONF/gtk-2.0"      gtk-2.0
copy_if_exists "$CONF/gtk-3.0"      gtk-3.0
copy_if_exists "$CONF/gtk-4.0"      gtk-4.0
copy_if_exists "$CONF/qt5ct"        qt5ct
copy_if_exists "$CONF/qt6ct"        qt6ct
copy_if_exists "$CONF/Kvantum"      Kvantum
copy_if_exists "$CONF/fastfetch"    fastfetch
copy_if_exists "$CONF/btop"         btop
copy_if_exists "$CONF/yazi"         yazi
copy_if_exists "$CONF/mpd"          mpd
copy_if_exists "$CONF/ncmpcpp"      ncmpcpp
copy_if_exists "$CONF/swappy"       swappy
copy_if_exists "$CONF/matugen"      matugen
copy_if_exists "$CONF/nwg-look"     nwg-look
copy_if_exists "$CONF/dunst"        dunst
copy_if_exists "$CONF/mako"         mako
copy_if_exists "$CONF/foot"         foot
copy_if_exists "$CONF/fuzzel"       fuzzel
copy_if_exists "$CONF/cava"         cava
copy_if_exists "$CONF/kew"          kew
copy_if_exists "$CONF/rmpc"         rmpc
copy_if_exists "$CONF/mpv"          mpv
copy_if_exists "$CONF/mpDris2"      mpDris2
copy_if_exists "$CONF/sptlrx"       sptlrx
copy_if_exists "$CONF/starship.toml" starship.toml

# Wallpapers
WALLDIR=""
for d in "$HOME/Pictures/wallpapers" "$HOME/Pictures/Wallpapers"; do
    [ -d "$d" ] && WALLDIR="$d" && break
done
if [ -n "$WALLDIR" ]; then
    cp -r "$WALLDIR" "$(dirname "$DEST")/wallpapers"
    echo "  ✓ wallpapers"
else
    mkdir -p "$(dirname "$DEST")/wallpapers"
    echo "  ~ wallpapers/ created empty (add yours here)"
fi

echo ""
echo "All done! Structure:"
find "$(dirname "$DEST")" -maxdepth 2 -type d | sort
echo ""
echo "Total size:"
du -sh "$(dirname "$DEST")"
