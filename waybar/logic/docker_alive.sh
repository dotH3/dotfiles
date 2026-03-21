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


echo "{\"text\": \"$text\", \"class\": \"$class\", \"alt\": \"$alt\"}"