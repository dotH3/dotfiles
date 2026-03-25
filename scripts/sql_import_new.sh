#!/bin/bash
CONTAINER="ecomenu-db"
DB_NAME="ecomenuDB"
DB_USER="root"
DB_PASS="rootpassword"
SQL_FILE="$HOME/backups/ecomenu/primary.sql"
importingFlag="/tmp/docker_importing"
# touch "$importingFlag"
pkill -RTMIN+9 waybar

START=$(date +%s)

docker exec -i "$CONTAINER" mysql -u "$DB_USER" -p"$DB_PASS" \
  -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;" && \
{
  echo "SET foreign_key_checks=0; SET unique_checks=0; SET autocommit=0;"
  cat "$SQL_FILE"
  echo "COMMIT;"
} | docker exec -i "$CONTAINER" mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME"

END=$(date +%s)
ELAPSED=$((END - START))

rm -f "$importingFlag"
pkill -RTMIN+9 waybar

notify-send "ecomenu import" "Completado en ${ELAPSED}s"
echo "Import completado en ${ELAPSED}s"
