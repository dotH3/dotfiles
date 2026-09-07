#!/bin/bash
# Lista los contenedores de cada stack registrado.
#   docker_ls.sh            -> todos los stacks
#   docker_ls.sh postgres   -> solo ese stack

source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/docker-stacks.sh"

# El status de mapfile es el suyo, no el de la sustitucion: se valida antes
selection=$(docker_stack_targets "$@") || exit 1
[[ -n $selection ]] || exit 1
mapfile -t targets <<<"$selection"

for id in "${targets[@]}"; do
    docker_stack_load "$id"
    printf '\n%s  %s  (%s)\n' "$STACK_ICON" "$STACK_LABEL" "$STACK_DIR"
    if [[ -d $STACK_DIR ]]; then
        docker compose --project-directory "$STACK_DIR" ps --all
    else
        echo "  No existe el directorio del proyecto"
    fi
done
