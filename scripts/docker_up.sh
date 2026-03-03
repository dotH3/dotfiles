#!/bin/bash

docker compose --project-directory "$HOME/docker/sql/" up -d
echo "=> Docker Running"
