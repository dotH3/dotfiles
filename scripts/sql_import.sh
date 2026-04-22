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
docker exec -i "$CONTAINER" mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SQL_FILE"

END=$(date +%s)
ELAPSED=$((END - START))

rm -f "$importingFlag"
pkill -RTMIN+9 waybar

notify-send "ecomenu import" "Completado en ${ELAPSED}s"
echo "=> SQL restored in ${ELAPSED}s"
