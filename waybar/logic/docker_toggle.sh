#!/bin/bash
exec >> /tmp/waybar-docker-click.log 2>&1
set -x

DIR="$(cd "$(dirname "$0")" && pwd)"
dockerUp="$HOME/dotfiles/scripts/docker_up.sh"
dockerDown="$HOME/dotfiles/scripts/docker_down.sh"
dockerLs="$HOME/dotfiles/scripts/docker_ls.sh"

isUp="$("$dockerLs" | grep "running" | wc -l)"

if [ "$isUp" -gt 0 ]; then
  # notify-send "Docker" "Apagando contenedores..."
  "$dockerDown"
else
  # notify-send "Docker" "Levantando contenedores..."
  "$dockerUp"
fi
