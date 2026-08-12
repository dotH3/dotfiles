#!/bin/bash
# Controla el reproductor MPRIS activo desde waybar (group/media)
# Uso: media-ctl.sh <play-pause|next|previous>

case "$1" in
play-pause | next | previous) ;;
*)
    echo "uso: ${0##*/} <play-pause|next|previous>" >&2
    exit 1
    ;;
esac

command -v playerctl >/dev/null 2>&1 || exit 0

# media-status.sh es el que decide cuál es el player activo; se reusa para que
# el click caiga siempre sobre el mismo que se está mostrando en la barra.
dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
instance=$("$dir/media-status.sh" player)
[[ -n $instance ]] || exit 0

playerctl -p "$instance" "$1" 2>/dev/null

# Refresco inmediato de los tres módulos (signal 10 -> RTMIN+10). El sleep le da
# tiempo a MPRIS a propagar el cambio; sin él el icono se leería al revés.
sleep 0.15
pkill -RTMIN+10 waybar
