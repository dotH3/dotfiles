#!/usr/bin/env bash
# Layouts XKB disponibles en el sistema

mapfile -t layouts < <(
  if command -v localectl >/dev/null; then
    localectl list-x11-keymap-layouts
  else
    awk '/^! layout/{f=1;next} /^!/{f=0} f && NF{print $1}' \
      /usr/share/X11/xkb/rules/base.lst
  fi
)

printf '%s\n' "${layouts[@]}"
echo "Total: ${#layouts[@]}"
