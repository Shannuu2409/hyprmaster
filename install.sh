#!/usr/bin/env bash
# ============================================================
#  Hyprland Ubuntu Install Script
#  Tested on: Ubuntu 24.04 LTS (Noble) / 22.04 LTS (Jammy)
#  Author: shannu24 – auto-generated from personal dotfiles
# ============================================================

set -e

# ── Colors ────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

log()  { echo -e "${GREEN}[✔]${NC} $*"; }
info() { echo -e "${CYAN}[➤]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[✘]${NC} $*"; exit 1; }

# ── Banner ─────────────────────────────────────────────────────
echo -e "${BOLD}${BLUE}"
cat << 'EOF'
  _   _               _                 _
 | | | |_   _ _ __  | | __ _ _ __   __| |
 | |_| | | | | '_ \ | |/ _` | '_ \ / _` |
 |  _  | |_| | |_) || | (_| | | | | (_| |
 |_| |_|\__, | .__/ |_|\__,_|_| |_|\__,_|
        |___/|_|     Ubuntu Install Script
EOF
echo -e "${NC}"

warn "This script will install Hyprland and all related tools on Ubuntu."
warn "Building Hyprland from source may take 10–20 minutes."
read -rp "$(echo -e ${YELLOW}Press ENTER to continue or Ctrl+C to cancel...${NC})"

# ── Detect Ubuntu version ─────────────────────────────────────
UBUNTU_VERSION=$(lsb_release -rs 2>/dev/null || echo "24.04")
UBUNTU_CODENAME=$(lsb_release -cs 2>/dev/null || echo "noble")
info "Detected Ubuntu ${UBUNTU_VERSION} (${UBUNTU_CODENAME})"

# ── 1. System update ──────────────────────────────────────────
info "Updating system packages..."
sudo apt update && sudo apt upgrade -y
log "System updated"

# ── 2. Add PPAs and repositories ─────────────────────────────
info "Adding required repositories..."

# Graphics / Wayland related PPA (for newer Mesa on older Ubuntu)
if [[ "${UBUNTU_VERSION}" == "22.04" ]]; then
    sudo add-apt-repository -y ppa:kisak/kisak-mesa
    sudo apt update
fi

# Nerd Fonts helpers
sudo apt install -y software-properties-common curl wget git unzip zip \
    build-essential cmake ninja-build pkg-config meson \
    libgl1-mesa-dev libgles2-mesa-dev libgbm-dev libegl1-mesa-dev \
    libdrm-dev libxkbcommon-dev libinput-dev libudev-dev \
    libsystemd-dev libseat-dev libliftoff-dev \
    libwayland-dev wayland-protocols libwayland-egl-backend-dev \
    libpipewire-0.3-dev libwlroots-dev 2>/dev/null || true

log "Base build dependencies installed"

# ── 3. Core apt packages ──────────────────────────────────────
info "Installing core dependencies via apt..."
CORE_PKGS=(
    # Wayland / session
    wayland-utils xwayland libxcb-icccm4 libxcb-image0 libxcb-keysyms1
    libxcb-render-util0 libxcb-xinerama0 libxcb-xkb1
    # Fonts
    fonts-noto fonts-noto-color-emoji
    # Audio
    pipewire pipewire-pulse pavucontrol wireplumber
    # Bluetooth
    bluez bluez-tools blueman
    # Network
    network-manager-gnome
    # Polkit
    policykit-1-gnome
    # XDG
    xdg-user-dirs xdg-desktop-portal
    # Qt theming
    qt5ct qt6ct
    # Brightness / media
    brightnessctl playerctl
    # Screenshot / clipboard
    grim slurp wl-clipboard
    # Utilities
    fzf ripgrep jq python3-requests python3-pip
    # Terminal
    kitty
    # File manager
    yazi || true
    # Media
    mpd ncmpcpp mpv
    # System monitor
    btop
    # Fetch
    fastfetch || neofetch
)

sudo apt install -y "${CORE_PKGS[@]}" 2>/dev/null || true
log "Core apt packages installed"

# ── 4. Fish shell ─────────────────────────────────────────────
info "Installing Fish shell..."
sudo apt-add-repository -y ppa:fish-shell/release-3 2>/dev/null || true
sudo apt update 2>/dev/null || true
sudo apt install -y fish
log "Fish shell installed"

# ── 5. Starship prompt ────────────────────────────────────────
info "Installing Starship prompt..."
curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
log "Starship installed"

# ── 6. Hyprland & ecosystem (build from source) ───────────────
info "Installing Hyprland build dependencies..."
sudo apt install -y \
    libgles2-mesa-dev libgbm-dev libegl1-mesa-dev libdrm-dev \
    libxcb-composite0-dev libxcb-ewmh-dev libxcb-icccm4-dev \
    libxcb-image0-dev libxcb-present-dev libxcb-render-util0-dev \
    libxcb-res0-dev libxcb-shape0-dev libxcb-xinput-dev xdotool \
    libglm-dev libtomlplusplus-dev libhyprlang-dev 2>/dev/null || true

# ── hyprutils ─────────────────────────────────────────────────
info "Building hyprutils..."
BUILD_DIR="$HOME/.hypr-build"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
git clone --depth=1 https://github.com/hyprwm/hyprutils.git 2>/dev/null || (cd hyprutils && git pull)
cd hyprutils && cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build && \
    cmake --build ./build --config Release --target all -j$(nproc) && \
    sudo cmake --install ./build && cd "$BUILD_DIR"

# ── aquamarine ────────────────────────────────────────────────
info "Building aquamarine (Hyprland backend)..."
git clone --depth=1 https://github.com/hyprwm/aquamarine.git 2>/dev/null || (cd aquamarine && git pull)
cd aquamarine && cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build && \
    cmake --build ./build --config Release --target all -j$(nproc) && \
    sudo cmake --install ./build && cd "$BUILD_DIR"

# ── hyprlang ──────────────────────────────────────────────────
info "Building hyprlang..."
git clone --depth=1 https://github.com/hyprwm/hyprlang.git 2>/dev/null || (cd hyprlang && git pull)
cd hyprlang && cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build && \
    cmake --build ./build --config Release --target all -j$(nproc) && \
    sudo cmake --install ./build && cd "$BUILD_DIR"

# ── hyprcursor ────────────────────────────────────────────────
info "Building hyprcursor..."
git clone --depth=1 https://github.com/hyprwm/hyprcursor.git 2>/dev/null || (cd hyprcursor && git pull)
cd hyprcursor && cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build && \
    cmake --build ./build --config Release --target all -j$(nproc) && \
    sudo cmake --install ./build && cd "$BUILD_DIR"

# ── hyprwayland-scanner ───────────────────────────────────────
info "Building hyprwayland-scanner..."
git clone --depth=1 https://github.com/hyprwm/hyprwayland-scanner.git 2>/dev/null || (cd hyprwayland-scanner && git pull)
cd hyprwayland-scanner && cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build && \
    cmake --build ./build --config Release --target all -j$(nproc) && \
    sudo cmake --install ./build && cd "$BUILD_DIR"

# ── Hyprland ──────────────────────────────────────────────────
info "Building Hyprland (this takes a while)..."
git clone --depth=1 --recursive https://github.com/hyprwm/Hyprland.git 2>/dev/null || \
    (cd Hyprland && git pull --recurse-submodules)
cd Hyprland && cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build && \
    cmake --build ./build --config Release --target all -j$(nproc) && \
    sudo cmake --install ./build && cd "$BUILD_DIR"
log "Hyprland built and installed"

# ── xdg-desktop-portal-hyprland ───────────────────────────────
info "Building xdg-desktop-portal-hyprland..."
sudo apt install -y libportal-dev 2>/dev/null || true
git clone --depth=1 https://github.com/hyprwm/xdg-desktop-portal-hyprland.git 2>/dev/null || \
    (cd xdg-desktop-portal-hyprland && git pull)
cd xdg-desktop-portal-hyprland && cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build && \
    cmake --build ./build --config Release --target all -j$(nproc) && \
    sudo cmake --install ./build && cd "$BUILD_DIR"

# ── hyprpaper ─────────────────────────────────────────────────
info "Building hyprpaper..."
git clone --depth=1 https://github.com/hyprwm/hyprpaper.git 2>/dev/null || (cd hyprpaper && git pull)
cd hyprpaper && cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build && \
    cmake --build ./build --config Release --target all -j$(nproc) && \
    sudo cmake --install ./build && cd "$BUILD_DIR"

# ── hyprlock ──────────────────────────────────────────────────
info "Building hyprlock..."
sudo apt install -y libpam0g-dev 2>/dev/null || true
git clone --depth=1 https://github.com/hyprwm/hyprlock.git 2>/dev/null || (cd hyprlock && git pull)
cd hyprlock && cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build && \
    cmake --build ./build --config Release --target all -j$(nproc) && \
    sudo cmake --install ./build && cd "$BUILD_DIR"

# ── hypridle ──────────────────────────────────────────────────
info "Building hypridle..."
git clone --depth=1 https://github.com/hyprwm/hypridle.git 2>/dev/null || (cd hypridle && git pull)
cd hypridle && cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build && \
    cmake --build ./build --config Release --target all -j$(nproc) && \
    sudo cmake --install ./build && cd "$BUILD_DIR"

log "All Hyprland ecosystem tools built"

# ── 7. Waybar ─────────────────────────────────────────────────
info "Installing Waybar..."
sudo apt install -y waybar || {
    warn "Waybar not in apt, building from source..."
    sudo apt install -y libgtkmm-3.0-dev libsigc++-2.0-dev libfmt-dev \
        libspdlog-dev libpulse-dev libnl-3-dev libnl-genl-3-dev \
        libdbusmenu-gtk3-dev libmpdclient-dev libjsoncpp-dev libxkbregistry-dev
    git clone --depth=1 https://github.com/Alexays/Waybar.git 2>/dev/null || (cd Waybar && git pull)
    cd Waybar && meson setup build && ninja -C build && sudo ninja -C build install
    cd "$BUILD_DIR"
}
log "Waybar installed"

# ── 8. Rofi-wayland ──────────────────────────────────────────
info "Installing rofi-wayland..."
sudo apt install -y rofi 2>/dev/null || true
# Try to build rofi-wayland if rofi doesn't have wayland support
which rofi-wayland &>/dev/null || {
    sudo apt install -y libwayland-dev libxkbcommon-dev bison flex librsvg2-dev \
        libgdk-pixbuf-2.0-dev libpango1.0-dev libcairo2-dev libxcb-ewmh-dev
    git clone --depth=1 https://github.com/lbonn/rofi.git "$BUILD_DIR/rofi-wayland" 2>/dev/null || \
        (cd "$BUILD_DIR/rofi-wayland" && git pull)
    cd "$BUILD_DIR/rofi-wayland" && autoreconf -i && \
        ./configure --disable-check && make -j$(nproc) && sudo make install
}
log "Rofi installed"

# ── 9. Wofi ───────────────────────────────────────────────────
info "Installing wofi..."
sudo apt install -y wofi
log "Wofi installed"

# ── 10. Swaylock ──────────────────────────────────────────────
info "Installing swaylock..."
sudo apt install -y swaylock || {
    warn "Building swaylock-effects from source..."
    git clone --depth=1 https://github.com/mortie/swaylock-effects.git "$BUILD_DIR/swaylock-effects" 2>/dev/null || \
        (cd "$BUILD_DIR/swaylock-effects" && git pull)
    cd "$BUILD_DIR/swaylock-effects" && meson setup build && ninja -C build && sudo ninja -C build install
}
log "Swaylock installed"

# ── 11. SwayNC ────────────────────────────────────────────────
info "Installing SwayNotificationCenter (swaync)..."
sudo apt install -y swaync 2>/dev/null || {
    warn "Building swaync from source..."
    sudo apt install -y libhandy-1-dev valac
    git clone --depth=1 https://github.com/ErikReider/SwayNotificationCenter.git "$BUILD_DIR/swaync" 2>/dev/null || \
        (cd "$BUILD_DIR/swaync" && git pull)
    cd "$BUILD_DIR/swaync" && meson setup build -Dprefix=/usr --buildtype=release && \
        ninja -C build && sudo ninja -C build install
}
log "SwayNC installed"

# ── 12. Wlogout ───────────────────────────────────────────────
info "Installing wlogout..."
sudo apt install -y wlogout 2>/dev/null || {
    warn "Building wlogout from source..."
    sudo apt install -y libgtk-layer-shell-dev
    git clone --depth=1 https://github.com/ArtsyMacaw/wlogout.git "$BUILD_DIR/wlogout" 2>/dev/null || \
        (cd "$BUILD_DIR/wlogout" && git pull)
    cd "$BUILD_DIR/wlogout" && meson setup build -Dprefix=/usr && ninja -C build && sudo ninja -C build install
}
log "Wlogout installed"

# ── 13. Wallust ───────────────────────────────────────────────
info "Installing wallust..."
which wallust &>/dev/null || {
    # Install via cargo (Rust)
    if ! which cargo &>/dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    cargo install wallust
}
log "Wallust installed"

# ── 14. Tofi ─────────────────────────────────────────────────
info "Installing tofi..."
sudo apt install -y tofi 2>/dev/null || {
    sudo apt install -y libpng-dev libharfbuzz-dev
    git clone --depth=1 https://github.com/philj56/tofi.git "$BUILD_DIR/tofi" 2>/dev/null || \
        (cd "$BUILD_DIR/tofi" && git pull)
    cd "$BUILD_DIR/tofi" && meson setup build && ninja -C build && sudo ninja -C build install
}
log "Tofi installed"

# ── 15. Cliphist ──────────────────────────────────────────────
info "Installing cliphist..."
which cliphist &>/dev/null || {
    if ! which go &>/dev/null; then
        sudo apt install -y golang-go
    fi
    go install go.senan.xyz/cliphist@latest
    sudo cp "$HOME/go/bin/cliphist" /usr/local/bin/
}
log "Cliphist installed"

# ── 16. Pyprland ─────────────────────────────────────────────
info "Installing pyprland..."
pip3 install pyprland --break-system-packages 2>/dev/null || pip3 install pyprland
log "Pyprland installed"

# ── 17. Noto fonts + JetBrains Mono Nerd + Font Awesome ──────
info "Installing fonts..."
sudo apt install -y fonts-noto fonts-noto-color-emoji fonts-font-awesome

# JetBrains Mono Nerd Font
NERD_FONT_VERSION="v3.4.0"
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VERSION}/JetBrainsMono.zip"
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerd
cd /tmp && wget -q "$NERD_FONT_URL" -O JetBrainsMono.zip && \
    unzip -o JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMonoNerd && \
    rm JetBrainsMono.zip
fc-cache -fv &>/dev/null
log "Fonts installed"

# ── 18. nwg-look (GTK theme manager) ─────────────────────────
info "Installing nwg-look..."
sudo apt install -y nwg-look 2>/dev/null || {
    if ! which go &>/dev/null; then sudo apt install -y golang-go; fi
    go install github.com/nwg-piotr/nwg-look@latest
    sudo cp "$HOME/go/bin/nwg-look" /usr/local/bin/
}
log "nwg-look installed"

# ── 19. Fastfetch ─────────────────────────────────────────────
info "Installing fastfetch..."
sudo apt install -y fastfetch 2>/dev/null || {
    # Fallback: download latest deb from GitHub
    FF_URL=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest \
        | grep browser_download_url | grep "linux-amd64.deb" | head -1 | cut -d'"' -f4)
    [ -n "$FF_URL" ] && {
        wget -q "$FF_URL" -O /tmp/fastfetch.deb && sudo dpkg -i /tmp/fastfetch.deb
    } || warn "Could not auto-install fastfetch; install manually."
}
log "Fastfetch installed"

# ── 20. Swappy ────────────────────────────────────────────────
info "Installing swappy..."
sudo apt install -y swappy || {
    sudo apt install -y libsixel-dev
    git clone --depth=1 https://github.com/jtheoof/swappy.git "$BUILD_DIR/swappy" 2>/dev/null || \
        (cd "$BUILD_DIR/swappy" && git pull)
    cd "$BUILD_DIR/swappy" && meson setup build && ninja -C build && sudo ninja -C build install
}
log "Swappy installed"

# ── 21. Kvantum ───────────────────────────────────────────────
info "Installing Kvantum Qt theme engine..."
sudo apt install -y qt5-style-kvantum qt5-style-kvantum-themes \
    qt6-style-kvantum 2>/dev/null || {
    sudo add-apt-repository -y ppa:papirus/papirus
    sudo apt update
    sudo apt install -y qt5-style-kvantum qt5-style-kvantum-themes
}
log "Kvantum installed"

# ── 22. Catppuccin Kvantum theme ─────────────────────────────
info "Installing Catppuccin Kvantum theme..."
CATP_KV_URL="https://github.com/catppuccin/Kvantum/releases/latest/download/Catppuccin-Kvantum.tar.gz"
cd /tmp && wget -q "$CATP_KV_URL" -O Catppuccin-Kvantum.tar.gz 2>/dev/null && {
    tar -xzf Catppuccin-Kvantum.tar.gz
    mkdir -p ~/.local/share/Kvantum
    cp -r Catppuccin*/ ~/.local/share/Kvantum/ 2>/dev/null || true
    rm -f Catppuccin-Kvantum.tar.gz
} || warn "Could not download Catppuccin Kvantum theme; skipping."
log "Catppuccin Kvantum done"

# ── 23. Catppuccin GTK theme ──────────────────────────────────
info "Installing Catppuccin GTK theme..."
CATP_GTK_URL="https://github.com/catppuccin/gtk/releases/latest/download/catppuccin-mocha-mauve-standard+default-0.7.2.zip"
mkdir -p ~/.themes
cd /tmp && wget -q "$CATP_GTK_URL" -O catppuccin-gtk.zip 2>/dev/null && {
    unzip -o catppuccin-gtk.zip -d ~/.themes/ && rm catppuccin-gtk.zip
} || warn "Could not download Catppuccin GTK theme; skipping."
log "Catppuccin GTK done"

# ── 24. Populate configs ──────────────────────────────────────
info "Populating configuration files..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/populate.sh" ]; then
    bash "$SCRIPT_DIR/populate.sh"
else
    warn "populate.sh not found, skipping config deployment."
fi

# ── 25. Set Fish as default shell ────────────────────────────
info "Setting Fish as default shell..."
FISH_PATH=$(which fish)
if ! grep -q "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells
fi
chsh -s "$FISH_PATH" "$USER"
log "Fish set as default shell"

# ── 26. Enable services ───────────────────────────────────────
info "Enabling system services..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
sudo systemctl enable bluetooth 2>/dev/null || true
sudo systemctl enable NetworkManager 2>/dev/null || true
log "Services enabled"

# ── Done ──────────────────────────────────────────────────────
echo -e "\n${BOLD}${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}  ✔  Installation Complete!${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════${NC}"
echo -e ""
echo -e "${CYAN}  Next steps:${NC}"
echo -e "  1. Log out and select ${BOLD}Hyprland${NC} at the login screen"
echo -e "     (or run: ${BOLD}exec Hyprland${NC} from a TTY)"
echo -e "  2. If something is broken, check: ${BOLD}~/.hypr-build/${NC}"
echo -e "  3. Wallpapers are not included — add them to: ${BOLD}~/Pictures/wallpapers/${NC}"
echo -e ""
echo -e "${YELLOW}  Build artifacts kept in: $BUILD_DIR${NC}"
echo -e "${YELLOW}  Remove them later with: rm -rf $BUILD_DIR${NC}"
echo -e ""
