#!/bin/sh
# Plank corre bajo XWayland y sway lo trata como una ventana flotante normal:
# al hacer "floating enable" sway lo centra en vez de respetar la posición que
# plank pide para sí mismo (abajo del todo), así que hay que reposicionarlo a
# mano después de que el compositor termine de mapearlo.
#
# Ojo con el timeout: plank puede tardar bastante en mapear su ventana (si el
# bamfdaemon no está corriendo se queda esperando que D-Bus lo active hasta que
# corta por timeout, ~15s), así que hay que esperarlo con paciencia.

query='[.. | objects | select(.window_properties?.class? == "Plank")][0]'

reposition() {
    win=$(swaymsg -t get_tree | jq -c "$query")
    [ "$win" = "null" ] || [ -z "$win" ] && return 1

    win_id=$(echo "$win" | jq -r '.id')
    win_w=$(echo "$win" | jq -r '.rect.width')
    win_h=$(echo "$win" | jq -r '.rect.height')

    output=$(swaymsg -t get_outputs | jq -c '[.[] | select(.focused == true)][0] // .[0]')
    out_x=$(echo "$output" | jq -r '.rect.x')
    out_y=$(echo "$output" | jq -r '.rect.y')
    out_w=$(echo "$output" | jq -r '.rect.width')
    out_h=$(echo "$output" | jq -r '.rect.height')

    swaymsg "[con_id=$win_id] move absolute position \
        $((out_x + (out_w - win_w) / 2)) $((out_y + out_h - win_h))" > /dev/null
}

# Esperar a que aparezca la ventana.
i=0
while [ $i -lt 120 ]; do
    reposition && break
    i=$((i + 1))
    sleep 0.5
done
[ $i -ge 120 ] && exit 0

# Plank reajusta su tamaño después de mapearse (íconos que entran, zoom, tema),
# y cada resize la vuelve a descolocar, así que re-afirmamos la posición un rato.
i=0
while [ $i -lt 10 ]; do
    sleep 1
    reposition
    i=$((i + 1))
done
