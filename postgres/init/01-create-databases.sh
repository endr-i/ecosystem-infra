#!/bin/bash
# Creates one empty database per name listed in POSTGRES_DATABASES (comma separated).
# Runs on first initialisation of the postgres data volume.
set -euo pipefail

if [ -z "${POSTGRES_DATABASES:-}" ]; then
  echo "POSTGRES_DATABASES is not set, nothing to create."
  exit 0
fi

IFS=',' read -ra databases <<< "$POSTGRES_DATABASES"

for db in "${databases[@]}"; do
  db="$(echo "$db" | tr -d '[:space:]')"
  [ -z "$db" ] && continue

  exists="$(psql -tAc "SELECT 1 FROM pg_database WHERE datname = '${db}'" \
    --username "$POSTGRES_USER" --dbname "$POSTGRES_DB")"

  if [ "$exists" = "1" ]; then
    echo "Database '${db}' already exists, skipping."
  else
    echo "Creating database '${db}'..."
    psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
      -c "CREATE DATABASE \"${db}\" OWNER \"${POSTGRES_USER}\";"
  fi
done
