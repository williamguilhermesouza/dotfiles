#!/usr/bin/env bash
set -euo pipefail

menu="$HOME/.config/waybar/scripts/popup-menu.sh"
if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then current='Turn Bluetooth off'; else current='Turn Bluetooth on'; fi
choice=$(printf '%s\nPair a device\n' "$current" | "$menu" --prompt 'Bluetooth') || exit 0
case "$choice" in
  'Turn Bluetooth on') bluetoothctl power on ;;
  'Turn Bluetooth off') bluetoothctl power off ;;
  'Pair a device')
    devices=$(bluetoothctl devices | sed 's/^Device //')
    [[ -n $devices ]] || exit 0
    device=$(printf '%s\n' "$devices" | "$menu" --prompt 'Select a device') || exit 0
    address=${device%% *}
    bluetoothctl connect "$address"
    ;;
esac
