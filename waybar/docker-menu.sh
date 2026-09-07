#!/bin/bash
# Menú fuzzel del módulo custom/docker: elige qué stack levantar o detener.
# Las entradas se arman con el estado actual, así que la acción de cada stack
# (levantar / detener) depende de lo que esté corriendo en ese momento.

source "$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")/scripts/docker-stacks.sh"

SCRIPTS_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")/scripts"

mapfile -t stacks < <(docker_stack_ids)

entries=()  # texto que ve el usuario
actions=()  # comando por índice: "up <id>" | "down <id>"
running_stacks=0
usable_stacks=0

for id in "${stacks[@]}"; do
    docker_stack_load "$id"
    if [[ ! -d $STACK_DIR ]]; then
        entries+=("$STACK_ICON  $STACK_LABEL — ✗ sin proyecto compose")
        actions+=("noop")
        continue
    fi
    ((usable_stacks++))
    if [[ -n $(docker_stack_running "$STACK_DIR") ]]; then
        ((running_stacks++))
        entries+=("$STACK_ICON  $STACK_LABEL — 󰓛 detener")
        actions+=("down $id")
    else
        entries+=("$STACK_ICON  $STACK_LABEL — 󰐊 levantar")
        actions+=("up $id")
    fi
done

# En estado mixto aparecen las dos acciones globales; si no, sólo la que aplica
if ((running_stacks < usable_stacks)); then
    entries+=("󰐊  Levantar todo")
    actions+=("up")
fi
if ((running_stacks > 0)); then
    entries+=("󰓛  Detener todo")
    actions+=("down")
fi
entries+=("󰀪  Ver contenedores")
actions+=("ls")

# --index evita re-parsear el texto de la entrada elegida
index=$(printf '%s\n' "${entries[@]}" | fuzzel --dmenu --index --prompt "Docker: ")
[[ -n $index ]] || exit 0

read -r action target <<<"${actions[$index]}"

case "$action" in
up)
    setsid "$SCRIPTS_DIR/docker_up.sh" $target >/dev/null 2>&1 &
    ;;
down)
    setsid "$SCRIPTS_DIR/docker_down.sh" $target >/dev/null 2>&1 &
    ;;
ls)
    # kitty es la terminal del setup (xdg-terminals.list); --hold deja leer la salida
    setsid kitty --hold "$SCRIPTS_DIR/docker_ls.sh" >/dev/null 2>&1 &
    ;;
noop) ;;
esac

docker_refresh_waybar
