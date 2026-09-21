#!/bin/bash
# Shanmukha Kumar Karra — hyprmaster populate

set -e

MIN_FREE_MB=500

echo "============================================"
echo "hyprmaster populate"
echo "============================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SOURCE="$SCRIPT_DIR/.config"

avail_kb=$(df -Pk "$HOME" | awk 'NR==2 {print $4}')
avail_mb=$((avail_kb / 1024))
if [ "$avail_mb" -lt "$MIN_FREE_MB" ]; then
    echo "ERROR: Need at least ${MIN_FREE_MB}MB free on $HOME (have ~${avail_mb}MB)."
    echo "Remove stale backups e.g. ~/.config.backup.* then retry."
    exit 1
fi

echo "Source: $CONFIG_SOURCE"
echo "Target: $HOME/.config (~${avail_mb}MB free)"

BACKUP_DIR="$HOME/.config.hyprmaster-backup.$(date +%Y%m%d_%H%M%S)"
if [ "${HYPRMASTER_SKIP_BACKUP:-0}" != "1" ] && [ "${HYPRMASTER_BACKUP:-0}" = "1" ] && [ -d "$HOME/.config/hypr" ]; then
    echo "Backing up hypr + waybar to: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    cp -r "$HOME/.config/hypr" "$BACKUP_DIR/" 2>/dev/null || true
    [ -d "$HOME/.config/waybar" ] && cp -r "$HOME/.config/waybar" "$BACKUP_DIR/" 2>/dev/null || true
fi

mkdir -p "$HOME/.config"

copy_into() {
    local name="$1"
    local src="$CONFIG_SOURCE/$name"
    local dest="$HOME/.config/$name"
    if [ -d "$src" ]; then
        echo "  - $name"
        mkdir -p "$dest"
        if command -v rsync >/dev/null 2>&1; then
            rsync -a --delete \
                --exclude 'wallpaper_effects/' \
                --exclude '*.save' \
                --exclude '*.save.*' \
                --exclude '* (copy *)*' \
                "$src/" "$dest/"
        else
            cp -r "$src/." "$dest/"
        fi
    fi
}

echo "Copying..."
for dir in hypr waybar kitty fish rofi wofi swaylock swaync wlogout fastfetch btop tofi swappy yazi nwg-look qt5ct qt6ct Kvantum matugen; do
    copy_into "$dir"
done

if [ -d "$CONFIG_SOURCE/mpd" ]; then
    mkdir -p "$HOME/.config/mpd"
    rsync -a "$CONFIG_SOURCE/mpd/" "$HOME/.config/mpd/" 2>/dev/null || cp -r "$CONFIG_SOURCE/mpd/." "$HOME/.config/mpd/"
fi
if [ -d "$CONFIG_SOURCE/ncmpcpp" ]; then
    mkdir -p "$HOME/.config/ncmpcpp"
    rsync -a "$CONFIG_SOURCE/ncmpcpp/" "$HOME/.config/ncmpcpp/" 2>/dev/null || cp -r "$CONFIG_SOURCE/ncmpcpp/." "$HOME/.config/ncmpcpp/"
fi
if [ -d "$CONFIG_SOURCE/starship" ]; then
    copy_into starship
fi
[ -f "$CONFIG_SOURCE/starship.toml" ] && cp "$CONFIG_SOURCE/starship.toml" "$HOME/.config/"

chmod +x "$HOME/.config/hypr/scripts/"*.sh 2>/dev/null || true
chmod +x "$HOME/.config/hypr/UserScripts/"*.sh 2>/dev/null || true
chmod +x "$HOME/.config/hypr/initial-boot.sh" 2>/dev/null || true

PROFILE_MARKER="# hyprmaster profile"
if ! grep -q "$PROFILE_MARKER" "$HOME/.profile" 2>/dev/null; then
    cat >> "$HOME/.profile" << 'EOF'

# hyprmaster profile
export QT_QPA_PLATFORMTHEME=qt6ct
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
EOF
fi

echo "Done. Log into Hyprland and run: $SCRIPT_DIR/scripts/verify-hyprland.sh"
