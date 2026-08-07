#!/bin/bash

PROJECT_DIR="$HOME/docker/db/"
killingFlag="/tmp/docker_killing"

# El flag lo lee waybar (custom/docker) para mostrar el estado "deteniendo"
trap 'rm -f "$killingFlag"; pkill -RTMIN+9 waybar' EXIT

touch "$killingFlag"
pkill -RTMIN+9 waybar

docker compose --project-directory "$PROJECT_DIR" stop
echo "=> Container stopped"
