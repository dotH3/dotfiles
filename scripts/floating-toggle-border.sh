#!/bin/sh
# mod+t alterna floating, pero sway no actualiza el borde de la ventana al
# cambiar de modo (default_border/default_floating_border solo aplican a
# ventanas nuevas). Así que después de alternar, forzamos el borde según el
# modo resultante: "normal" (con barrita) si quedó flotante, "pixel" si quedó
# tiled.
swaymsg floating toggle

focused=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true)')
mode=$(echo "$focused" | jq -r '.type')

if [ "$mode" = "floating_con" ]; then
    swaymsg border normal
else
    swaymsg border pixel 2
fi
