# hyprmaster

**Shanmukha Kumar Karra** — Hyprland rice for Ubuntu 26.04+ with **saneAspect-style minimal** default, optional liquid glass, and **full matugen** theming (wallpaper → Hypr, Waybar, Rofi, Kitty, SwayNC).

## Features

- **noir-minimal** (default) — flat bar, muted Everforest-like palette
- **liquid-glass-dark** / **liquid-glass-light** — frosted glass bar
- **noir**, **catppuccin-mocha**, **nord**, **tokyo-night**, **everforest**
- One theme apply: wallpaper + matugen + reload (see [docs/THEMES.md](docs/THEMES.md))
- Your keybinds in `UserConfigs/UserKeybinds.conf`

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

Default: **`noir-minimal`**. Full guide: [docs/THEMES.md](docs/THEMES.md).

```bash
~/.config/hypr/UserScripts/skkarra-theme-switch.sh list
~/.config/hypr/UserScripts/skkarra-theme-switch.sh apply noir-minimal
~/.config/hypr/UserScripts/ThemePicker.sh          # Super+Ctrl+T or Super+Ctrl+B
~/.config/hypr/UserScripts/skkarra-theme-switch.sh next   # Super+Alt+D
```

Wallpapers: `~/Pictures/wallpapers`. Each preset can ship `themes/<name>/wallpaper.jpg`.

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

Before push (no Hyprland session):

```bash
~/Downloads/hyprmaster/scripts/preflight-hyprmaster.sh
```

After logging into **Hyprland** at the greeter (not `hyprland` from a GNOME terminal):

```bash
hyprctl configerrors
~/Downloads/hyprmaster/scripts/verify-hyprland.sh
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Black screen / no wallpaper | Log in via Hyprland session; run `~/.config/hypr/UserScripts/wallpaper-bootstrap.sh`; add images to `~/Pictures/wallpapers` |
| populate: not enough disk | Remove `~/.config.backup.*`, clear large downloads |
| waybar missing | `pkill waybar; waybar`; check `~/.config/waybar/config` |
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
