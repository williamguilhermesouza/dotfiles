#!/usr/bin/env bash
set -euo pipefail

# Wofi opens as a Wayland layer surface below the top bar.
exec wofi --dmenu --location top --yoffset 48 --width 390 --height 300 \
  --style "$HOME/.config/waybar/wofi.css" "$@"
