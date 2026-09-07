#!/bin/bash
# Registro de stacks de docker compose + helpers compartidos.
# Lo consumen scripts/docker_{up,down,ls}.sh y waybar/docker-{status,toggle,menu}.sh.
#
# Para agregar un stack: crear ~/dotfiles/docker/<id>/docker-compose.yml,
# enlazarlo con `ln -sfn ~/dotfiles/docker/<id> ~/docker/<id>` y sumar una linea
# a DOCKER_STACKS. Ningun otro script necesita cambios.

DOCKER_STACKS_ROOT="${DOCKER_STACKS_ROOT:-$HOME/docker}"

# id|directorio|etiqueta|icono (Nerd Font)
DOCKER_STACKS=(
    "mysql|$DOCKER_STACKS_ROOT/mysql|MySQL|󰆼"
    "postgres|$DOCKER_STACKS_ROOT/postgres|PostgreSQL|󰘨"
)

# Rellena STACK_ID/STACK_DIR/STACK_LABEL/STACK_ICON para el id pedido.
docker_stack_load() {
    local entry
    for entry in "${DOCKER_STACKS[@]}"; do
        IFS='|' read -r STACK_ID STACK_DIR STACK_LABEL STACK_ICON <<<"$entry"
        [[ $STACK_ID == "$1" ]] && return 0
    done
    STACK_ID="" STACK_DIR="" STACK_LABEL="" STACK_ICON=""
    return 1
}

docker_stack_ids() {
    local entry
    for entry in "${DOCKER_STACKS[@]}"; do
        printf '%s\n' "${entry%%|*}"
    done
}

# Sin argumentos devuelve todos los stacks; con argumentos valida los ids dados.
docker_stack_targets() {
    local id
    if (($# == 0)); then
        docker_stack_ids
        return 0
    fi
    for id in "$@"; do
        if ! docker_stack_load "$id"; then
            printf 'Stack desconocido: %s (validos: %s)\n' \
                "$id" "$(docker_stack_ids | paste -sd, -)" >&2
            return 1
        fi
        printf '%s\n' "$id"
    done
}

# Flags que lee waybar para pintar los estados transitorios.
docker_stack_flag() { printf '/tmp/docker_%s_%s' "$2" "$1"; } # <id> starting|killing

docker_refresh_waybar() { pkill -RTMIN+9 waybar 2>/dev/null; return 0; }

# Ids de contenedores corriendo del stack; falla si el daemon no responde.
docker_stack_running() {
    docker compose --project-directory "$1" ps --status running -q 2>/dev/null
}
