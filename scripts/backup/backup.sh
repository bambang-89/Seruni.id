#!/bin/bash
# Supabase Database Backup Script
# Usage: ./backup.sh [output_dir]
# Default output: ./backups/

set -e

# Configuration
OUTPUT_DIR="${1:-./backups}"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="seruni_backup_${DATE}.sql.gz"
PROJECT_REF="${SUPABASE_PROJECT_REF:-smngqdpbmgcdbmkiuviq}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup directory
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/logs"

log_info "Starting database backup..."
log_info "Project: $PROJECT_REF"
log_info "Output: $OUTPUT_DIR/$BACKUP_NAME"

# Method 1: Using Supabase CLI (if available)
if command -v supabase &> /dev/null; then
    log_info "Using Supabase CLI for backup..."
    supabase db dump -p "$PROJECT_REF" --db-url "$DATABASE_URL" | gzip > "$OUTPUT_DIR/$BACKUP_NAME"
    log_info "Backup created: $BACKUP_NAME"
else
    # Method 2: Using pg_dump directly
    if command -v pg_dump &> /dev/null; then
        log_info "Using pg_dump for backup..."
        pg_dump "$DATABASE_URL" | gzip > "$OUTPUT_DIR/$BACKUP_NAME"
        log_info "Backup created: $BACKUP_NAME"
    else
        # Method 3: Using Supabase Management API
        log_info "Using Supabase Management API for backup..."
        # Note: Requires SUPABASE_ACCESS_TOKEN
        if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
            log_error "SUPABASE_ACCESS_TOKEN not set. Please set it to use this method."
            log_error "Or install Supabase CLI: npm install -g supabase"
            exit 1
        fi

        # Create backup via API
        RESPONSE=$(curl -s -X POST \
            "https://api.supabase.com/v1/projects/$PROJECT_REF/backups" \
            -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \
            -H "Content-Type: application/json")

        BACKUP_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

        if [ -n "$BACKUP_ID" ]; then
            log_info "Backup initiated: $BACKUP_ID"
            log_info "Backup will be available at: https://supabase.com/dashboard/project/$PROJECT_REF/backups"
        else
            log_error "Failed to initiate backup"
            log_error "Response: $RESPONSE"
            exit 1
        fi
    fi
fi

# Verify backup
if [ -f "$OUTPUT_DIR/$BACKUP_NAME" ]; then
    SIZE=$(du -h "$OUTPUT_DIR/$BACKUP_NAME" | cut -f1)
    log_info "Backup verified: $SIZE"

    # Create metadata file
    cat > "$OUTPUT_DIR/${BACKUP_NAME}.meta" << EOF
{
    "backup_date": "$(date -Iseconds)",
    "project_ref": "$PROJECT_REF",
    "backup_file": "$BACKUP_NAME",
    "size": "$SIZE",
    "method": "pg_dump",
    "version": "1.0"
}
EOF
    log_info "Metadata created"
else
    log_error "Backup file not found!"
    exit 1
fi

# Cleanup old backups (keep last 30)
log_info "Cleaning up old backups (keeping last 30)..."
cd "$OUTPUT_DIR"
ls -t *.sql.gz 2>/dev/null | tail -n +31 | xargs -r rm
log_info "Cleanup complete"

# Log
echo "$(date -Iseconds) - $BACKUP_NAME - $SIZE" >> "$OUTPUT_DIR/logs/backup.log"

log_info "Backup complete!"
log_info "Backup location: $OUTPUT_DIR/$BACKUP_NAME"
