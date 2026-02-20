# Hyprland Rice 🌸

A fully themed Hyprland desktop rice by **shannu24**.

## What's included

| Component | Tool |
|---|---|
| Window Manager | Hyprland |
| Status Bar | Waybar |
| Widgets | EWW |
| Terminal | Kitty |
| Shell | Fish |
| App Launcher | Rofi / Wofi / Tofi |
| Notifications | SwayNC |
| Lockscreen | Swaylock |
| Logout Menu | Wlogout |
| Colorscheme Gen | Wallust |
| GTK Theme | Custom (gtk-3.0 / gtk-4.0) |
| Qt Theme | Kvantum (qt5ct / qt6ct) |
| Fetch | Fastfetch |
| System Monitor | Btop |
| File Manager | Yazi |
| Music Player | MPD + ncmpcpp |
| Screenshot | Swappy + Grim |
| Prompt | Starship |

## Requirements

- Arch Linux (or Arch-based distro)
- `yay` or `paru` AUR helper (installer will auto-install yay if missing)
- A display manager or TTY to launch Hyprland

## Installation

```bash
git clone https://github.com/shannu24/Hyprland-master
cd Hyprland-master
chmod +x install.sh
./install.sh
```

### Options

```
./install.sh --skip-packages    # Only install configs (skip pacman/AUR installs)
./install.sh --skip-configs     # Only install packages (skip config copying)
./install.sh --help             # Show help
```

## Directory Structure

```
Hyprland-master/
├── install.sh          ← Main installer
├── README.md           ← This file
├── wallpapers/         ← Wallpapers (add yours here)
└── config/
    ├── hypr/           ← Hyprland config (UserConfigs + UserScripts)
    ├── waybar/         ← Status bar
    ├── eww/            ← Widgets
    ├── fish/           ← Shell config
    ├── kitty/          ← Terminal
    ├── rofi/           ← App launcher
    ├── wofi/           ← App launcher (alt)
    ├── tofi/           ← App launcher (alt)
    ├── wallust/        ← Colorscheme generator
    ├── swaylock/       ← Lockscreen
    ├── swaync/         ← Notifications
    ├── wlogout/        ← Session menu
    ├── gtk-2.0/        ← GTK2 theme
    ├── gtk-3.0/        ← GTK3 theme
    ├── gtk-4.0/        ← GTK4 theme
    ├── qt5ct/          ← Qt5 appearance
    ├── qt6ct/          ← Qt6 appearance
    ├── Kvantum/        ← Qt theme engine
    ├── fastfetch/      ← System info fetch
    ├── btop/           ← System monitor
    ├── yazi/           ← File manager
    ├── mpd/            ← Music Player Daemon
    ├── ncmpcpp/        ← MPD frontend
    ├── swappy/         ← Screenshot editor
    ├── matugen/        ← Material color gen
    ├── nwg-look/       ← GTK theme picker
    └── starship.toml   ← Shell prompt
```

## Notes

- Your old configs are automatically backed up to `~/.config/rice-backup-<timestamp>` before installation.
- After install, log out and choose **Hyprland** in your display manager, or run `Hyprland` from a TTY.
- Wallpapers go in `~/Pictures/wallpapers/`.
