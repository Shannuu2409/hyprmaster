#!/bin/bash

wallDIR="/home/shannu24/Downloads/Wallpapers"
scriptsDir="$HOME/.config/hypr/scripts"

# Get focused monitor
focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')

# Fallback if not detected
if [ -z "$focused_monitor" ]; then
    focused_monitor=$(hyprctl monitors | awk '/^Monitor/{print $2; exit}')
fi

# Collect wallpapers
PICS=($(find "$wallDIR" -type f \( \
    -name "*.jpg" -o \
    -name "*.jpeg" -o \
    -name "*.png" -o \
    -name "*.gif" \)))

# Pick random image
RANDOMPICS=${PICS[$RANDOM % ${#PICS[@]}]}

# Transition config
FPS=60
TYPE="random"
DURATION=1
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"

# Ensure daemon is running
swww query || swww-daemon --format xrgb

# Give daemon moment to start
sleep 0.5

# Set wallpaper
swww img -o "$focused_monitor" "$RANDOMPICS" $SWWW_PARAMS

# Wait for cache creation
sleep 0.5

# Update colors and refresh components
${scriptsDir}/WallustSwww.sh
sleep 1
${scriptsDir}/Refresh.sh
sleep 0.2
${scriptsDir}/walogram.sh

