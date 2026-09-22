# hyprmaster themes

Default: **noir-minimal** (saneAspect-style flat bar, Everforest-adjacent palette).

## Keybinds

| Keys | Action |
|------|--------|
| Super+Alt+D | Next theme in cycle |
| Super+Ctrl+T / Super+Ctrl+B | Rofi theme picker |
| Super+Alt+W | Wallpaper picker (matugen from image) |

## Presets

| Theme | Style | Waybar layout |
|-------|--------|---------------|
| noir-minimal | Flat, low blur | sane |
| liquid-glass-dark / light | Frosted glass | minimal |
| noir | Monochrome | sane |
| catppuccin-mocha, nord, tokyo-night, everforest | Static palette + matugen | sane |

Each folder under `.config/hypr/themes/<name>/`:

- `meta.env` — `BASE_COLOR`, `WALLPAPER`, `WAYBAR_CONFIG`, optional `GTK_THEME`
- `hypr-colors.conf` — fallback Hypr palette
- `wallpaper.jpg` — shown when you apply the theme
- `palette.md` — human-readable swatches
- `decoration.conf`, `waybar.css` — fallbacks if matugen is missing

## Flow

1. Resolve theme wallpaper → `swww img`
2. `matugen image` (or `matugen color hex`) → hypr, waybar, rofi, kitty, swaync, wlogout
3. Copy `decoration.conf` → `generated/theme-decoration.conf`
4. `hyprctl reload` + restart waybar/swaync + kitty colors

## Add a theme

```bash
mkdir -p ~/.config/hypr/themes/my-theme
# Add meta.env, hypr-colors.conf, wallpaper.jpg, decoration.conf, waybar.css, palette.md
~/.config/hypr/UserScripts/skkarra-theme-switch.sh apply my-theme
```

Wallpapers for browsing: `~/Pictures/wallpapers` (optional `~/Pictures/wallpapers/<theme>/`).
