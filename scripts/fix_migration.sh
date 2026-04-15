#!/bin/bash
# Fix the database migration state

DB_DSN="postgres://501SteamHub:STEAMAdmin501@localhost/501SteamHub?sslmode=disable"

# Delete the failed migration entry
psql "$DB_DSN" <<EOF
DELETE FROM schema_migrations WHERE version = 27 AND dirty = true;
SELECT '=== Migration history after cleanup ===' as status;
SELECT * FROM schema_migrations;
EOF
