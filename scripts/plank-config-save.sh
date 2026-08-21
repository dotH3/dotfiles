#!/bin/sh
# Exporta los settings del dock (posición, zoom, auto-hide, tema...) a texto
# plano para poder versionarlos.
#
# Plank no guarda esto en ~/.config/plank —ahí solo viven los .dockitem de los
# lanzadores pinneados—, sino en dconf, que es un único archivo binario
# compartido por todas las apps del sistema (~/.config/dconf/user). Por eso no
# alcanza con symlinkear la carpeta como hacemos con sway o waybar: hay que
# dumpear a mano esta rama del árbol.
#
# Correlo cada vez que toques la config del dock, si no el cambio queda solo en
# esta máquina.

set -e

DCONF_PATH="/net/launchpad/plank/"
OUT="$(dirname "$0")/../plank/settings.dconf"

dconf dump "$DCONF_PATH" > "$OUT"

echo "Settings del dock guardados en $(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT")"
