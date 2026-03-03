#!/bin/bash

# Configuración de rutas - Modificar aquí para cambiar las rutas
DOTFILES_DIR="/home/h3/dotfiles"
BACKUPS_DIR="/home/h3/backups"

# Nombre del backup con timestamp
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
BACKUP_NAME="dotfiles_backup_${TIMESTAMP}"

# Copiar la carpeta dotfiles completa
cp -r "$DOTFILES_DIR" "$BACKUPS_DIR/dotfiles/$BACKUP_NAME"

if [ $? -eq 0 ]; then
    echo "=> $BACKUPS_DIR/dotfiles/$BACKUP_NAME"
else
    echo "Error al crear el backup"
    exit 1
fi
