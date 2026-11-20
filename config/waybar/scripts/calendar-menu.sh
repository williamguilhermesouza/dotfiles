#!/usr/bin/env bash
set -euo pipefail

today=$(date +%-d)
first=$(date +%Y-%m-01)
month=$(date -d "$first" +%B\ %Y)
offset=$(date -d "$first" +%u)
days=$(date -d "$first +1 month -1 day" +%-d)
printf 'Wk\nMo\nTu\nWe\nTh\nFr\nSa\nSu\n'
for ((day=1; day<=days; day++)); do
  weekday=$(date -d "$first +$((day - 1)) days" +%u)
  if ((day == 1)); then
    week=$(date -d "$first" +%V)
    printf '%s\n' "$week"
    for ((i=1; i<offset; i++)); do printf '·\n'; done
  elif (((offset + day - 1) % 7 == 1)); then
    week=$(date -d "$first +$((day - 1)) days" +%V)
    printf '%s\n' "$week"
  fi
  if ((day == today)); then printf '<b>%d</b>\n' "$day"; else printf '%d\n' "$day"; fi
done | "$HOME/.config/waybar/scripts/popup-menu.sh" --hide-search --allow-markup --columns 8 \
  --lines 8 --height 300 --prompt "$month · calendar" >/dev/null || true
