#!/usr/bin/env bash
set -euo pipefail

menu="$HOME/.config/waybar/scripts/popup-menu.sh"
if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then current='Turn Bluetooth off'; else current='Turn Bluetooth on'; fi
if [[ ${1:-} == --toggle ]]; then
  if [[ $current == 'Turn Bluetooth off' ]]; then bluetoothctl power off; else bluetoothctl power on; fi
  exit $?
fi

devices=$(bluetoothctl devices 2>/dev/null | sed 's/^Device //')
connected_devices=$(bluetoothctl devices Connected 2>/dev/null | awk '{print $2}')
choices=("$current" 'Pair a device')
declare -A address_by_label
declare -A connected_address
while IFS= read -r address; do
  [[ -n $address ]] && connected_address["$address"]=1
done <<< "$connected_devices"
while IFS= read -r device; do
  [[ -n $device ]] || continue
  address=${device%% *}
  name=${device#* }
  if [[ ${connected_address[$address]:-} == 1 ]]; then marker='●'; else marker='○'; fi
  label="$marker  $name"
  choices+=("$label")
  address_by_label["$label"]=$address
done <<< "$devices"
choice=$(printf '%s\n' "${choices[@]}" | "$menu" --prompt 'Bluetooth') || exit 0
case "$choice" in
  'Turn Bluetooth on') bluetoothctl power on ;;
  'Turn Bluetooth off') bluetoothctl power off ;;
  'Pair a device')
    bluetoothctl scan on >/dev/null 2>&1 || true
    sleep 5
    bluetoothctl scan off >/dev/null 2>&1 || true
    devices=$(bluetoothctl devices | sed 's/^Device //')
    [[ -n $devices ]] || exit 0
    device=$(printf '%s\n' "$devices" | "$menu" --prompt 'Select a device') || exit 0
    address=${device%% *}
    bluetoothctl pair "$address" || true
    bluetoothctl trust "$address" || true
    bluetoothctl connect "$address"
    ;;
  ●\ *|○\ *)
    address=${address_by_label[$choice]:-}
    [[ -n $address ]] || exit 0
    if bluetoothctl info "$address" 2>/dev/null | grep -q 'Connected: yes'; then
      bluetoothctl disconnect "$address"
    else
      bluetoothctl connect "$address"
    fi
    ;;
esac
