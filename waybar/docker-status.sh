#!/bin/bash
# Reporta el estado del stack de docker compose en formato JSON para waybar (custom/docker)

PROJECT_DIR="${WAYBAR_DOCKER_PROJECT_DIR:-$HOME/docker/db}"
STARTING_FLAG="/tmp/docker_starting"
KILLING_FLAG="/tmp/docker_killing"
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

# Estados transitorios: docker_up.sh / docker_down.sh dejan un flag y mandan RTMIN+9
[[ -e "$STARTING_FLAG" ]] && emit "$ICON …" "Levantando contenedores…" "starting"
[[ -e "$KILLING_FLAG" ]] && emit "$ICON …" "Deteniendo contenedores…" "stopping"

[[ -d "$PROJECT_DIR" ]] ||
    emit "$ICON ✗" "No existe el proyecto compose:"$'\n'"$PROJECT_DIR" "error"

if ! out=$(docker compose --project-directory "$PROJECT_DIR" ps --all --format json 2>&1); then
    case "$out" in
    *"permission denied"*)
        msg="Sin permisos sobre el socket de Docker"$'\n'"sudo usermod -aG docker $USER (y volver a iniciar sesión)"
        ;;
    *"Cannot connect"* | *daemon*)
        msg="El daemon de Docker no está corriendo"
        ;;
    *)
        msg=${out%%$'\n'*}
        ;;
    esac
    emit "$ICON ✗" "$msg" "error"
fi

# compose devuelve un array JSON (o NDJSON en versiones viejas): ambos se aplanan igual
mapfile -t rows < <(
    printf '%s' "$out" |
        jq -r 'if type == "array" then .[] else . end | "\(.Name)|\(.State)"' 2>/dev/null
)

running=()
stopped=()
for row in "${rows[@]}"; do
    name=${row%%|*}
    state=${row##*|}
    [[ -n $name ]] || continue
    if [[ $state == running ]]; then
        running+=("  $name")
    else
        stopped+=("  $name ($state)")
    fi
done

if ((${#running[@]} + ${#stopped[@]} == 0)); then
    emit "$ICON 0" "Sin contenedores en $PROJECT_DIR"$'\n\n'"Click para levantar" "stopped"
fi

nl=$'\n'
tooltip=""
if ((${#running[@]})); then
    tooltip="Corriendo:$nl$(printf '%s\n' "${running[@]}")"
fi
if ((${#stopped[@]})); then
    [[ -n $tooltip ]] && tooltip+="$nl"
    tooltip+="Detenidos:$nl$(printf '%s\n' "${stopped[@]}")"
fi

if ((${#running[@]})); then
    emit "$ICON ${#running[@]}" "$tooltip$nl${nl}Click para detener" "running"
else
    emit "$ICON 0" "$tooltip$nl${nl}Click para levantar" "stopped"
fi
