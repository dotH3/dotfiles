#!/bin/bash
# Shows a wofi menu with shutdown/suspend/reboot options for the custom/power waybar module

options="󰐥  Shutdown\n󰜉  Restart\n󰤄  Suspend\n󰍃  Log out"

selected=$(echo -e "$options" | fuzzel --dmenu --prompt "Power menu: ")

case "$selected" in
    *Shutdown*)
        systemctl poweroff
        ;;
    *Restart*)
        systemctl reboot
        ;;
    *Suspend*)
        systemctl suspend
        ;;
    *"Log out"*)
        swaymsg exit
        ;;
esac
