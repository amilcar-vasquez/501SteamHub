#!/bin/bash
# Wrapper script to run migrations with bad env vars unset

# Unset problematic PostgreSQL environment variables
unset PGLOCALEDIR
unset PGHASHDATADIR
unset PGSYSCONFDIR
unset PGDATADIR
unset PGVERSION
unset PGPATH
unset PGCONFIG
unset PGWITH_DEFAULTS

# Run the migrations
migrate -path ./migrations -database "${DB_DSN}" up
