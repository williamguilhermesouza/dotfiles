#!/usr/bin/env bash
set -euo pipefail

# Place the layer-shell menu under the pointer that clicked the Waybar module.
menu_width=360
wofi_args=()
while (($#)); do
  if [[ $1 == --popup-width && $# -gt 1 ]]; then
    menu_width=$2
    shift 2
  else
    wofi_args+=("$1")
    shift
  fi
done

cursor_values=()
mapfile -t cursor_values < <(timeout 0.08s hyprctl cursorpos 2>/dev/null | grep -oE -- '-?[0-9]+' | head -n 2 || true)
monitor_info=''
if ((${#cursor_values[@]} == 2)) && command -v jq >/dev/null; then
  cursor_x=${cursor_values[0]}
  cursor_y=${cursor_values[1]}
  monitor_info=$(timeout 0.08s hyprctl -j monitors 2>/dev/null | jq -r --argjson x "$cursor_x" --argjson y "$cursor_y" \
    '.[] | select($x >= .x and $x < (.x + .width) and $y >= .y and $y < (.y + .height)) | [.name,.x,.y,.width] | @tsv' 2>/dev/null | head -n 1 || true)
fi

# Waybar reserves the bar area, so only add a small gap below it.
location_args=(--location top --yoffset 4)
if [[ -n $monitor_info ]]; then
  IFS=$'\t' read -r monitor_name monitor_x _monitor_y monitor_width <<< "$monitor_info"
  max_width=$((monitor_width - 24))
  ((max_width < 220)) && max_width=220
  ((menu_width > max_width)) && menu_width=$max_width
  xoffset=$((cursor_x - monitor_x - menu_width / 2))
  ((xoffset < 12)) && xoffset=12
  ((xoffset > monitor_width - menu_width - 12)) && xoffset=$((monitor_width - menu_width - 12))
  location_args=(--monitor "$monitor_name" --location top_left --xoffset "$xoffset" --yoffset 4)
fi

# Let focus move away from Wofi so close_on_focus_loss can dismiss the menu,
# then restore Hyprland's original layer focus setting when Wofi exits.
restore_layers_hog=0
layers_hog_changed=0
if command -v hyprctl >/dev/null 2>&1; then
  if layers_hog_output=$(timeout 0.12s hyprctl getoption input:layers_hog_keyboard_focus 2>/dev/null); then
    restore_layers_hog=$(sed -n 's/^[[:space:]]*int:[[:space:]]*\([01]\).*$/\1/p' <<< "$layers_hog_output" | head -n 1)
    if [[ $restore_layers_hog == 1 ]] && timeout 0.12s hyprctl keyword input:layers_hog_keyboard_focus 0 >/dev/null 2>&1; then
      layers_hog_changed=1
    fi
  fi
fi
restore_focus_policy() {
  if ((layers_hog_changed)); then
    timeout 0.12s hyprctl keyword input:layers_hog_keyboard_focus "$restore_layers_hog" >/dev/null 2>&1 || true
  fi
}
trap restore_focus_policy EXIT

if wofi --dmenu "${location_args[@]}" --define=content_halign=start \
  --define=close_on_focus_loss=true --width "$menu_width" --height 340 \
  --style "$HOME/.config/waybar/wofi.css" "${wofi_args[@]}"; then
  exit 0
else
  exit $?
fi
