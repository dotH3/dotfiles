#!/bin/bash
# Alterna un stack de docker compose (o todos si no se pasa ninguno).
#   docker-toggle.sh            -> todos: levanta si no hay nada corriendo, si no detiene
#   docker-toggle.sh postgres   -> sólo ese stack

source "$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")/scripts/docker-stacks.sh"

SCRIPTS_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")/scripts"

# El status de mapfile es el suyo, no el de la sustitucion: se valida antes
selection=$(docker_stack_targets "$@") || exit 1
[[ -n $selection ]] || exit 1
mapfile -t targets <<<"$selection"

running=0
reachable=0
for id in "${targets[@]}"; do
    docker_stack_load "$id"
    if ids=$(docker_stack_running "$STACK_DIR"); then
        reachable=1
        [[ -n $ids ]] && running=1
    fi
done

# Si el daemon no responde no hay nada que alternar; el módulo ya muestra el error
((reachable)) || exit 1

if ((running)); then
    "$SCRIPTS_DIR/docker_down.sh" "${targets[@]}"
else
    "$SCRIPTS_DIR/docker_up.sh" "${targets[@]}"
fi

# Fuerza a waybar a refrescar el módulo de inmediato (signal 9, ver config)
docker_refresh_waybar
