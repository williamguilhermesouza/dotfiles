#!/usr/bin/env bash
set -euo pipefail

config="$HOME/.config/waybar/weather.conf"
[[ -r $config ]] && source "$config"
latitude=${LATITUDE:--23.5505}
longitude=${LONGITUDE:--46.6333}
location=${LOCATION:-Weather}

if ! command -v curl >/dev/null || ! command -v jq >/dev/null; then
  printf '{"text":"","tooltip":"Install curl and jq to enable weather"}\n'
  exit 0
fi

url="https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=5"
if ! response=$(curl -fsS --connect-timeout 3 --max-time 7 "$url" 2>/dev/null); then
  printf '{"text":"","tooltip":"%s · weather unavailable"}\n' "$location"
  exit 0
fi

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
mkdir -p "$cache_dir"
cache_tmp="$cache_dir/weather.json.tmp.$$"
printf '%s\n' "$response" > "$cache_tmp"
mv "$cache_tmp" "$cache_dir/weather.json"

read -r temperature code <<<"$(jq -r '[.current.temperature_2m, .current.weather_code] | @tsv' <<<"$response")"
[[ $temperature != null && $code != null ]] || {
  printf '{"text":"","tooltip":"%s · weather unavailable"}\n' "$location"
  exit 0
}

case "$code" in
  0) icon=''; description='Clear' ;;
  1|2) icon=''; description='Partly cloudy' ;;
  3) icon=''; description='Overcast' ;;
  45|48) icon=''; description='Fog' ;;
  51|53|55|56|57) icon=''; description='Drizzle' ;;
  61|63|65|66|67|80|81|82) icon=''; description='Rain' ;;
  71|73|75|77|85|86) icon=''; description='Snow' ;;
  95|96|99) icon=''; description='Thunderstorm' ;;
  *) icon=''; description='Current conditions' ;;
esac

jq -cn --arg text "$icon ${temperature%.*}°" --arg tooltip "$location · $description · ${temperature}°C" \
  '{text:$text,tooltip:$tooltip}'
