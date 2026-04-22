#!/bin/bash
normalIcon=" " 
hotIcon="󰀦"

usage=$(free | grep Mem | awk '{printf "%.0f", ($3/$2)*100}')

icon="$normalIcon"
class=""
if [ "$usage" -gt 75 ]; then
  icon="$hotIcon"
  class="hot"
fi

total=$(free -h | grep Mem | awk '{print $2}')
used=$(free -h | grep Mem | awk '{print $3}')

# text="$icon ${usage}%"
text="RAM:${usage}% |"
alt="RAM: ${used}/${total}"

echo "{\"text\": \"$text\", \"alt\": \"$alt\", \"class\": \"$class\"}"
