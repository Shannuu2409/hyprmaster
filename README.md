# hyprmaster

**Shanmukha Kumar Karra** — Hyprland rice for Ubuntu 26.04+ with macOS-style **liquid glass** (light/dark), noir presets, matugen wallpapers, and a minimal floating waybar.

## Features

- **liquid-glass-dark** / **liquid-glass-light** — frosted panels, heavy blur, pill waybar
- **noir**, **catppuccin-mocha**, **nord**, **tokyo-night**, **everforest**
- Unified wallpaper + colors via `wallpaper-apply.sh` / matugen
- Your keybinds in `UserConfigs/UserKeybinds.conf` (unchanged layout)

## Requirements

- Ubuntu 26.04 (or similar) with Hyprland session at login
- **≥ 500 MB** free on `$HOME` for `populate.sh`
- Packages: see [`install.sh`](install.sh) (Ubuntu names: `sway-notification-center` for swaync, `hyprpolkitagent`, cargo-built `swww` if needed)

## Quick start

```bash
cd ~/Downloads/hyprmaster
chmod +x populate.sh install.sh scripts/verify-hyprland.sh

# If disk was full from an old backup:
rm -rf ~/.config.backup.*   # only if you do not need that backup

HYPRMASTER_SKIP_BACKUP=1 ./populate.sh
# optional system packages:
sudo ./install.sh
```

Log out of GNOME → choose **Hyprland**.

## Themes

| Preset | Description |
|--------|-------------|
| `liquid-glass-dark` | Default — dark frosted glass, mac-like bar |
| `liquid-glass-light` | Light frosted glass |
| `noir` | Monochrome black |
| `catppuccin-mocha` | Catppuccin dark |
| `nord` | Nord |
| `tokyo-night` | Tokyo Night |
| `everforest` | Everforest |

```bash
~/.config/hypr/UserScripts/skkarra-theme-switch.sh list
~/.config/hypr/UserScripts/skkarra-theme-switch.sh apply liquid-glass-dark
~/.config/hypr/UserScripts/skkarra-theme-switch.sh apply liquid-glass-light
~/.config/hypr/UserScripts/skkarra-theme-switch.sh next   # Super+Alt+D / Super+Ctrl+B
```

Cycle order: dark glass → light glass → noir → catppuccin → nord → tokyo-night → everforest.

## GTK / fonts (optional, mac-adjacent)

After install, use **nwg-look** for GTK theme (e.g. Orchis, WhiteSur). Install script pulls **Inter** and **Bibata** cursor when available.

## Keybindings (cheat sheet)

| Keys | Action |
|------|--------|
| Super+Return | Kitty |
| Super+Space | Rofi |
| Super+Alt+D | Next theme |
| Super+Ctrl+B | Next theme |
| Super+Alt+W | Wallpaper picker |
| Super+Shift+W | Wallpaper effects |
| Ctrl+Alt+L | Lock |

Full map: [`.config/hypr/UserConfigs/UserKeybinds.conf`](.config/hypr/UserConfigs/UserKeybinds.conf)

## Verify zero errors

```bash
hyprctl configerrors
journalctl --user -u hyprland -b --no-pager
journalctl --user -u hyprland -b -p err..alert --no-pager
~/Downloads/hyprmaster/scripts/verify-hyprland.sh
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| populate: not enough disk | Remove `~/.config.backup.*`, clear large downloads |
| waybar missing | `waybar` in PATH; check `~/.config/waybar/config` |
| matugen missing | `cargo install matugen` or re-run `sudo ./install.sh` |
| Theme not applied | `skkarra-theme-switch.sh apply liquid-glass-dark` |

## Layout

```
.config/
  hypr/          hyprland.conf, UserConfigs/, themes/, generated/
  matugen/       templates + config.toml
  waybar/        config.minimal → config
```

## License

GPL-3.0 — see [LICENSE](LICENSE) and [NOTICE](NOTICE). Configs by **Shanmukha Kumar Karra**.
