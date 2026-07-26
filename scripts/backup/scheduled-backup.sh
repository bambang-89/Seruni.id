#!/bin/bash
# Automated scheduled backup - keeps daily, weekly, monthly backups
# Add to crontab: 0 2 * * * /path/to/scripts/backup/scheduled-backup.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/seruni}"
RETENTION_DAYS=7
RETENTION_WEEKS=4
RETENTION_MONTHS=12

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting scheduled backup..."

# Daily backup
"$SCRIPT_DIR/backup.sh" "$BACKUP_DIR/daily/"

# Create weekly backup (Sunday)
if [ "$(date +%u)" = "7" ]; then
    log "Creating weekly backup..."
    cp "$BACKUP_DIR/daily/"*.sql.gz "$BACKUP_DIR/weekly/" 2>/dev/null || true
fi

# Create monthly backup (1st of month)
if [ "$(date +%d)" = "01" ]; then
    log "Creating monthly backup..."
    cp "$BACKUP_DIR/daily/"*.sql.gz "$BACKUP_DIR/monthly/" 2>/dev/null || true
fi

# Cleanup old backups
log "Cleaning up old backups..."

# Daily: keep 7 days
find "$BACKUP_DIR/daily" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete

# Weekly: keep 4 weeks
find "$BACKUP_DIR/weekly" -name "*.sql.gz" -mtime +$((RETENTION_WEEKS * 7)) -delete

# Monthly: keep 12 months
find "$BACKUP_DIR/monthly" -name "*.sql.gz" -mtime +$((RETENTION_MONTHS * 30)) -delete

log "Scheduled backup complete!"
log "Daily backups: $(ls -1 "$BACKUP_DIR/daily/"*.sql.gz 2>/dev/null | wc -l)"
log "Weekly backups: $(ls -1 "$BACKUP_DIR/weekly/"*.sql.gz 2>/dev/null | wc -l)"
log "Monthly backups: $(ls -1 "$BACKUP_DIR/monthly/"*.sql.gz 2>/dev/null | wc -l)"
