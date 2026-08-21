#!/bin/sh
# Restaura los settings del dock guardados por plank-config-save.sh.
# Es lo que hay que correr al clonar los dotfiles en una máquina nueva.
#
# Ojo: pisa la config actual del dock con la del repo. No se corre solo desde el
# sway config a propósito —si lo hiciera, cualquier ajuste que hagas desde las
# preferencias del dock se te revertiría en el siguiente reload.
#
# Plank aplica los cambios en vivo, no hace falta reiniciarlo.

set -e

DCONF_PATH="/net/launchpad/plank/"
IN="$(dirname "$0")/../plank/settings.dconf"

if [ ! -f "$IN" ]; then
    echo "No existe $IN; corré plank-config-save.sh primero." >&2
    exit 1
fi

dconf load "$DCONF_PATH" < "$IN"

echo "Settings del dock restaurados desde $(cd "$(dirname "$IN")" && pwd)/$(basename "$IN")"
