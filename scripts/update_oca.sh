#!/bin/bash
# Odoo Routine Module Update Script (Robust Version)

# --- Configuration ---
# 1. Use the stable Docker Compose Service Name
ODOO_SERVICE_NAME="odoo" 

# 2. Database name should be passed as the first argument, not hardcoded.
# This makes the script reusable for multiple databases.
DB_NAME="$1" 

# --- Input Validation ---
if [ -z "$DB_NAME" ]; then
    echo "ERROR: Please provide the database name as the first argument."
    echo "Usage: ./update.sh your_database_name"
    exit 1
fi

echo "=== Odoo Routine Module Update for Database: $DB_NAME ==="

# --- 1. Update Module List (Refresh Base App) ---
echo "1. Updating module list (-u base)..."
# Use 'docker compose exec' and the SERVICE NAME for reliability
docker compose exec "$ODOO_SERVICE_NAME" odoo -d "$DB_NAME" -u base --stop-after-init

# --- 2. Get Modules Requiring Update (Improved Query) ---
echo "2. Checking modules requiring updates..."
# Use 'docker compose exec' and '-q' option in psql to ensure clean output
MODULES=$(docker compose exec "$ODOO_SERVICE_NAME" psql -U odoo -d "$DB_NAME" -t -q -c \
"SELECT name FROM ir_module_module WHERE state IN ('installed', 'to upgrade') AND latest_version != installed_version;")

# Trim whitespace and newline characters from the SQL result
MODULES=$(echo "$MODULES" | xargs)

if [ -z "$MODULES" ]; then
    echo "No installed modules require an update."
    exit 0
fi

echo "Modules to update: $MODULES"

# --- 3. Prompt and Execute Individual Updates ---
read -p "Do you want to update these modules? (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # It is safer and clearer to use 'docker compose exec' consistently
    for module in $MODULES; do
        echo "Upgrading $module..."
        # Running modules one by one is crucial to catch dependency errors early
        docker compose exec "$ODOO_SERVICE_NAME" odoo -d "$DB_NAME" -u "$module" --stop-after-init
    done
    echo "Module updates completed."
else
    echo "Skipped updating modules."
fi