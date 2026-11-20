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
add_network() {
  [[ -n $ssid ]] || return 0
  marker='○'
  [[ $in_use == '*' || $in_use == yes ]] && marker='●'
  label=$(printf '%s %-24.24s %3s%% %-8.8s' "$marker" "$ssid" "${signal:-0}" "${security:---}")
  choices+=("$label")
  ssid_by_label["$label"]=$ssid
}
while IFS= read -r line; do
  field=${line%%:*}
  value=${line#*:}
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  case "$field" in
    IN-USE)
      add_network
      in_use=$value
      ssid= signal= security=
      ;;
    SSID) ssid=$value ;;
    SIGNAL) signal=$value ;;
    SECURITY) security=$value ;;
  esac
done < <(nmcli -c no -m multiline -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan no 2>/dev/null)
add_network
choice=$(printf '%s\n' "${choices[@]}" | "$menu" --prompt 'Wi-Fi networks' \
  --style "$HOME/.config/waybar/wofi-wifi.css") || exit 0
case "$choice" in
  '⟳  Rescan')
    nmcli device wifi rescan >/dev/null 2>&1 || true
    sleep 2
    exec "$0"
    ;;
  '×  Disconnect') nmcli device disconnect "$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2 == "wifi" {print $1; exit}')" ;;
  'Power off Wi-Fi') nmcli radio wifi off ;;
  '● '*) exit 0 ;;
  '') exit 0 ;;
  *)
    ssid=${ssid_by_label[$choice]:-}
    [[ -n $ssid ]] || exit 0
    if ! nmcli device wifi connect "$ssid"; then
      password=$("$menu" --password --height 100 --prompt "Password for $ssid" \
        --style "$HOME/.config/waybar/wofi-wifi.css") || exit 0
      nmcli device wifi connect "$ssid" password "$password"
    fi
    ;;
esac
