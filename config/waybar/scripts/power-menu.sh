#!/usr/bin/env bash

set -u

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/waybar-power-menu.lock"
flock -n 9 || exit 0

action=$(zenity --list \
  --title="Power" \
  --text="Choose a system action" \
  --radiolist \
  --column="" \
  --column="Action" \
  --hide-header \
  --print-column=2 \
  --width=340 \
  --height=300 \
  FALSE "Lock" \
  FALSE "Suspend" \
  FALSE "Restart" \
  FALSE "Shut down" 2>/dev/null) || exit 0

case "$action" in
  "Lock")
    loginctl lock-session
    ;;
  "Suspend")
    systemctl suspend
    ;;
  "Restart"|"Shut down")
    zenity --question \
      --title="$action" \
      --text="Are you sure you want to ${action,,}?" \
      --ok-label="$action" \
      --cancel-label="Cancel" 2>/dev/null || exit 0

    if [[ $action == "Restart" ]]; then
      systemctl reboot
    else
      systemctl poweroff
    fi
    ;;
esac
