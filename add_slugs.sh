#!/bin/bash

# Script to run the migration to add slugs to existing resources
# This allows existing resources to be viewable via the new slug-based URLs

echo "Adding slugs to existing resources in the database..."

# Run the migration
cd "$(dirname "$0")"

# Check if we're in the correct directory
if [ ! -f "migrations/018_add_slugs_to_existing_resources.up.sql" ]; then
    echo "Error: Migration file not found. Make sure you're running this from the project root."
    exit 1
fi

# Run the migration using migrate tool if available
if command -v migrate &> /dev/null; then
    echo "Using migrate tool..."
    migrate -path migrations -database "${DATABASE_URL}" up 1
elif command -v psql &> /dev/null; then
    echo "Using psql..."
    # Assuming you have DATABASE_URL or can connect via psql
    if [ -z "$DATABASE_URL" ]; then
        echo "Please set DATABASE_URL environment variable or modify this script to connect to your database"
        echo "Example: DATABASE_URL='postgres://username:password@localhost:5432/dbname?sslmode=disable'"
        echo ""
        echo "Alternatively, you can run the migration manually:"
        echo "psql -U your_user -d your_database -f migrations/018_add_slugs_to_existing_resources.up.sql"
        exit 1
    fi
    psql "$DATABASE_URL" -f migrations/018_add_slugs_to_existing_resources.up.sql
else
    echo "Neither 'migrate' nor 'psql' command found."
    echo "Please run the migration manually:"
    echo "psql -U your_user -d your_database -f migrations/018_add_slugs_to_existing_resources.up.sql"
    exit 1
fi

echo "Migration complete! Existing resources now have slugs."
echo "You can now navigate to resource pages using the ResourceCard components."
