#!/usr/bin/env bash
set -euo pipefail

config="$HOME/.config/waybar/weather.conf"
[[ -r $config ]] && source "$config"
latitude=${LATITUDE:--23.5505}
longitude=${LONGITUDE:--46.6333}
location=${LOCATION:-Weather}
cache="${XDG_CACHE_HOME:-$HOME/.cache}/waybar/weather.json"
if [[ ! -r $cache ]] || ! jq -e '.daily.time and .daily.weather_code' "$cache" >/dev/null 2>&1; then
  "$HOME/.config/waybar/scripts/weather.sh" >/dev/null 2>&1 &
  printf 'Forecast is loading. Open this panel again in a moment.\n' \
    | "$HOME/.config/waybar/scripts/popup-menu.sh" --prompt "$location" --lines 2 >/dev/null || true
  exit 0
fi

jq -r '
  def describe(code):
    if code == 0 then "Clear"
    elif code <= 3 then "Cloudy"
    elif code <= 48 then "Fog"
    elif code <= 57 then "Drizzle"
    elif code <= 67 or (code >= 80 and code <= 82) then "Rain"
    elif code <= 77 or (code >= 85 and code <= 86) then "Snow"
    elif code >= 95 then "Thunderstorm"
    else "Variable" end;
  .daily as $d |
  range(0; $d.time|length) as $i |
  "\($d.time[$i] | strptime("%Y-%m-%d") | strftime("%a, %d %b"))  ·  \($d.temperature_2m_min[$i] | round)° / \($d.temperature_2m_max[$i] | round)°  ·  \(describe($d.weather_code[$i]))"
' "$cache" | "$HOME/.config/waybar/scripts/popup-menu.sh" --prompt "$location · 5-day forecast" --lines 6 >/dev/null || true
