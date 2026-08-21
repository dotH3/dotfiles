#!/bin/bash
# Indica si el micrófono está en uso (grabando) en este momento, para waybar (custom/mic).
#
# Un stream de captura cuenta como "micrófono en uso" solo si está enlazado a una
# fuente de entrada real (Audio/Source: micrófono integrado, USB, etc), no al
# monitor de un sink — p. ej. cava, que escucha la salida de audio y estaría
# siempre "grabando".
#
# Vía pw-dump (PipeWire) porque pactl no está instalado en este sistema; se deja
# el camino con pactl como respaldo para máquinas con pulseaudio-utils.

is_mic_active_pipewire() {
    pw-dump 2>/dev/null | jq -e '
        [.[] | select(.type == "PipeWire:Interface:Node")] as $nodes
        | [$nodes[] | select(.info.props."media.class" == "Audio/Source") | .id] as $sources
        | [$nodes[]
           | select((.info.props."media.class" // "") | startswith("Stream/Input"))
           | .id] as $captures
        | [.[]
           | select(.type == "PipeWire:Interface:Link")
           | .info
           | select((."output-node-id" | IN($sources[]))
                and (."input-node-id"  | IN($captures[])))]
        | length > 0
    ' >/dev/null
}

is_mic_active_pulse() {
    local real_sources active_sources src

    real_sources=$(pactl list sources short | awk '$2 !~ /\.monitor$/ {print $1}')
    [[ -z $real_sources ]] && return 1

    active_sources=$(pactl list source-outputs short | awk '{print $2}')
    for src in $active_sources; do
        grep -qx "$src" <<<"$real_sources" && return 0
    done
    return 1
}

is_mic_active() {
    if command -v pw-dump >/dev/null && command -v jq >/dev/null; then
        is_mic_active_pipewire
    elif command -v pactl >/dev/null; then
        is_mic_active_pulse
    else
        return 1
    fi
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
