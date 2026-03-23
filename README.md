# 🌿 Hyprland Dotfiles

> My personal Hyprland rice — configs for every tool, one-click install on Ubuntu.

## Screenshots

> Add your screenshots here.

---

## 📦 What's Included

| Tool | Purpose |
|---|---|
| **hyprland** | Wayland compositor |
| **hyprpaper** | Wallpaper daemon |
| **hypridle** | Idle management |
| **hyprlock** | Lock screen |
| **hyprgrass** | Touch gesture plugin |
| **xdg-desktop-portal-hyprland** | XDG portal |
| **waybar** | Status bar (24 layouts!) |
| **kitty** | GPU-accelerated terminal |
| **fish** | Shell |
| **rofi-wayland** | App launcher / menus |
| **wofi** | Launcher |
| **tofi** | Minimal launcher |
| **swaylock** | Lock screen (fallback) |
| **swaync** | Notification center |
| **wlogout** | Logout menu |
| **wallust** | Wallpaper color theming |
| **fastfetch** | System info fetch |
| **btop** | System monitor |
| **mpd + ncmpcpp** | Music player daemon |
| **yazi** | TUI file manager |
| **starship** | Shell prompt |
| **nwg-look** | GTK appearance manager |
| **qt5ct / qt6ct** | Qt theming |
| **kvantum** | Qt style engine (Catppuccin) |
| **grim + slurp** | Screenshots |
| **swappy** | Screenshot annotation |
| **cliphist** | Clipboard manager |
| **pyprland** | Hyprland plugin system |
| **brightnessctl** | Brightness control |
| **playerctl** | Media key control |
| **pavucontrol** | Audio control |

---

## 🚀 One-Click Install (Ubuntu 22.04 / 24.04)

> [!IMPORTANT]
> Run this on **Ubuntu 22.04 LTS** or **Ubuntu 24.04 LTS** on bare metal or a VM.  
> Building Hyprland from source takes **10–20 minutes** depending on your CPU.

```bash
git clone https://github.com/YOUR_USERNAME/Hyprland-master.git
cd Hyprland-master
chmod +x install.sh populate.sh
./install.sh
```

After it finishes:
1. **Log out** and select **Hyprland** at the display manager
2. Or from a TTY: `exec Hyprland`

---

## ⚙️ Just Deploy Configs (no install)

If Hyprland is already installed and you only want to copy the dotfiles:

```bash
./populate.sh
```

This will back up any existing configs and deploy everything from `config/` into `~/.config/`.

---

## 📁 Config Directory Structure

```
config/
├── hypr/
│   ├── hyprland.conf          # Main config (sources UserConfigs)
│   ├── hypridle.conf
│   ├── hyprgrass.conf
│   ├── pyprland.toml
│   ├── UserConfigs/
│   │   ├── UserKeybinds.conf  # All keybindings
│   │   ├── UserSettings.conf  # Look & feel, gaps, animations
│   │   ├── Monitors.conf      # Monitor layout
│   │   ├── WindowRules.conf   # Window rules
│   │   ├── WorkspaceRules.conf
│   │   ├── Startup_Apps.conf  # Autostart
│   │   └── ENVariables.conf   # Environment variables
│   ├── UserScripts/           # WallpaperSelect, RofiBeats, etc.
│   └── wallust/               # Wallust color templates
├── waybar/
│   ├── config                 # Active bar config
│   ├── modules               # Module definitions
│   ├── style.css
│   └── configs/              # 24 preconfigured bar layouts
├── kitty/                    # kitty.conf + color themes
├── fish/                     # config.fish + functions
├── rofi/                     # config.rasi + themes
├── wofi/                     # config + style.css
├── tofi/                     # Minimal launcher configs
├── swaylock/                 # Lock screen config
├── swaync/                   # Notification center
├── wlogout/                  # Logout menu layout + style
├── wallust/                  # Color generation config + templates
├── fastfetch/                # System fetch config
├── btop/                     # btop.conf + themes
├── mpd/                      # mpd.conf (music player daemon)
├── ncmpcpp/                  # config + bindings
├── yazi/                     # yazi.toml (file manager)
├── starship/                 # starship.toml (prompt)
├── nwg-look/                 # GTK theme config
├── qt5ct/                    # Qt5 theme config
├── qt6ct/                    # Qt6 theme config
└── Kvantum/                  # Kvantum theme (Catppuccin Mocha)
```

---

## 🎨 Theme

- **Color scheme**: Catppuccin Mocha (via wallust auto-theming)
- **GTK theme**: Catppuccin GTK
- **Qt theme**: Catppuccin Kvantum
- **Icons**: (add your icon theme here)
- **Font**: JetBrainsMono Nerd Font + Noto Emoji

---

## ⌨️ Key Keybindings

> Full bindings in `config/hypr/UserConfigs/UserKeybinds.conf`

| Keys | Action |
|---|---|
| `SUPER + ENTER` | Open Kitty terminal |
| `SUPER + SPACE` | Open Rofi launcher |
| `SUPER + Q` | Kill active window |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + V` | Toggle floating |
| `SUPER + 1–0` | Switch workspaces |
| `SUPER + SHIFT + 1–0` | Move window to workspace |
| `SUPER + L` | Lock screen (hyprlock) |
| `SUPER + SHIFT + E` | Wlogout |
| `SUPER + SHIFT + W` | Wallpaper selector |
| `Print` | Screenshot (grim + slurp) |
| `SUPER + Print` | Annotate screenshot (swappy) |

---

## 🛠️ Troubleshooting

**Hyprland won't start:**
- Check `~/.hypr-build/` for build logs
- Run `Hyprland` from a TTY and check output

**Waybar missing modules:**
- Ensure `waybar` version supports your module
- Check `journalctl --user -u waybar`

**No audio:**
- `systemctl --user status pipewire`
- Run `pavucontrol` to configure

**Wallust not theming:**
- Run `wallust run <path-to-wallpaper>`
- Templates must be in `~/.config/wallust/templates/`

---

## 📝 Notes

- Wallpapers are **not included** — add them to `~/Pictures/wallpapers/`
- Music is read from `~/Music/` by MPD
- Build artifacts are in `~/.hypr-build/` — remove when done: `rm -rf ~/.hypr-build`

---

*Generated from personal dotfiles on Arch Linux, adapted for Ubuntu install.*
