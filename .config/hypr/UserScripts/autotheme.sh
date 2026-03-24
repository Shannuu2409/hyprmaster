#!/bin/bash

wallpaper=$(swww query | awk -F 'image: ' '{print $2}')

wallust run "$wallpaper"

hyprctl reload

killall waybar 

waybar &
