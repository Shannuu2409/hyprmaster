#!/bin/bash

# ===========================================
# Hyprland Config Populate Script
# ===========================================

set -e

echo "============================================"
echo "Hyprland Config Populate Script"
echo "============================================"

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SOURCE="$SCRIPT_DIR/.config"

echo "Source directory: $CONFIG_SOURCE"
echo "Target directory: $HOME/.config"

# Create backup directory with timestamp
BACKUP_DIR="$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"
echo "Creating backup in: $BACKUP_DIR"

# ===========================================
# Backup existing configs
# ===========================================

if [ -d "$HOME/.config" ]; then
    echo "Backing up existing configurations..."
    cp -r "$HOME/.config" "$BACKUP_DIR"
    echo "Backup created successfully"
fi

# ===========================================
# Create necessary directories
# ===========================================

echo "Creating necessary directories..."
mkdir -p "$HOME/.config"

# ===========================================
# Copy configuration files
# ===========================================

echo "Copying configuration files..."

# Copy Hypr configuration
if [ -d "$CONFIG_SOURCE/hypr" ]; then
    echo "  - Copying Hypr configs..."
    cp -r "$CONFIG_SOURCE/hypr/"* "$HOME/.config/"
fi

# Copy Waybar configuration
if [ -d "$CONFIG_SOURCE/waybar" ]; then
    echo "  - Copying Waybar configs..."
    cp -r "$CONFIG_SOURCE/waybar/"* "$HOME/.config/"
fi

# Copy Kitty terminal configuration
if [ -d "$CONFIG_SOURCE/kitty" ]; then
    echo "  - Copying Kitty configs..."
    cp -r "$CONFIG_SOURCE/kitty/"* "$HOME/.config/"
fi

# Copy Fish shell configuration
if [ -d "$CONFIG_SOURCE/fish" ]; then
    echo "  - Copying Fish configs..."
    cp -r "$CONFIG_SOURCE/fish/"* "$HOME/.config/"
fi

# Copy Rofi configuration
if [ -d "$CONFIG_SOURCE/rofi" ]; then
    echo "  - Copying Rofi configs..."
    cp -r "$CONFIG_SOURCE/rofi/"* "$HOME/.config/"
fi

# Copy Wofi configuration
if [ -d "$CONFIG_SOURCE/wofi" ]; then
    echo "  - Copying Wofi configs..."
    cp -r "$CONFIG_SOURCE/wofi/"* "$HOME/.config/"
fi

# Copy Swaylock configuration
if [ -d "$CONFIG_SOURCE/swaylock" ]; then
    echo "  - Copying Swaylock configs..."
    cp -r "$CONFIG_SOURCE/swaylock/"* "$HOME/.config/"
fi

# Copy SwayNC configuration
if [ -d "$CONFIG_SOURCE/swaync" ]; then
    echo "  - Copying SwayNC configs..."
    cp -r "$CONFIG_SOURCE/swaync/"* "$HOME/.config/"
fi

# Copy Wlogout configuration
if [ -d "$CONFIG_SOURCE/wlogout" ]; then
    echo "  - Copying Wlogout configs..."
    cp -r "$CONFIG_SOURCE/wlogout/"* "$HOME/.config/"
fi

# Copy Wallust configuration
if [ -d "$CONFIG_SOURCE/wallust" ]; then
    echo "  - Copying Wallust configs..."
    cp -r "$CONFIG_SOURCE/wallust/"* "$HOME/.config/"
fi

# Copy Fastfetch configuration
if [ -d "$CONFIG_SOURCE/fastfetch" ]; then
    echo "  - Copying Fastfetch configs..."
    cp -r "$CONFIG_SOURCE/fastfetch/"* "$HOME/.config/"
fi

# Copy btop configuration
if [ -d "$CONFIG_SOURCE/btop" ]; then
    echo "  - Copying btop configs..."
    cp -r "$CONFIG_SOURCE/btop/"* "$HOME/.config/"
fi

# Copy eww configuration
if [ -d "$CONFIG_SOURCE/eww" ]; then
    echo "  - Copying eww configs..."
    cp -r "$CONFIG_SOURCE/eww/"* "$HOME/.config/"
fi

# Copy tofi configuration
if [ -d "$CONFIG_SOURCE/tofi" ]; then
    echo "  - Copying tofi configs..."
    cp -r "$CONFIG_SOURCE/tofi/"* "$HOME/.config/"
fi

# Copy swappy configuration
if [ -d "$CONFIG_SOURCE/swappy" ]; then
    echo "  - Copying swappy configs..."
    cp -r "$CONFIG_SOURCE/swappy/"* "$HOME/.config/"
fi

# Copy mpd configuration
if [ -d "$CONFIG_SOURCE/mpd" ]; then
    echo "  - Copying mpd configs..."
    mkdir -p "$HOME/.config/mpd"
    cp -r "$CONFIG_SOURCE/mpd/"* "$HOME/.config/mpd/"
fi

# Copy ncmpcpp configuration
if [ -d "$CONFIG_SOURCE/ncmpcpp" ]; then
    echo "  - Copying ncmpcpp configs..."
    mkdir -p "$HOME/.config/ncmpcpp"
    cp -r "$CONFIG_SOURCE/ncmpcpp/"* "$HOME/.config/ncmpcpp/"
fi

# Copy yazi configuration
if [ -d "$CONFIG_SOURCE/yazi" ]; then
    echo "  - Copying yazi configs..."
    cp -r "$CONFIG_SOURCE/yazi/"* "$HOME/.config/"
fi

# Copy starship configuration
if [ -d "$CONFIG_SOURCE/starship" ]; then
    echo "  - Copying starship configs..."
    cp -r "$CONFIG_SOURCE/starship/"* "$HOME/.config/"
fi

if [ -f "$CONFIG_SOURCE/starship.toml" ]; then
    cp "$CONFIG_SOURCE/starship.toml" "$HOME/.config/"
fi

# Copy nwg-look configuration
if [ -d "$CONFIG_SOURCE/nwg-look" ]; then
    echo "  - Copying nwg-look configs..."
    cp -r "$CONFIG_SOURCE/nwg-look/"* "$HOME/.config/"
fi

# Copy qt5ct configuration
if [ -d "$CONFIG_SOURCE/qt5ct" ]; then
    echo "  - Copying qt5ct configs..."
    cp -r "$CONFIG_SOURCE/qt5ct/"* "$HOME/.config/"
fi

# Copy qt6ct configuration
if [ -d "$CONFIG_SOURCE/qt6ct" ]; then
    echo "  - Copying qt6ct configs..."
    cp -r "$CONFIG_SOURCE/qt6ct/"* "$HOME/.config/"
fi

# Copy Kvantum configuration
if [ -d "$CONFIG_SOURCE/Kvantum" ]; then
    echo "  - Copying Kvantum configs..."
    cp -r "$CONFIG_SOURCE/Kvantum/"* "$HOME/.config/"
fi

# ===========================================
# Set permissions
# ===========================================

echo "Setting permissions..."
chmod -R 755 "$HOME/.config"/*

# ===========================================
# Additional setup
# ===========================================

echo "Additional setup..."

# Set fish as default shell (if installed)
if command -v fish &> /dev/null; then
    if [ "$SHELL" != "$(which fish)" ]; then
        echo "Setting fish as default shell..."
        chsh -s "$(which fish)"
    fi
fi

# Set up environment variables
if ! grep -q "QT_QPA_PLATFORMTHEME=qt5ct" "$HOME/.profile" 2>/dev/null; then
    echo 'export QT_QPA_PLATFORMTHEME=qt5ct' >> "$HOME/.profile"
fi

if ! grep -q "XDG_CURRENT_DESKTOP=Hyprland" "$HOME/.profile" 2>/dev/null; then
    echo 'export XDG_CURRENT_DESKTOP=Hyprland' >> "$HOME/.profile"
fi

if ! grep -q "XDG_SESSION_TYPE=wayland" "$HOME/.profile" 2>/dev/null; then
    echo 'export XDG_SESSION_TYPE=wayland' >> "$HOME/.profile"
fi

if ! grep -q "GBM_BACKEND=nvidia-drm" "$HOME/.profile" 2>/dev/null; then
    echo 'export GBM_BACKEND=nvidia-drm' >> "$HOME/.profile"
fi

if ! grep -q "LIBVA_DRIVER_NAME=zva" "$HOME/.profile" 2>/dev/null; then
    echo 'export LIBVA_DRIVER_NAME=zva' >> "$HOME/.profile"
fi

echo "============================================"
echo "Configuration populated successfully!"
echo "============================================"
echo ""
echo "Your configurations have been copied to ~/.config/"
echo "A backup of your old configurations is stored in: $BACKUP_DIR"
echo ""
echo "Please restart Hyprland or log out and log back in for changes to take effect."
echo ""
