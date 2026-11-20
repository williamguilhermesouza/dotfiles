#!/usr/bin/env bash
set -euo pipefail

battery=$(upower -e 2>/dev/null | grep -m1 '/battery_' || true)
[[ -n $battery ]] || exit 0
info=$(upower -i "$battery")
state=$(awk -F: '/^[[:space:]]*state:/ {gsub(/^[[:space:]]+/, "", $2); print $2; exit}' <<<"$info")
percentage=$(awk -F: '/^[[:space:]]*percentage:/ {gsub(/^[[:space:]]+/, "", $2); print $2; exit}' <<<"$info")
time=$(awk -F: '/^[[:space:]]*time to (empty|full):/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' <<<"$info")
case "$state" in
  charging) time_label='Time to full' ;;
  discharging) time_label='Time to empty' ;;
  *) time_label='Estimated time' ;;
esac
printf 'Battery: %s · %s\n%s: %s\n' "${percentage:-unknown}" "${state:-unknown}" "$time_label" "${time:-unknown}" \
  | "$HOME/.config/waybar/scripts/popup-menu.sh" --prompt 'Battery' >/dev/null || true
