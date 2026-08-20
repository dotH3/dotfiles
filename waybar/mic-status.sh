#!/bin/bash
# Indica si el micrófono está en uso (grabando) en este momento, para waybar (custom/mic).
#
# Un source-output cuenta como "micrófono en uso" solo si su Source no es el monitor
# de un sink (p. ej. cava, que escucha la salida de audio), sino una fuente de
# entrada real (micrófono integrado, USB, etc).

is_mic_active() {
    local real_sources active_sources src

    real_sources=$(pactl list sources short | awk '$2 !~ /\.monitor$/ {print $1}')
    [[ -z $real_sources ]] && return 1

    active_sources=$(pactl list source-outputs short | awk '{print $2}')
    for src in $active_sources; do
        grep -qx "$src" <<<"$real_sources" && return 0
    done
    return 1
}

case "$1" in
check)
    is_mic_active
    exit $?
    ;;
*)
    is_mic_active && echo '{"text":"●","tooltip":"Micrófono en uso","class":"active"}'
    ;;
esac
