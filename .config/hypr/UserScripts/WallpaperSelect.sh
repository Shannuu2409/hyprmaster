#!/bin/bash
# Shanmukha Kumar Karra — wallpaper picker

wallDIR="/home/shannu24/Downloads/Wallpapers"
APPLY="${HOME}/.config/hypr/UserScripts/wallpaper-apply.sh"
focused_monitor=$(hyprctl monitors 2>/dev/null | awk '/^Monitor/{name=$2} /focused: yes/{print name}')

FPS=60
SWWW_PARAMS="--transition-fps $FPS --transition-type any --transition-duration 2"

mapfile -d '' PICS < <(find "${wallDIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -print0 2>/dev/null)

RANDOM_PIC="${PICS[$((RANDOM % ${#PICS[@]}))]:-}"
RANDOM_PIC_NAME=". random"
rofi_command="rofi -i -show -dmenu -config ~/.config/rofi/config-wallpaper.rasi"

menu() {
  IFS=$'\n' sorted_options=($(sort <<<"${PICS[*]}"))
  [ -n "$RANDOM_PIC" ] && printf "%s\x00icon\x1f%s\n" "$RANDOM_PIC_NAME" "$RANDOM_PIC"
  for pic_path in "${sorted_options[@]}"; do
    pic_name=$(basename "$pic_path")
    if [[ ! "$pic_name" =~ \.gif$ ]]; then
      printf "%s\x00icon\x1f%s\n" "$(echo "$pic_name" | cut -d. -f1)" "$pic_path"
    else
      printf "%s\n" "$pic_name"
    fi
  done
}

swww query 2>/dev/null || swww-daemon --format xrgb

choice=$(menu | $rofi_command)
choice=$(echo "$choice" | xargs)
[ -z "$choice" ] && exit 0

if [[ "$choice" == "$(echo "$RANDOM_PIC_NAME" | xargs)" ]]; then
  swww img -o "$focused_monitor" "$RANDOM_PIC" $SWWW_PARAMS 2>/dev/null || swww img "$RANDOM_PIC" $SWWW_PARAMS
  "$APPLY" "$RANDOM_PIC"
  exit 0
fi

for i in "${!PICS[@]}"; do
  filename=$(basename "${PICS[$i]}")
  if [[ "$filename" == "$choice"* ]]; then
    swww img -o "$focused_monitor" "${PICS[$i]}" $SWWW_PARAMS 2>/dev/null || swww img "${PICS[$i]}" $SWWW_PARAMS
    "$APPLY" "${PICS[$i]}"
    exit 0
  fi
done

echo "Image not found." >&2
exit 1
