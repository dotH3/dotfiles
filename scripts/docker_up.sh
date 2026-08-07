#!/bin/bash

PROJECT_DIR="$HOME/docker/db/"
startingFlag="/tmp/docker_starting"

# El flag lo lee waybar (custom/docker) para mostrar el estado "levantando"
trap 'rm -f "$startingFlag"; pkill -RTMIN+9 waybar' EXIT

touch "$startingFlag"
pkill -RTMIN+9 waybar

docker compose --project-directory "$PROJECT_DIR" up -d
echo "=> Docker Running"
