#!/usr/bin/env bash
set -euo pipefail

menu="$HOME/.config/waybar/scripts/popup-menu.sh"
action=$(printf 'Lock\nSuspend\nRestart\nShut down\n' | "$menu" --prompt 'Power') || exit 0

case "$action" in
  Lock) loginctl lock-session ;;
  Suspend) systemctl suspend ;;
  Restart|"Shut down")
    confirm=$(printf 'Cancel\nConfirm %s\n' "$action" | "$menu" --prompt "$action?") || exit 0
    [[ $confirm == "Confirm $action" ]] || exit 0
    if [[ $action == Restart ]]; then systemctl reboot; else systemctl poweroff; fi
    ;;
esac
