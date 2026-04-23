#!/bin/bash
maxTemp=85
normalIcon="󰍛"
hotIcon=""
fan_usage_limit=5300

temperature=$(sensors | grep 'Core 0' | awk '{print $3}' | tr -d '+' | cut -d'.' -f1)
usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
fan_usage_rpm=$(sensors | grep 'fan' | awk '{print $2}' | tr -d 'RPM')
# fan_usage_percent=$(echo "scale=2; $fan_usage_rpm / $fan_usage_limit * 100" | bc)

icon="$normalIcon"
class=""
if [ "$temperature" -gt "$maxTemp" ] 2>/dev/null; then
  icon="$hotIcon"
  class="hot"
fi

# text="$icon ${temperature}°C"
text="TMP:${temperature}°C"
# text="$text | Fan: ${fan_usage_percent}%"
alt="CPU: %${usage}"

echo "{\"text\": \"$text\", \"alt\": \"$alt\", \"class\": \"$class\"}"