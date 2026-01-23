#!/bin/bash

set -eux;

# Init database structure (schemas, tables, indexes, functions, views, triggers, etc.)
psql -v ON_ERROR_STOP=1 --username "$DB_ADMIN" --dbname "$DB_NAME" -f "/structure.sql"

# Init database users and their privileges
psql -v ON_ERROR_STOP=1 \
    --username "$DB_ADMIN" \
    --dbname "$DB_NAME" \
    -v db_name="$DB_NAME" \
    -v maintenance_admin="$DB_ADMIN" \
    -v db_user="$DB_USER" -v db_user_password="$DB_USER_PASSWORD" \
    -f "/access.sql"
