#!/bin/bash
# Visualizador de espectro para waybar (group/media), alimentado por cava.
#
# Módulo de salida continua: no lleva "interval", waybar lee una línea por
# frame. Cada línea de cava trae un valor 0-7 por barra separado por ";" y acá
# se traduce a caracteres de bloque.
#
# Ojo: cava escucha el monitor de la placa, o sea TODO el audio del sistema.
# Un video en otra pestaña o un sonido de notificación también mueven las barras,
# aunque el reproductor esté en pausa.

dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CONF="$dir/cava.conf"

# Sin cava el módulo queda vacío y waybar lo oculta, igual que el resto del grupo
command -v cava >/dev/null 2>&1 || exit 0
[[ -r $CONF ]] || exit 0

# cava no se muere solo cuando se va el que lo lee: no mira si le falla el write,
# así que sin esto queda dando vueltas para siempre con el monitor de audio
# tomado, y se acumula uno nuevo por cada reload de sway. Se lo baja a mano al
# salir, sea por SIGTERM (reload) o por el EPIPE de emit() cuando muere waybar.
limpiar() {
    trap - EXIT
    pkill -P $$ 2>/dev/null
    exit 0
}
trap limpiar EXIT TERM INT HUP PIPE

# Frames de silencio seguidos que hay que juntar antes de ocultar el módulo. Un
# silencio corto dentro de un tema no debería hacer desaparecer y reaparecer el
# bloque (además de que al estar en modules-center le movería el reloj al lado).
# 45 frames a 30fps = 1,5s
SILENCIO_MAX=45

# Frames sin escribir tras los cuales se reescribe el valor actual aunque no haya
# cambiado. Es la única manera de enterarse de que waybar se murió: el EPIPE
# llega recién cuando escribimos, así que si nos quedamos callados en silencio
# este script (y su cava, que sigue tomando el monitor de audio) quedan
# huérfanos para siempre. 150 frames a 30fps = 5s.
LATIDO_MAX=150

prev=""
silencio=0
sin_escribir=0
emit() {
    # Solo se escribe si cambió: en silencio o en pasajes sostenidos evita
    # redibujar la barra 30 veces por segundo al pedo
    if [[ $1 == "$prev" ]] && ((++sin_escribir < LATIDO_MAX)); then
        return
    fi
    sin_escribir=0
    prev=$1
    # Si waybar ya no está el SIGPIPE nos baja acá, que es justamente lo que se busca
    printf '%s\n' "$1" || exit 0
}

while read -r line; do
    if [[ $line != *[1-7]* ]]; then
        # Todo ceros: se aguanta la línea base hasta confirmar que el silencio es
        # real y no un respiro del tema. Recién ahí se oculta el módulo.
        if ((++silencio >= SILENCIO_MAX)); then
            emit ""
            continue
        fi
    else
        silencio=0
    fi
    out=${line//;/}
    out=${out//0/▁}
    out=${out//1/▂}
    out=${out//2/▃}
    out=${out//3/▄}
    out=${out//4/▅}
    out=${out//5/▆}
    out=${out//6/▇}
    out=${out//7/█}
    emit "$out"
done < <(cava -p "$CONF" 2>/dev/null)
