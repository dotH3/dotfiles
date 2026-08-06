#!/bin/bash
# Conecta/desconecta la VPN "Chemes" al hacer click en el módulo custom/vpn

VPN_NAME="Chemes"

if nmcli -t -f NAME,TYPE connection show --active | grep -qF "${VPN_NAME}:vpn"; then
    nmcli connection down "$VPN_NAME"
else
    nmcli connection up "$VPN_NAME"
fi

# Fuerza a waybar a refrescar el módulo de inmediato (signal 8, ver config)
pkill -RTMIN+8 waybar
