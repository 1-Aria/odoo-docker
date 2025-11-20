#!/bin/bash
# Automated Backup Script (Recommended)

# --- Configuration ---
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="../backups"
DB_NAME="odoo-db"
DB_SERVICE_NAME="db"
# !!! IMPORTANT: Check this name with 'docker volume ls' !!! format is <project>_<web-volume>
VOLUME_NAME="odoo-docker_odoo-web-data" 

# --- Setup ---
mkdir -p $BACKUP_DIR

# --- 1. Database Backup (Compressed Custom Format) ---
echo "Backing up database (compressed)..."
# Using -Fc (Custom Format) and piping to gzip for compression and smaller size
docker exec $DB_SERVICE_NAME pg_dump -U odoo -Fc $DB_NAME | gzip > "$BACKUP_DIR/db_${DB_NAME}_${TIMESTAMP}.dump.gz"
if [ $? -ne 0 ]; then
    echo "ERROR: Database backup failed."
    exit 1
fi

# --- 2. Filestore Backup (Volume Archive) ---
echo "Backing up filestore..."
# Running tar inside a temporary alpine container to compress the Odoo volume
docker run --rm -v $VOLUME_NAME:/data -v $(pwd)/$BACKUP_DIR:/backup \
    alpine tar czf /backup/filestore_${TIMESTAMP}.tar.gz -C /data .

# --- 3. Retention Policy (Keep only last 10) ---
echo "Cleaning up old backups (keeping 10)..."
# Deletes old .dump.gz and .tar.gz files based on modification time
ls -t $BACKUP_DIR/db_*.dump.gz | tail -n +11 | xargs -r rm
ls -t $BACKUP_DIR/filestore_*.tar.gz | tail -n +11 | xargs -r rm

echo "Backup completed successfully: ${TIMESTAMP}"