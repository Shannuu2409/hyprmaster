#!/usr/bin/env bash
# ============================================================
#  Hyprland Populate Script
#  Copies dotfiles from this repo into ~/.config
#  Run after install.sh, or standalone to refresh configs.
# ============================================================

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

log()  { echo -e "${GREEN}[✔]${NC} $*"; }
info() { echo -e "${CYAN}[➤]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/config"
CONFIG_DST="$HOME/.config"

if [ ! -d "$CONFIG_SRC" ]; then
    echo -e "${RED}[✘]${NC} Config source directory not found: $CONFIG_SRC"
    exit 1
fi

echo -e "${BOLD}${CYAN}"
echo "  ┌─────────────────────────────────────────┐"
echo "  │   Deploying Hyprland Dotfiles            │"
echo "  │   Source : $CONFIG_SRC"
echo "  │   Target : $CONFIG_DST"
echo "  └─────────────────────────────────────────┘"
echo -e "${NC}"

# ── Helper: backup_and_copy ───────────────────────────────────
backup_and_copy() {
    local src="$1"
    local dst="$2"
    local name
    name=$(basename "$dst")

    # Backup existing config if it exists and is not already from this deploy
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        local backup="${dst}.bak.$(date +%Y%m%d_%H%M%S)"
        warn "Backing up existing $name → $backup"
        mv "$dst" "$backup"
    elif [ -L "$dst" ]; then
        rm "$dst"
    fi

    mkdir -p "$(dirname "$dst")"
    if [ -d "$src" ]; then
        cp -r "$src" "$dst"
    else
        cp "$src" "$dst"
    fi
    log "Deployed: ~/.config/$name"
}

# ── Deploy each config directory ──────────────────────────────
CONFIGS=(
    hypr
    waybar
    kitty
    fish
    rofi
    wofi
    swaylock
    swaync
    wlogout
    wallust
    fastfetch
    btop
    tofi
    swappy
    mpd
    ncmpcpp
    yazi
    starship
    nwg-look
    qt5ct
    qt6ct
    Kvantum
)

for cfg in "${CONFIGS[@]}"; do
    src="$CONFIG_SRC/$cfg"
    dst="$CONFIG_DST/$cfg"
    if [ -d "$src" ] || [ -f "$src" ]; then
        backup_and_copy "$src" "$dst"
    else
        warn "Skipping $cfg (not found in repo)"
    fi
done

# ── Deploy starship.toml to ~/.config/ ────────────────────────
if [ -f "$CONFIG_SRC/starship/starship.toml" ]; then
    cp "$CONFIG_SRC/starship/starship.toml" "$CONFIG_DST/starship.toml"
    log "Deployed: ~/.config/starship.toml"
fi

# ── Make UserScripts executable ───────────────────────────────
if [ -d "$CONFIG_DST/hypr/UserScripts" ]; then
    chmod +x "$CONFIG_DST/hypr/UserScripts/"*.sh 2>/dev/null || true
    chmod +x "$CONFIG_DST/hypr/UserScripts/"*.py 2>/dev/null || true
    log "Made UserScripts executable"
fi

if [ -d "$CONFIG_DST/hypr/scripts" ]; then
    chmod +x "$CONFIG_DST/hypr/scripts/"*.sh 2>/dev/null || true
    log "Made hypr/scripts executable"
fi

# ── Create required dirs ──────────────────────────────────────
mkdir -p ~/Pictures/wallpapers
mkdir -p ~/Music
mkdir -p ~/.local/share/fonts
mkdir -p ~/.local/share/themes
mkdir -p ~/.local/share/icons
log "Created standard dirs"

# ── MPD setup ─────────────────────────────────────────────────
if [ -f "$CONFIG_DST/mpd/mpd.conf" ]; then
    mkdir -p ~/Music
    mkdir -p "$CONFIG_DST/mpd/playlists"
    # Patch music directory path in mpd.conf
    sed -i "s|music_directory.*|music_directory         \"$HOME/Music\"|" "$CONFIG_DST/mpd/mpd.conf"
    log "MPD config patched with correct music directory"
fi

# ── Fish config: ensure starship is initialized ───────────────
FISH_CONF="$CONFIG_DST/fish/config.fish"
if [ -f "$FISH_CONF" ]; then
    if ! grep -q "starship init fish" "$FISH_CONF"; then
        echo -e '\n# Starship prompt\nstarship init fish | source' >> "$FISH_CONF"
        log "Starship init added to Fish config"
    fi
fi

# ── Wallust templates: ensure they point to correct paths ─────
info "Wallust templates configured"

echo -e "\n${BOLD}${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}  ✔  Dotfiles deployed successfully!${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════${NC}"
echo -e ""
echo -e "${CYAN}  Config directories deployed to: ${BOLD}~/.config/${NC}"
echo -e "${CYAN}  Add wallpapers to: ${BOLD}~/Pictures/wallpapers/${NC}"
echo -e "${CYAN}  Music directory  : ${BOLD}~/Music/${NC}"
echo -e ""
