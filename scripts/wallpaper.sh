#!/bin/sh
# Wallpaper de Sway.
#
# Modo por defecto: video animado. Para cambiar, editá MODE acá abajo (o
# exportá WALLPAPER_MODE) y recargá sway con mod+Shift+c:
#
#   video  fondo animado ($VIDEO) con mpvpaper
#   image  imagen estática ($IMAGE) con swaybg
#   black  fondo negro liso
#
# swaybg solo muestra imágenes estáticas, así que para el modo video usamos
# mpvpaper: es mpv dibujando sobre la capa "background" de wlr-layer-shell, o
# sea el mismo lugar donde swaybg pone la imagen. Instalarlo con
# scripts/mpvpaper-install.sh (queda en ~/.local/bin, sin sudo).
#
# Se llama desde exec_always, que corre de nuevo en cada reload de sway, así
# que primero matamos la instancia anterior o quedan wallpapers apilados.
#
# OJO: la línea "output * bg" del config de sway tiene que quedar comentada.
# Levanta su propio swaybg, que se pone encima y tapa a mpvpaper.

MODE="${WALLPAPER_MODE:-video}"
VIDEO="${WALLPAPER_VIDEO:-$HOME/dotfiles/wallpapers/abi-toads-terrarium.mp4}"
# VIDEO="${WALLPAPER_VIDEO:-$HOME/dotfiles/wallpapers/rei-animated.mp4}"
IMAGE="${WALLPAPER_IMAGE:-$HOME/dotfiles/wallpapers/rei.jpg}"

# sway no siempre hereda ~/.local/bin en el PATH, así que lo buscamos a mano
MPVPAPER="$HOME/.local/bin/mpvpaper"
[ -x "$MPVPAPER" ] || MPVPAPER="$(command -v mpvpaper 2>/dev/null)"

killall -q mpvpaper mpvpaper-holder swaybg

if [ "$MODE" = "video" ] && [ -n "$MPVPAPER" ] && [ -x "$MPVPAPER" ] && [ -f "$VIDEO" ]; then
    # -f            forkea, si no exec_always se queda colgado esperándolo
    # -s            para mpv cuando el wallpaper queda tapado, así no gasta GPU
    #               decodificando algo que no se ve. Se puede sumar "-a MAX"
    #               para que también pare con cualquier ventana maximizada,
    #               pero en un tiling eso lo apaga casi siempre.
    # ALL           todas las salidas (HDMI-A-1 y HDMI-A-2)
    # panscan=1.0   recorta para llenar la pantalla en vez de dejar barras
    exec "$MPVPAPER" -f -s \
        -o "no-audio loop-file=inf panscan=1.0 hwdec=auto" \
        ALL "$VIDEO"
fi

if [ "$MODE" = "image" ] && [ -f "$IMAGE" ]; then
    exec swaybg -i "$IMAGE" -m fill
fi

# Modo black, y fallback si falta mpvpaper o el video. Nunca quedamos sin fondo.
exec swaybg -c "#000000"
