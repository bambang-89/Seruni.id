#!/bin/bash
# Restore database from backup
# Usage: ./restore.sh backup_file.sql.gz [new_db_name]

set -e

BACKUP_FILE="$1"
if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file.sql.gz> [new_db_name]"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

NEW_DB="${2:-seruni_restore}"

echo "[WARN] This will restore backup to a new database"
echo "[WARN] Source: $BACKUP_FILE"
echo "[WARN] Target DB: $NEW_DB"
echo ""
read -p "Continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo "[INFO] Restoring backup..."

# Decompress and restore
gunzip -c "$BACKUP_FILE" | psql "$DATABASE_URL"

echo "[INFO] Restore complete!"
echo "[INFO] Database: $NEW_DB"
