#!/bin/bash
# Shanmukha Kumar Karra — hyprmaster install (Ubuntu 26.04+)

set -e

echo "============================================"
echo "hyprmaster — Ubuntu Hyprland install"
echo "============================================"

if [ "$EUID" -ne 0 ]; then
    echo "Run: sudo ./install.sh"
    exit 1
fi

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$TARGET_HOME" ] || [ "$TARGET_USER" = "root" ]; then
    echo "Run with sudo from your user account (e.g. sudo ./install.sh), not as root login."
    exit 1
fi

echo "Installing packages for user: $TARGET_USER"
apt update
apt install -y \
    hyprland hypridle hyprpicker \
    kitty fish waybar rofi wofi \
    swaylock swaync wlogout \
    grim slurp swappy jq \
    swww cliphist wl-clipboard \
    pipewire wireplumber playerctl brightnessctl \
    polkit-kde-agent libnotify-bin \
    fastfetch btop yazi mpd ncmpcpp \
    jq bc unzip curl wget git \
    fonts-font-awesome fonts-jetbrains-mono fonts-inter \
    papirus-icon-theme bibata-cursor-theme \
    qt6ct qt5ct nwg-look \
    network-manager-gnome \
    cmatrix cava tty-clock htop \
    python3 python3-pip

# matugen: cargo or pip if available
if ! command -v matugen >/dev/null 2>&1; then
    apt install -y cargo rustc 2>/dev/null || true
    if command -v cargo >/dev/null 2>&1; then
        su - "$TARGET_USER" -c 'cargo install matugen 2>/dev/null || true'
    fi
fi

if ! command -v kvantummanager >/dev/null 2>&1; then
    apt install -y qt5-style-kvantum 2>/dev/null || apt install -y kvantum 2>/dev/null || true
fi

if ! command -v starship >/dev/null 2>&1; then
    su - "$TARGET_USER" -c 'curl -sS https://starship.rs/install.sh | sh -s -- -y' || true
fi

echo "Deploying dotfiles to $TARGET_HOME..."
su - "$TARGET_USER" -c "cd '$REPO_DIR' && chmod +x populate.sh scripts/verify-hyprland.sh 2>/dev/null; ./populate.sh"

echo "============================================"
echo "Installation complete for $TARGET_USER"
echo "Log out of GNOME and select Hyprland, then run:"
echo "  $REPO_DIR/scripts/verify-hyprland.sh"
echo "============================================"
