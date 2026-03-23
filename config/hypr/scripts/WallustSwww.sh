#!/bin/bash
# Wallust Colors for current wallpaper

cache_dir="$HOME/.cache/swww/"
ln_success=false

# Get focused monitor
current_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')
echo "$current_monitor"

cache_file="$cache_dir$current_monitor"
echo "$cache_file"

# Ensure directories exist
mkdir -p "$HOME/.config/rofi"
mkdir -p "$HOME/.config/hypr/wallpaper_effects"

if [ -f "$cache_file" ]; then
    # Extract wallpaper path safely
    wallpaper_path=$(strings "$cache_file" | grep '^/' | head -n 1)
    echo "Wallpaper detected: $wallpaper_path"

    if [ -f "$wallpaper_path" ]; then
        if ln -sf "$wallpaper_path" "$HOME/.config/rofi/.current_wallpaper"; then
            ln_success=true
        fi

        cp "$wallpaper_path" \
           "$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
    else
        echo "Wallpaper path invalid or empty."
    fi
else
    echo "Cache file not found."
fi

if [ "$ln_success" = true ]; then
    echo "Running wallust..."
    wallust run "$wallpaper_path" -s &
fi

