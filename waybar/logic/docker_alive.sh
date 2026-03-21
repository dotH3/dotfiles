#!/bin/bash
dockerUp="docker_up.sh"
dockerLs="docker_ls.sh"

dockerIcon="  "

isUp=$($dockerLs | grep "running" | wc -l)

text="$dockerIcon"
class="off"
alt="$isUp containers running"

if [ "$isUp" -gt 0 ] 2>/dev/null; then
  text="$dockerIcon"
  class="on"
fi

if [ -f /tmp/docker_killing ]; then
  class="killing"
  alt="Killing containers..."
fi

if [ -f /tmp/docker_importing ]; then
  class="importing"
  alt="Importing SQL..."
fi

echo "{\"text\": \"$text\", \"class\": \"$class\", \"alt\": \"$alt\"}"


