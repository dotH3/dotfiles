#!/bin/bash
CONTAINER="ecomenu-db"
DB_NAME="ecomenuDB"
DB_USER="root"
DB_PASS="rootpassword"
SQL_FILE="$HOME/backups/ecomenu/primary.sql"

docker exec -i "$CONTAINER" mysql -u "$DB_USER" -p"$DB_PASS" \
  -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;" && \
docker exec -i "$CONTAINER" mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SQL_FILE"