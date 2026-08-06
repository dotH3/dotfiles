# #!/bin/sh
# # Uso: global_workspaces.sh N  -> activa el workspace global N en ambos monitores

# # Sway solo cambia el workspace del monitor enfocado.
# # Guardamos cuál es para devolver el foco al final.
# CUR=$(swaymsg -t get_outputs | jq -r '.[]|select(.focused)|.name')

# # Monitor derecho -> workspace "N:2"
# swaymsg "focus output HDMI-A-2, workspace $1:2"

# # Monitor izquierdo -> workspace "N:1"
# swaymsg "focus output HDMI-A-1, workspace $1:1"

# # Restaura el foco
# swaymsg "focus output $CUR"
