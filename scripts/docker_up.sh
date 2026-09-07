#!/bin/bash
# Levanta uno o varios stacks de docker compose.
#   docker_up.sh            -> todos los stacks
#   docker_up.sh postgres   -> solo ese stack

source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/docker-stacks.sh"

# El status de mapfile es el suyo, no el de la sustitucion: se valida antes
selection=$(docker_stack_targets "$@") || exit 1
[[ -n $selection ]] || exit 1
mapfile -t targets <<<"$selection"

# Los flags los lee waybar (custom/docker) para mostrar el estado "levantando"
flags=()
cleanup() {
    rm -f "${flags[@]}"
    docker_refresh_waybar
}
trap cleanup EXIT

for id in "${targets[@]}"; do
    flags+=("$(docker_stack_flag "$id" starting)")
done
touch "${flags[@]}"
docker_refresh_waybar

status=0
for id in "${targets[@]}"; do
    docker_stack_load "$id"
    echo "=> Levantando $STACK_LABEL ($STACK_DIR)"
    if docker compose --project-directory "$STACK_DIR" up -d; then
        echo "=> $STACK_LABEL running"
    else
        echo "=> Error levantando $STACK_LABEL" >&2
        status=1
    fi
    rm -f "$(docker_stack_flag "$id" starting)"
    docker_refresh_waybar
done

exit "$status"
