#!/bin/bash
# Reporta el estado de la VPN "Chemes" en formato JSON para waybar (custom/vpn)

VPN_NAME="Chemes"
LOCKED=$''   # fa-lock
UNLOCKED=$'' # fa-unlock

if nmcli -t -f NAME,TYPE connection show --active | grep -qF "${VPN_NAME}:vpn"; then
    echo "{\"text\":\"${LOCKED} VPN\",\"tooltip\":\"VPN conectada ($VPN_NAME) - click para desconectar\",\"class\":\"connected\"}"
else
    echo "{\"text\":\"${UNLOCKED} VPN\",\"tooltip\":\"VPN desconectada - click para conectar ($VPN_NAME)\",\"class\":\"disconnected\"}"
fi
