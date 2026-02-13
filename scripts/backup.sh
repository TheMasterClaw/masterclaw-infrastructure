#!/bin/bash
# backup.sh - Automated backup script for MasterClaw

BACKUP_DIR="/backups/masterclaw"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup SQLite database
echo "[$(date)] Backing up database..."
tar -czf "$BACKUP_DIR/db_$DATE.tar.gz" ./data/

# Backup gateway data
echo "[$(date)] Backing up gateway data..."
tar -czf "$BACKUP_DIR/gateway_$DATE.tar.gz" ./gateway-data/

# Cleanup old backups
echo "[$(date)] Cleaning up backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "[$(date)] Backup complete: $BACKUP_DIR"
