#!/bin/bash

DIR="$HOME/Pictures/Screenshots"
FILE="$DIR/Screenshot from $(date +'%Y-%m-%d %H-%M-%S').png"

mkdir -p "$DIR"

grim -g "$(slurp)" "$FILE" || exit 1

wl-copy < "$FILE"
notify-send "Captura guardada" "$FILE" -i "$FILE"
