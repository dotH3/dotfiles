#!/bin/bash

PROJECT_DIR="$HOME/docker/sql/"

docker compose --project-directory "$PROJECT_DIR" down -v
echo "=> Container and volume dropped"
