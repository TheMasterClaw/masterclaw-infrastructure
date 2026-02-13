#!/bin/bash
# backup.sh - Comprehensive backup script for MasterClaw

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${BACKUP_DIR:-$PROJECT_DIR/backups}"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=${RETENTION_DAYS:-7}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🐾 MasterClaw Backup${NC}"
echo "===================="

# Create backup directory
mkdir -p "$BACKUP_DIR"
BACKUP_PATH="$BACKUP_DIR/backup_$DATE"
mkdir -p "$BACKUP_PATH"

echo "📦 Backing up to: $BACKUP_PATH"

# Backup databases
echo "💾 Backing up databases..."
if [ -d "$PROJECT_DIR/data/backend" ]; then
    tar -czf "$BACKUP_PATH/backend.tar.gz" -C "$PROJECT_DIR/data" backend/
    echo -e "${GREEN}✅${NC} Backend data"
fi

if [ -d "$PROJECT_DIR/data/gateway" ]; then
    tar -czf "$BACKUP_PATH/gateway.tar.gz" -C "$PROJECT_DIR/data" gateway/
    echo -e "${GREEN}✅${NC} Gateway data"
fi

if [ -d "$PROJECT_DIR/data/core" ]; then
    tar -czf "$BACKUP_PATH/core.tar.gz" -C "$PROJECT_DIR/data" core/
    echo -e "${GREEN}✅${NC} Core data"
fi

if [ -d "$PROJECT_DIR/data/chroma" ]; then
    tar -czf "$BACKUP_PATH/chroma.tar.gz" -C "$PROJECT_DIR/data" chroma/
    echo -e "${GREEN}✅${NC} ChromaDB"
fi

# Backup configuration
echo "⚙️  Backing up configuration..."
if [ -f "$PROJECT_DIR/.env" ]; then
    cp "$PROJECT_DIR/.env" "$BACKUP_PATH/.env.backup"
    echo -e "${GREEN}✅${NC} Environment config"
fi

if [ -f "$PROJECT_DIR/docker-compose.yml" ]; then
    cp "$PROJECT_DIR/docker-compose.yml" "$BACKUP_PATH/"
    echo -e "${GREEN}✅${NC} Docker Compose config"
fi

# Create manifest
cat > "$BACKUP_PATH/MANIFEST.txt" << EOF
MasterClaw Backup Manifest
==========================
Date: $(date)
Hostname: $(hostname)
Version: $(cd "$PROJECT_DIR" && git describe --tags 2>/dev/null || echo "unknown")

Contents:
$(ls -la "$BACKUP_PATH")

Services Status:
$(cd "$PROJECT_DIR" && docker-compose ps 2>/dev/null || echo "Docker not running")
EOF

# Create final archive
echo "🗜️  Creating final archive..."
cd "$BACKUP_DIR"
tar -czf "masterclaw_backup_$DATE.tar.gz" "backup_$DATE"
rm -rf "backup_$DATE"

# Cleanup old backups
echo "🧹 Cleaning up backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -name "masterclaw_backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete

# Summary
BACKUP_SIZE=$(du -h "$BACKUP_DIR/masterclaw_backup_$DATE.tar.gz" | cut -f1)
BACKUP_COUNT=$(find "$BACKUP_DIR" -name "masterclaw_backup_*.tar.gz" | wc -l)

echo ""
echo -e "${GREEN}✅ Backup complete!${NC}"
echo "   File: masterclaw_backup_$DATE.tar.gz"
echo "   Size: $BACKUP_SIZE"
echo "   Total backups: $BACKUP_COUNT"
echo ""
echo -e "${YELLOW}🐾 MasterClaw data is safe.${NC}"
