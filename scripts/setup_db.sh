#!/bin/bash

# Database setup script for 501SteamHub

echo "Setting up PostgreSQL database for 501SteamHub..."

# Create user and database as postgres superuser
sudo -u postgres psql << EOF
-- Create user if not exists
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '501SteamHub') THEN
    CREATE USER "501SteamHub" WITH PASSWORD 'STEAMAdmin501';
  END IF;
END
\$\$;

-- Drop database if exists (for clean setup)
DROP DATABASE IF EXISTS "501SteamHub";

-- Create database
CREATE DATABASE "501SteamHub" OWNER "501SteamHub";

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE "501SteamHub" TO "501SteamHub";
EOF

echo "Database setup complete!"
echo "User: 501SteamHub"
echo "Database: 501SteamHub"
echo ""
echo "Now running migrations..."
