#!/usr/bin/env bash

set -u

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/waybar-wifi-menu.lock"
flock -n 9 || exit 0

if [[ $(nmcli -t -f WIFI general status 2>/dev/null) != "enabled" ]]; then
  zenity --question \
    --title="Wi-Fi" \
    --text="Wi-Fi is disabled. Enable it?" \
    --ok-label="Enable" \
    --cancel-label="Cancel" 2>/dev/null || exit 0
  nmcli radio wifi on || exit 1
  sleep 1
fi

declare -a rows
declare -A security_by_ssid

rows+=(FALSE "⟳  Rescan" "" "")
rows+=(FALSE "×  Disconnect" "" "")
rows+=(FALSE "Power off Wi-Fi" "" "")

in_use= ssid= signal= security=
while IFS= read -r line; do
  field=${line%%:*}
  value=${line#*:}
  case "$field" in
    IN-USE) in_use=$value ;;
    SSID) ssid=$value ;;
    SIGNAL) signal=$value ;;
    SECURITY)
      security=$value
      if [[ -n $ssid ]]; then
        security_by_ssid["$ssid"]=$security
        if [[ $in_use == "yes" || $in_use == "*" ]]; then
          selected=TRUE
          label="●  $ssid"
        else
          selected=FALSE
          label="$ssid"
        fi
        [[ $security == "--" || -z $security ]] && lock="Open" || lock="Secured"
        rows+=("$selected" "$label" "${signal}%" "$lock")
      fi
      in_use= ssid= signal= security=
      ;;
  esac
done < <(nmcli -c no -m multiline -f IN-USE,SSID,SIGNAL,SECURITY \
  device wifi list --rescan yes 2>/dev/null)

choice=$(zenity --list \
  --title="Wi-Fi" \
  --text="Select a network" \
  --radiolist \
  --column="" \
  --column="Network" \
  --column="Signal" \
  --column="Security" \
  --print-column=2 \
  --width=520 \
  --height=420 \
  "${rows[@]}" 2>/dev/null) || exit 0

case "$choice" in
  "⟳  Rescan")
    exec "$0"
    ;;
  "×  Disconnect")
    device=$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2 == "wifi" { print $1; exit }')
    [[ -n $device ]] && nmcli device disconnect "$device"
    ;;
  "Power off Wi-Fi")
    nmcli radio wifi off
    ;;
  "●  "*)
    notify-send "Wi-Fi" "Already connected to ${choice#●  }"
    ;;
  *)
    ssid=$choice
    if nmcli device wifi connect "$ssid" >/dev/null 2>&1; then
      notify-send "Wi-Fi" "Connected to $ssid"
      exit 0
    fi

    security=${security_by_ssid["$ssid"]:-}
    if [[ $security == "--" || -z $security ]]; then
      notify-send -u critical "Wi-Fi" "Could not connect to $ssid"
      exit 1
    fi

    password=$(zenity --password \
      --title="Password for $ssid" 2>/dev/null) || exit 0
    if nmcli device wifi connect "$ssid" password "$password" >/dev/null 2>&1; then
      notify-send "Wi-Fi" "Connected to $ssid"
    else
      notify-send -u critical "Wi-Fi" "Connection failed for $ssid"
      exit 1
    fi
    ;;
esac
