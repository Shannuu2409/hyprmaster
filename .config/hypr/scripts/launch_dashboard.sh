#!/bin/bash

# --- LEFT COLUMN (80/20 Split) ---

# 1. HTOP (Top Left - 80% Height)
hyprctl dispatch exec [float; size 48% 78%; move 1% 1%] "kitty --class startup_htop -e htop"

# 2. CMATRIX (Bottom Left - 20% Height)
# Starts at Y=80% (approx 1% gap + 78% htop + 1% gap)
hyprctl dispatch exec [float; size 48% 18%; move 1% 81%] "kitty --class startup_cmatrix -e cmatrix"


# --- RIGHT COLUMN (70/30 Split) ---

# 3. NORMAL TERMINAL (Bottom Right - 70% Height)
# We place this at the bottom. 
hyprctl dispatch exec [float; size 48% 68%; move 51% 31%] "kitty --class startup_terminal"

# 4 & 5. SHARED SPACE (Top Right - 30% Height Shared)
# Splitting the top-right 30% horizontally between Clock and Cava
hyprctl dispatch exec [float; size 23.5% 28%; move 51% 1%] "kitty --class startup_clock -e tty-clock -C 4 -c"
hyprctl dispatch exec [float; size 23.5% 28%; move 75.5% 1%] "kitty --class startup_cava -e cava"

