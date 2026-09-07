#!/bin/bash
# Reporta el estado de todos los stacks de docker compose en JSON para waybar
# (custom/docker). El registro de stacks vive en scripts/docker-stacks.sh.

source "$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")/scripts/docker-stacks.sh"

ICON=$'󰡨' # nf-md-docker

# Escapa lo mínimo para incrustar texto arbitrario (nombres, errores) en el JSON.
# Los saltos de línea reales pasan a "\n", que es como waybar los quiere en el tooltip.
json_escape() {
    local s=${1//\\/\\\\}
    s=${s//\"/\\\"}
    s=${s//$'\n'/\\n}
    printf '%s' "$s"
}

emit() {
    printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
        "$(json_escape "$1")" "$(json_escape "$2")" "$3"
    exit 0
}

nl=$'\n'
mapfile -t stacks < <(docker_stack_ids)

# Estados transitorios: docker_up.sh / docker_down.sh dejan un flag y mandan RTMIN+9
starting=() stopping=()
for id in "${stacks[@]}"; do
    docker_stack_load "$id"
    [[ -e $(docker_stack_flag "$id" starting) ]] && starting+=("$STACK_LABEL")
    [[ -e $(docker_stack_flag "$id" killing) ]] && stopping+=("$STACK_LABEL")
done
if ((${#starting[@]})); then
    emit "$ICON …" "Levantando: ${starting[*]}" "starting"
fi
if ((${#stopping[@]})); then
    emit "$ICON …" "Deteniendo: ${stopping[*]}" "stopping"
fi

# Traduce el error de compose a un mensaje corto y accionable
daemon_error() {
    case "$1" in
    *"permission denied"*)
        printf 'Sin permisos sobre el socket de Docker%s%s' "$nl" \
            "sudo usermod -aG docker $USER (y volver a iniciar sesión)"
        ;;
    *"Cannot connect"* | *daemon*) printf 'El daemon de Docker no está corriendo' ;;
    *) printf '%s' "${1%%$'\n'*}" ;;
    esac
}

total_running=0
stacks_up=0
tooltip=""
errors=()

for id in "${stacks[@]}"; do
    docker_stack_load "$id"
    [[ -n $tooltip ]] && tooltip+="$nl"

    if [[ ! -d $STACK_DIR ]]; then
        errors+=("$STACK_LABEL")
        tooltip+="$STACK_ICON $STACK_LABEL — ✗ sin proyecto compose$nl  $STACK_DIR$nl"
        continue
    fi

    if ! out=$(docker compose --project-directory "$STACK_DIR" ps --all --format json 2>&1); then
        errors+=("$STACK_LABEL")
        tooltip+="$STACK_ICON $STACK_LABEL — ✗ $(daemon_error "$out")$nl"
        continue
    fi

    # compose devuelve un array JSON (o NDJSON en versiones viejas): ambos se aplanan igual
    mapfile -t rows < <(
        printf '%s' "$out" |
            jq -r 'if type == "array" then .[] else . end | "\(.Name)|\(.State)"' 2>/dev/null
    )

    running=() stopped=()
    for row in "${rows[@]}"; do
        name=${row%%|*}
        state=${row##*|}
        [[ -n $name ]] || continue
        if [[ $state == running ]]; then
            running+=("  ● $name")
        else
            stopped+=("  ○ $name ($state)")
        fi
    done

    ((total_running += ${#running[@]}))
    ((${#running[@]})) && ((stacks_up++))

    if ((${#running[@]} + ${#stopped[@]} == 0)); then
        tooltip+="$STACK_ICON $STACK_LABEL — sin contenedores$nl"
        continue
    fi

    if ((${#running[@]})); then
        tooltip+="$STACK_ICON $STACK_LABEL — corriendo$nl"
    else
        tooltip+="$STACK_ICON $STACK_LABEL — detenido$nl"
    fi
    ((${#running[@]})) && tooltip+="$(printf '%s\n' "${running[@]}")$nl"
    ((${#stopped[@]})) && tooltip+="$(printf '%s\n' "${stopped[@]}")$nl"
done

tooltip+="${nl}Click para elegir stack"

# Un stack roto no oculta a los demás: el error sólo gana si nada está corriendo
if ((${#errors[@]} && total_running == 0)); then
    emit "$ICON ✗" "$tooltip" "error"
fi

if ((total_running == 0)); then
    emit "$ICON 0" "$tooltip" "stopped"
elif ((stacks_up < ${#stacks[@]})); then
    emit "$ICON $total_running" "$tooltip" "partial"
else
    emit "$ICON $total_running" "$tooltip" "running"
fi
