#!/bin/bash
dockerUp="docker_up.sh"
dockerDown="docker_down.sh"
dockerLs="docker_ls.sh"

isUp=$($dockerLs | grep "running" | wc -l)

if [ "$isUp" -gt 0 ] 2>/dev/null; then
  notify-send "Docker" "Apagando contenedores..."
  $dockerDown &
else
  notify-send "Docker" "Levantando contenedores..."
  $dockerUp &
fi