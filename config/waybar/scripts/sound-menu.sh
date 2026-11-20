#!/usr/bin/env bash
set -euo pipefail

volume_output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || exit 0
volume=$(awk '{ printf "%.0f", $2 * 100 }' <<<"$volume_output")
if [[ $volume_output == *MUTED* ]]; then state=Muted; else state=On; fi

choice=$(printf 'Volume up (+5%%)\nVolume down (-5%%)\nMute / unmute\n' \
  | "$HOME/.config/waybar/scripts/popup-menu.sh" --prompt "Audio · ${volume}% · ${state}") || exit 0
case "$choice" in
  'Volume up (+5%)') wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ ;;
  'Volume down (-5%)') wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
  'Mute / unmute') wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
esac
