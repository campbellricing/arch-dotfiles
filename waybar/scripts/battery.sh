#!/bin/bash

power_supply="${POWER_SUPPLY_PATH:-/sys/class/power_supply}"
adapter="$power_supply/AC/online"

if [ -r "$adapter" ] && [ "$(cat "$adapter")" = "1" ]; then
  exit 0
fi

icon_for_capacity() {
  capacity="$1"

  if [ "$capacity" -lt 10 ]; then
    echo "󰁺"
  elif [ "$capacity" -lt 20 ]; then
    echo "󰁻"
  elif [ "$capacity" -lt 30 ]; then
    echo "󰁼"
  elif [ "$capacity" -lt 40 ]; then
    echo "󰁽"
  elif [ "$capacity" -lt 50 ]; then
    echo "󰁾"
  elif [ "$capacity" -lt 60 ]; then
    echo "󰁿"
  elif [ "$capacity" -lt 70 ]; then
    echo "󰂀"
  elif [ "$capacity" -lt 80 ]; then
    echo "󰂁"
  elif [ "$capacity" -lt 90 ]; then
    echo "󰂂"
  else
    echo "󰁹"
  fi
}

labels=()

for battery in BAT0 BAT1; do
  capacity_file="$power_supply/$battery/capacity"

  if [ ! -r "$capacity_file" ]; then
    continue
  fi

  capacity="$(cat "$capacity_file")"
  labels+=("${capacity}% $(icon_for_capacity "$capacity")")
done

if [ "${#labels[@]}" -eq 0 ]; then
  exit 0
fi

printf "%s\n" "${labels[*]}"
