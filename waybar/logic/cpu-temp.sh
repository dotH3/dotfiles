#!/bin/bash
maxTemp=85
normalIcon="󰍛"
hotIcon=""

temperature=$(sensors | grep 'Core 0' | awk '{print $3}' | tr -d '+' | cut -d'.' -f1)
usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')

icon="$normalIcon"
class=""
if [ "$temperature" -gt "$maxTemp" ] 2>/dev/null; then
  icon="$hotIcon"
  class="hot"
fi

text="$icon ${temperature}°C"
alt="CPU: %${usage}"

echo "{\"text\": \"$text\", \"alt\": \"$alt\", \"class\": \"$class\"}"