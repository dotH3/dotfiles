#!/bin/bash

PROJECT_DIR="$HOME/docker/sql/"
killingFlag="/tmp/docker_killing"

touch "$killingFlag"
pkill -RTMIN+9 waybar
notify-send "Docker" "Nuking container and volume..." -i docker

docker compose --project-directory "$PROJECT_DIR" down -v
echo "=> Container and volume dropped"

rm -f "$killingFlag"
pkill -RTMIN+9 waybar
