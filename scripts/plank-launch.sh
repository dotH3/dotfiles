#!/bin/sh
# Levanta plank (el dock) en sway. Se llama desde un exec_always, así que corre
# tanto al arrancar la sesión como en cada reload.
#
# Dos rarezas de plank acá:
#
# 1. Plank aborta con "Only X11 environments are supported" si ve WAYLAND_DISPLAY
#    o XDG_SESSION_TYPE=wayland, aunque anda bien vía XWayland. Hay que
#    desetearlos y forzar GDK_BACKEND=x11.
#
# 2. Plank usa bamfdaemon (el matcher que asocia ventanas abiertas con lanzadores)
#    por D-Bus. El bamfdaemon.service de systemd hereda el env de la sesión
#    wayland y se cae con SIGSEGV, así que plank se queda ~15s esperando la
#    activación por D-Bus hasta que corta por timeout, y después arranca sin
#    matcher: íconos duplicados y sin indicador de "app abierta". Levantándolo
#    nosotros con el env X11 correcto anda bien.

X11_ENV="env -u WAYLAND_DISPLAY -u XDG_SESSION_TYPE GDK_BACKEND=x11"

killall -q plank bamfdaemon
# Barrer el re-posicionador de un reload anterior, que si no sigue vivo unos
# segundos más. El patrón va con [.] para que el pkill no matche su propia línea
# de comando y se suicide.
pkill -f 'plank-position[.]sh'

# La ruta de bamfdaemon es multiarch, no está en el PATH.
bamf=$(ls /usr/lib/*/bamf/bamfdaemon 2>/dev/null | head -1)
if [ -n "$bamf" ]; then
    $X11_ENV "$bamf" &
    # Esperar a que reclame el nombre en D-Bus, si no plank dispara la activación
    # por systemd (la que crashea) antes de que el nuestro esté listo.
    i=0
    while [ $i -lt 20 ]; do
        dbus-send --session --dest=org.freedesktop.DBus --type=method_call \
            --print-reply /org/freedesktop/DBus org.freedesktop.DBus.NameHasOwner \
            string:org.ayatana.bamf 2>/dev/null | grep -q true && break
        i=$((i + 1))
        sleep 0.25
    done
fi

$X11_ENV plank &

exec "$(dirname "$0")/plank-position.sh"
