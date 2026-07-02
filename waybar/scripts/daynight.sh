#!/bin/bash

hour=$(date +%H)

if [ "$hour" -ge 5 ] && [ "$hour" -lt 10 ]; then
  echo "󰼰 " # moon
elif [ "$hour" -ge 10 ] && [ "$hour" -lt 16 ]; then
  echo "󰖙 " # sunrise
elif [ "$hour" -ge 16 ] && [ "$hour" -lt 18 ]; then
  echo "󰖚 " # sun
else
  echo "󰖔 " # sunset
fi
