#!/bin/bash
# Shanmukha Kumar Karra — hyprmaster install (Ubuntu 26.04+)

set -euo pipefail

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
DEFAULT_WALL="${REPO_DIR}/.config/hypr/wallpapers/default.jpg"
USER_WALL_DIR="${TARGET_HOME}/Downloads/Wallpapers"

if [ -z "$TARGET_HOME" ] || [ "$TARGET_USER" = "root" ]; then
    echo "Run with sudo from your user account (e.g. sudo ./install.sh), not as root login."
    exit 1
fi

warn() { echo "WARN: $*"; }
info() { echo "INFO: $*"; }

run_as_user() {
    su - "$TARGET_USER" -c "$1"
}

apt_try() {
    if apt install -y "$@"; then
        return 0
    fi
    warn "Could not install: $*"
    return 1
}

ensure_user_path_line() {
    local file="$1"
    local line="$2"
    [ -f "$file" ] || return 0
    if ! grep -qF "$line" "$file" 2>/dev/null; then
        echo "$line" >>"$file"
    fi
}

echo "Installing packages for user: $TARGET_USER"
apt update

apt install -y \
    hyprland hypridle hyprpicker hyprpolkitagent \
    kitty fish waybar rofi wofi \
    swaylock sway-notification-center wlogout \
    grim slurp swappy jq \
    cliphist wl-clipboard \
    pipewire wireplumber playerctl brightnessctl \
    libnotify-bin \
    fastfetch btop mpd ncmpcpp \
    bc unzip curl wget git \
    fonts-font-awesome fonts-jetbrains-mono fonts-inter \
    papirus-icon-theme bibata-cursor-theme \
    qt6ct qt5ct nwg-look \
    network-manager-gnome \
    cmatrix cava htop \
    python3 python3-pip \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

apt_try hyprland-backgrounds || true

if ! command -v yazi >/dev/null 2>&1; then
    info "yazi is not in Ubuntu apt; skipping (optional: snap install yazi --classic)"
fi

if ! command -v swww >/dev/null 2>&1; then
    info "swww not found; installing build deps and building via cargo (may take several minutes)..."
    apt install -y \
        cargo rustc \
        liblz4-dev libdav1d-dev libvulkan-dev \
        libpipewire-0.3-dev libgbm-dev \
        2>/dev/null || apt install -y cargo rustc libssl-dev pkg-config
    if command -v cargo >/dev/null 2>&1; then
        run_as_user 'cargo install swww --locked 2>/dev/null || cargo install swww' || \
            warn "swww cargo install failed; install manually: https://github.com/LGFae/swww"
    else
        warn "cargo not available; install swww manually for animated wallpapers"
    fi
else
    info "swww already installed: $(command -v swww)"
fi

if ! run_as_user 'command -v matugen' >/dev/null 2>&1; then
    apt_try cargo rustc || true
    if command -v cargo >/dev/null 2>&1; then
        run_as_user 'cargo install matugen 2>/dev/null || true'
    fi
fi

if run_as_user 'command -v matugen' >/dev/null 2>&1; then
    info "matugen: $(run_as_user 'command -v matugen')"
else
    warn "matugen not in PATH for $TARGET_USER; add ~/.cargo/bin to shell PATH after cargo install"
fi

ensure_user_path_line "${TARGET_HOME}/.zshrc" 'export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"'
ensure_user_path_line "${TARGET_HOME}/.bashrc" 'export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"'
ensure_user_path_line "${TARGET_HOME}/.profile" 'export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"'

if ! command -v kvantummanager >/dev/null 2>&1; then
    apt_try qt5-style-kvantum || apt_try kvantum || true
fi

if ! run_as_user 'command -v starship' >/dev/null 2>&1; then
    run_as_user "mkdir -p '${TARGET_HOME}/.local/bin' && curl -sS https://starship.rs/install.sh | sh -s -- -y -b '${TARGET_HOME}/.local/bin'" || \
        warn "starship install failed"
fi

apt_try tty-clock || true

mkdir -p "$USER_WALL_DIR"
if [ -f "$DEFAULT_WALL" ]; then
    cp -n "$DEFAULT_WALL" "${USER_WALL_DIR}/hyprmaster-default.jpg" 2>/dev/null || true
    info "Wallpapers dir: $USER_WALL_DIR"
fi

echo "Deploying dotfiles to $TARGET_HOME..."
run_as_user "cd '$REPO_DIR' && chmod +x populate.sh scripts/*.sh 2>/dev/null; HYPRMASTER_SKIP_BACKUP=1 ./populate.sh"

if [ -x "${REPO_DIR}/scripts/preflight-hyprmaster.sh" ]; then
    run_as_user "cd '$REPO_DIR' && ./scripts/preflight-hyprmaster.sh" || warn "preflight failed (check repo)"
fi

echo "============================================"
echo "Installation complete for $TARGET_USER"
echo "Log out of GNOME and select Hyprland (not: hyprland inside Kitty)."
echo "In Hyprland session run:"
echo "  hyprctl configerrors"
echo "  $REPO_DIR/scripts/verify-hyprland.sh"
echo "============================================"
