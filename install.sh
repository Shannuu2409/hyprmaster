#!/usr/bin/env bash
# ============================================================
#  Hyprland Rice Installer — shannu24
#  Generated: 2026-02-20
# ============================================================

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log()    { echo -e "${CYAN}${BOLD}[rice]${RESET} $*"; }
ok()     { echo -e "${GREEN}${BOLD}[ ok ]${RESET} $*"; }
warn()   { echo -e "${YELLOW}${BOLD}[warn]${RESET} $*"; }
err()    { echo -e "${RED}${BOLD}[err ]${RESET} $*"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/rice-backup-$(date +%Y%m%d_%H%M%S)"

# ── Helpers ──────────────────────────────────────────────────
backup_and_copy() {
    local src="$1"    # relative to SCRIPT_DIR/config/
    local dest="$2"   # absolute destination path

    local full_src="$SCRIPT_DIR/config/$src"

    if [ ! -e "$full_src" ]; then
        warn "Skipping '$src' — not found in package."
        return
    fi

    # Backup existing config
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$dest" "$BACKUP_DIR/" 2>/dev/null || true
        log "Backed up existing $(basename "$dest") → $BACKUP_DIR/"
    fi

    # Copy new config
    mkdir -p "$(dirname "$dest")"
    cp -r "$full_src" "$dest"
    ok "Installed: $src → $dest"
}

# ── Package list ─────────────────────────────────────────────
PACMAN_PKGS=(
    hyprland
    hyprpaper
    hypridle
    hyprlock
    xdg-desktop-portal-hyprland
    waybar
    kitty
    fish
    rofi-wayland
    wofi
    swaylock
    swaync
    wlogout
    wallust
    fastfetch
    btop
    eww
    grim
    slurp
    wl-clipboard
    cliphist
    brightnessctl
    playerctl
    pavucontrol
    network-manager-applet
    bluez
    bluez-utils
    blueman
    polkit-gnome
    xdg-user-dirs
    nwg-look
    qt5ct
    qt6ct
    kvantum
    kvantum-theme-catppuccin-git
    noto-fonts
    noto-fonts-emoji
    ttf-jetbrains-mono-nerd
    ttf-font-awesome
    swappy
    mpd
    ncmpcpp
    yazi
    starship
    pyprland
    tofi
)

AUR_PKGS=(
    hyprgrass
    wallust
    tofi
    wlogout
)

# ── Installation steps ────────────────────────────────────────
install_packages() {
    log "Checking for AUR helper…"
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &>/dev/null; then
        AUR_HELPER="paru"
    else
        warn "No AUR helper found. Installing yay…"
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
        AUR_HELPER="yay"
    fi

    log "Installing pacman packages…"
    sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}" || warn "Some packages may have failed."

    log "Installing AUR packages…"
    "$AUR_HELPER" -S --needed --noconfirm "${AUR_PKGS[@]}" || warn "Some AUR packages may have failed."
}

install_configs() {
    log "Installing rice configurations…"

    # ── Hyprland ──────────────────────────────────────────
    backup_and_copy "hypr"         "$HOME/.config/hypr"

    # ── Waybar ────────────────────────────────────────────
    backup_and_copy "waybar"       "$HOME/.config/waybar"

    # ── EWW ───────────────────────────────────────────────
    backup_and_copy "eww"          "$HOME/.config/eww"

    # ── Fish shell ────────────────────────────────────────
    backup_and_copy "fish"         "$HOME/.config/fish"

    # ── Kitty terminal ────────────────────────────────────
    backup_and_copy "kitty"        "$HOME/.config/kitty"

    # ── Rofi ──────────────────────────────────────────────
    backup_and_copy "rofi"         "$HOME/.config/rofi"

    # ── Wofi ──────────────────────────────────────────────
    backup_and_copy "wofi"         "$HOME/.config/wofi"

    # ── Tofi ──────────────────────────────────────────────
    backup_and_copy "tofi"         "$HOME/.config/tofi"

    # ── Wallust ───────────────────────────────────────────
    backup_and_copy "wallust"      "$HOME/.config/wallust"

    # ── Swaylock ──────────────────────────────────────────
    backup_and_copy "swaylock"     "$HOME/.config/swaylock"

    # ── SwayNC ────────────────────────────────────────────
    backup_and_copy "swaync"       "$HOME/.config/swaync"

    # ── Wlogout ───────────────────────────────────────────
    backup_and_copy "wlogout"      "$HOME/.config/wlogout"

    # ── GTK 2 / 3 / 4 ────────────────────────────────────
    backup_and_copy "gtk-2.0"      "$HOME/.config/gtk-2.0"
    backup_and_copy "gtk-3.0"      "$HOME/.config/gtk-3.0"
    backup_and_copy "gtk-4.0"      "$HOME/.config/gtk-4.0"

    # ── Qt ────────────────────────────────────────────────
    backup_and_copy "qt5ct"        "$HOME/.config/qt5ct"
    backup_and_copy "qt6ct"        "$HOME/.config/qt6ct"
    backup_and_copy "Kvantum"      "$HOME/.config/Kvantum"

    # ── Fastfetch ─────────────────────────────────────────
    backup_and_copy "fastfetch"    "$HOME/.config/fastfetch"

    # ── Btop ──────────────────────────────────────────────
    backup_and_copy "btop"         "$HOME/.config/btop"

    # ── Starship prompt ───────────────────────────────────
    [ -f "$SCRIPT_DIR/config/starship.toml" ] && \
        cp "$SCRIPT_DIR/config/starship.toml" "$HOME/.config/starship.toml" && \
        ok "Installed: starship.toml"

    # ── Yazi ──────────────────────────────────────────────
    backup_and_copy "yazi"         "$HOME/.config/yazi"

    # ── MPD / ncmpcpp ─────────────────────────────────────
    backup_and_copy "mpd"          "$HOME/.config/mpd"
    backup_and_copy "ncmpcpp"      "$HOME/.config/ncmpcpp"

    # ── Swappy ────────────────────────────────────────────
    backup_and_copy "swappy"       "$HOME/.config/swappy"

    # ── Matugen (optional colorscheme tool) ───────────────
    backup_and_copy "matugen"      "$HOME/.config/matugen"

    # ── NWG-look ──────────────────────────────────────────
    backup_and_copy "nwg-look"     "$HOME/.config/nwg-look"

    # ── Wallpapers ────────────────────────────────────────
    if [ -d "$SCRIPT_DIR/wallpapers" ]; then
        mkdir -p "$HOME/Pictures/wallpapers"
        cp -r "$SCRIPT_DIR/wallpapers/." "$HOME/Pictures/wallpapers/"
        ok "Installed: wallpapers → ~/Pictures/wallpapers/"
    fi
}

setup_fish_default_shell() {
    if ! grep -q "$(command -v fish)" /etc/shells 2>/dev/null; then
        command -v fish | sudo tee -a /etc/shells
    fi
    if [ "$SHELL" != "$(command -v fish)" ]; then
        log "Setting fish as default shell…"
        chsh -s "$(command -v fish)"
        ok "Default shell set to fish (takes effect on next login)."
    fi
}

setup_mpd() {
    mkdir -p "$HOME/.config/mpd" "$HOME/Music"
    log "Enabling MPD user service…"
    systemctl --user enable mpd.service --now 2>/dev/null || warn "Could not enable MPD service."
}

fix_permissions() {
    log "Fixing script permissions in ~/.config/hypr…"
    find "$HOME/.config/hypr" -name "*.sh" -o -name "*.py" | xargs chmod +x 2>/dev/null || true
    ok "Permissions fixed."
}

print_done() {
    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}${BOLD}║   Hyprland rice installed successfully!  ║${RESET}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  ${CYAN}• Log out and select Hyprland in your display manager, or${RESET}"
    echo -e "  ${CYAN}• Run: ${BOLD}Hyprland${RESET} ${CYAN}from a TTY.${RESET}"
    echo ""
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "  ${YELLOW}Old configs backed up to: $BACKUP_DIR${RESET}"
    fi
    echo ""
}

# ── Main ─────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}${BOLD}  ╔══════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}${BOLD}  ║      Hyprland Rice Installer v1.0        ║${RESET}"
echo -e "${CYAN}${BOLD}  ╚══════════════════════════════════════════╝${RESET}"
echo ""

# Parse args
SKIP_PKGS=false
SKIP_CONFIGS=false
for arg in "$@"; do
    case "$arg" in
        --skip-packages)  SKIP_PKGS=true    ;;
        --skip-configs)   SKIP_CONFIGS=true ;;
        --help|-h)
            echo "Usage: ./install.sh [--skip-packages] [--skip-configs]"
            echo ""
            echo "  --skip-packages   Skip system package installation"
            echo "  --skip-configs    Skip copying config files"
            exit 0
            ;;
    esac
done

# Arch Linux check
if ! command -v pacman &>/dev/null; then
    err "This installer is designed for Arch Linux (pacman not found)."
fi

$SKIP_PKGS    || install_packages
$SKIP_CONFIGS || install_configs
setup_fish_default_shell
setup_mpd
fix_permissions
print_done
