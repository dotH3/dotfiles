#!/bin/bash
# Reporta el reproductor MPRIS activo en formato JSON para waybar (group/media)
# Uso: media-status.sh <title|prev|next|player>
#
#   title   texto = icono play/pause + "artista - tema", con tooltip
#   prev    solo el icono de "anterior"
#   next    solo el icono de "siguiente"
#   player  imprime el nombre de instancia del player elegido (lo usa media-ctl.sh)

# Orden de prioridad: primero las apps de música, %any deja los navegadores al
# final para que una pestaña de YouTube no le robe el módulo a Strawberry.
PLAYERS="${WAYBAR_MEDIA_PLAYERS:-strawberry,audacious,vlc,mpv,spotify,%any}"

SEP=$'\x1f' # unit separator: no aparece en los metadatos y no lo colapsa IFS

# Los glifos van como escapes para que no dependan del editor. Misma familia
# FontAwesome que usaba el módulo mpd, cubierta por el font stack de style.css
PLAY=$'\uF04B'  # fa-play
PAUSE=$'\uF04C' # fa-pause
PREV=$'\uF048'  # fa-step-backward
NEXT=$'\uF051'  # fa-step-forward

mode="${1:-title}"
case "$mode" in
title | prev | next | player) ;;
*)
    echo "uso: ${0##*/} <title|prev|next|player>" >&2
    exit 1
    ;;
esac

# Escapa lo mínimo para incrustar texto arbitrario (títulos, rutas) en el JSON.
json_escape() {
    local s=${1//\\/\\\\}
    s=${s//\"/\\\"}
    s=${s//$'\n'/\\n}
    printf '%s' "$s"
}

# El tooltip se renderiza como pango markup, así que un "&" o un "<" en el
# nombre del tema lo dejaría en blanco si no se escapa.
# Los "\&" son necesarios: desde bash 5.2 un "&" suelto en el reemplazo se
# expande al texto que matcheó el patrón.
pango_escape() {
    local s=${1//&/\&amp;}
    s=${s//</\&lt;}
    s=${s//>/\&gt;}
    printf '%s' "$s"
}

emit() {
    printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
        "$(json_escape "$1")" "$(json_escape "$2")" "$3"
    exit 0
}

# Sin playerctl, sin players o con todo detenido: texto vacío y waybar oculta
# el módulo, así los tres botones desaparecen juntos.
hide() {
    [[ $mode == player ]] || printf '{"text":""}\n'
    exit 0
}

command -v playerctl >/dev/null 2>&1 || hide

# Elige el player activo: el primero que esté sonando y, si no hay ninguno, el
# primero en pausa. Dentro de cada grupo manda el orden de $PLAYERS.
instance=""
state=""
while IFS=$SEP read -r inst status; do
    [[ -n $inst ]] || continue
    case "$status" in
    Playing)
        instance=$inst
        state=playing
        break
        ;;
    Paused)
        if [[ -z $instance ]]; then
            instance=$inst
            state=paused
        fi
        ;;
    esac
done < <(playerctl -p "$PLAYERS" -a metadata --format "{{playerInstance}}${SEP}{{status}}" 2>/dev/null)

[[ -n $instance ]] || hide

case "$mode" in
player) printf '%s\n' "$instance"; exit 0 ;;
prev) emit "$PREV" "Tema anterior" "$state" ;;
next) emit "$NEXT" "Tema siguiente" "$state" ;;
esac

# --- modo title ---

fields="{{artist}}${SEP}{{title}}${SEP}{{album}}${SEP}{{xesam:url}}"
meta=$(playerctl -p "$instance" metadata --format "${fields}${SEP}{{duration(position)}}${SEP}{{duration(mpris:length)}}" 2>/dev/null)
# Los streams y algunos players no exponen posición: se reintenta sin esos campos
[[ -n $meta ]] || meta=$(playerctl -p "$instance" metadata --format "$fields" 2>/dev/null)

IFS=$SEP read -r artist title album url position length <<<"$meta"

if [[ -n $artist && -n $title ]]; then
    name="$artist - $title"
elif [[ -n $title ]]; then
    name=$title
elif [[ $url == file://* ]]; then
    # Archivo local sin tags (típico de mpv/VLC): nombre de archivo sin
    # extensión y con los %20 de la URL decodificados
    name=${url##*/}
    name=${name%.*}
    name=$(printf '%b' "${name//%/\\x}")
elif [[ -n $url ]]; then
    name=$url
else
    name="Reproduciendo"
fi

if [[ $state == playing ]]; then
    icon=$PAUSE # el icono muestra la acción del click, no el estado
    action="Click para pausar"
else
    icon=$PLAY
    action="Click para reanudar"
fi

nl=$'\n'
# Sin título usable cae el mismo nombre que se muestra en la barra, para que el
# tooltip nunca arranque con un campo secundario (o vacío)
if [[ -n $title ]]; then
    tooltip="$(pango_escape "$title")$nl"
else
    tooltip="$(pango_escape "$name")$nl"
fi
[[ -n $artist ]] && tooltip+="$(pango_escape "$artist")$nl"
[[ -n $album ]] && tooltip+="$(pango_escape "$album")$nl"

foot=${instance%%.*} # firefox.instance_1_11 -> firefox
[[ -n $position && -n $length ]] && foot+=" · $position/$length"
tooltip+="$foot$nl$nl$action"

emit "$icon $name" "$tooltip" "$state"
