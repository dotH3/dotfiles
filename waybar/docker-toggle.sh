#!/bin/bash
# Levanta/detiene el stack de docker compose al hacer click en el módulo custom/docker

PROJECT_DIR="${WAYBAR_DOCKER_PROJECT_DIR:-$HOME/docker/db}"
SCRIPTS_DIR="$HOME/dotfiles/scripts"

# Si el daemon no responde no hay nada que alternar; el módulo ya muestra el error
running=$(docker compose --project-directory "$PROJECT_DIR" ps --status running -q 2>/dev/null) || exit 1

if [[ -n $running ]]; then
    "$SCRIPTS_DIR/docker_down.sh"
else
    "$SCRIPTS_DIR/docker_up.sh"
fi

# Fuerza a waybar a refrescar el módulo de inmediato (signal 9, ver config)
pkill -RTMIN+9 waybar
