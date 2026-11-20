#!/usr/bin/env bash
set -euo pipefail

menu="$HOME/.config/waybar/scripts/popup-menu.sh"
if [[ $(nmcli -t -f WIFI general status 2>/dev/null || true) != enabled ]]; then
  choice=$(printf 'Enable Wi-Fi\nCancel\n' | "$menu" --prompt 'Wi-Fi is off') || exit 0
  [[ $choice == 'Enable Wi-Fi' ]] && nmcli radio wifi on
  exit 0
fi

declare -a choices=('⟳  Rescan' '×  Disconnect' 'Power off Wi-Fi')
declare -A ssid_by_label
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
        prefix='  '
        [[ $in_use == '*' || $in_use == yes ]] && prefix='● '
        label="$prefix$ssid · ${signal}% · ${security:---}"
        choices+=("$label")
        ssid_by_label["$label"]=$ssid
      fi
      in_use= ssid= signal= security=
      ;;
  esac
done < <(nmcli -c no -m multiline -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan yes 2>/dev/null)
choice=$(printf '%s\n' "${choices[@]}" | "$menu" --prompt 'Wi-Fi networks') || exit 0
case "$choice" in
  '⟳  Rescan') exec "$0" ;;
  '×  Disconnect') nmcli device disconnect "$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2 == "wifi" {print $1; exit}')" ;;
  'Power off Wi-Fi') nmcli radio wifi off ;;
  '● '*) exit 0 ;;
  '') exit 0 ;;
  *)
    ssid=${ssid_by_label[$choice]:-}
    [[ -n $ssid ]] || exit 0
    if ! nmcli device wifi connect "$ssid"; then
      password=$(wofi --dmenu --password --location top --yoffset 48 --width 390 --height 90 \
        --style "$HOME/.config/waybar/wofi.css" --prompt "Password for $ssid") || exit 0
      nmcli device wifi connect "$ssid" password "$password"
    fi
    ;;
esac
