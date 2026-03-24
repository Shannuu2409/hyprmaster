#!/bin/bash

# ===========================================
# Hyprland Ubuntu Installation Script
# ===========================================

set -e

echo "============================================"
echo "Hyprland Ubuntu Installation Script"
echo "============================================"

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Update system
echo "Updating system packages..."
apt update && apt upgrade -y

# ===========================================
# Install core Hyprland dependencies
# ===========================================
echo "Installing core dependencies..."

# Wayland compositor
apt install -y hyprland

# ===========================================
# Install core utilities
# ===========================================
echo "Installing core utilities..."

# Terminal
apt install -y kitty

# Shell
apt install -y fish

# Status bar
apt install -y waybar

# Application launchers
apt install -y rofi wofi tofi

# Screen locker
apt install -y swaylock

# Notification daemon
apt install -y swaync

# Logout menu
apt install -y wlogout

# Wallpaper theming
apt install -y wallust

# System info
apt install -y fastfetch

# System monitor
apt install -y btop

# Widgets
apt install -y eww

# Screenshot tool
apt install -y swappy

# Music player
apt install -y mpd ncmpcpp

# File manager
apt install -y yazi

# ===========================================
# Install additional dependencies
# ===========================================
echo "Installing additional dependencies..."

# Hyprland plugins and tools
apt install -y hyprpicker grim slurp polkit-kde-agent libnotify-bin

# Fonts and icons
apt install -y fonts-font-awesome fonts-jetbrains-mono fonts-nerd-fonts-complete
apt install -y papirus-icon-theme

# GTK/Qt themes
apt install -y gtk2-apps gtk2-engines gtk-3-examples
apt install -y qt5-style-plugins qt6-styleplugins

# Desktop appearance
apt install -y nwg-look lxappearance

# ===========================================
# Install from source/PPA (if needed)
# ===========================================

# Install Kvantum (if not available in apt)
if ! command -y kvantummanager &> /dev/null; then
    echo "Installing Kvantum from source..."
    apt install -y cmake g++ qtbase5-dev qt5-style-plugins libqt5svg5-dev
    cd /tmp
    git clone https://github.com/tsujan/Kvantum.git
    cd Kvantum && mkdir build && cd build
    cmake .. && make && make install
    ldconfig
fi

# ===========================================
# Install optional packages
# ===========================================
echo "Installing optional packages..."

# Starship prompt
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh
fi

# Additional tools
apt install -y bc jq unzip curl wget git

# ===========================================
# Post-installation setup
# ===========================================

echo "Post-installation setup..."

# Create necessary directories
mkdir -p ~/.config
mkdir -p ~/.local/share/fonts
mkdir -p ~/.local/bin

# Download and install Nerd Fonts (if not present)
if [ ! -d "~/.local/share/fonts/NerdFonts" ]; then
    echo "Installing Nerd Fonts..."
    cd /tmp
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
    unzip -o JetBrainsMono.zip -d ~/.local/share/fonts
    rm JetBrainsMono.zip
    fc-cache -fv
fi

# ===========================================
# Configuration
# ===========================================

echo "Configuration setup..."

# Set environment variables for Qt
echo 'QT_QPA_PLATFORMTHEME=qt5ct' >> ~/.profile
echo 'QT_QPA_PLATFORM=wayland' >> ~/.profile

# Set environment variables for GTK
echo 'GTK_THEME=Catppuccin-Mocha' >> ~/.profile

# ===========================================
# Run populate script
# ===========================================

if [ -f "./populate.sh" ]; then
    echo "Running populate script..."
    chmod +x ./populate.sh
    ./populate.sh
else
    echo "Warning: populate.sh not found. Please run it manually."
fi

echo "============================================"
echo "Installation complete!"
echo "============================================"
echo ""
echo "Please reboot your system or restart your display manager."
echo "After reboot, your Hyprland configuration will be ready."
echo ""
echo "Key shortcuts:"
echo "  Super + Return - Open terminal (kitty)"
echo "  Super + D - Open application launcher (rofi)"
echo "  Super + L - Lock screen"
echo "  Super + C - Close window"
echo "  Super + 1-9 - Switch workspaces"
echo ""
