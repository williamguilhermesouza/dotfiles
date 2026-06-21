#!/usr/bin/env bash

set -u

# Prevent a double-click from opening overlapping dialogs.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/waybar-sound-menu.lock"
flock -n 9 || exit 0

volume_output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || {
  notify-send "Sound" "No default audio output found"
  exit 1
}

volume=$(awk '{ printf "%.0f", $2 * 100 }' <<<"$volume_output")
if [[ $volume_output == *MUTED* ]]; then
  state="muted"
else
  state="active"
fi

choice=$(zenity --scale \
  --title="Sound" \
  --text="Output volume · ${state}" \
  --value="$volume" \
  --min-value=0 \
  --max-value=100 \
  --step=5 \
  --width=360 \
  --extra-button="Mute / unmute" \
  --extra-button="Open mixer" 2>/dev/null) || exit 0

case "$choice" in
  "Mute / unmute")
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    ;;
  "Open mixer")
    xdg-terminal-exec wiremix
    ;;
  ''|*[!0-9]*)
    ;;
  *)
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "${choice}%"
    wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
    ;;
esac
