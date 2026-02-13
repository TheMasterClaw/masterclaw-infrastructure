#!/bin/bash
# restore.sh - Restore MasterClaw from backup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🐾 MasterClaw Restore${NC}"
echo "====================="

# List available backups
BACKUP_DIR="${BACKUP_DIR:-$PROJECT_DIR/backups}"
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}❌ No backups directory found${NC}"
    exit 1
fi

echo "📦 Available backups:"
echo ""
BACKUPS=($(ls -1t "$BACKUP_DIR"/masterclaw_backup_*.tar.gz 2>/dev/null || true))

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo -e "${RED}❌ No backups found in $BACKUP_DIR${NC}"
    exit 1
fi

for i in "${!BACKUPS[@]}"; do
    BACKUP_FILE="${BACKUPS[$i]}"
    BACKUP_NAME=$(basename "$BACKUP_FILE")
    BACKUP_DATE=$(stat -c %y "$BACKUP_FILE" 2>/dev/null || stat -f %Sm "$BACKUP_FILE")
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "  [$i] $BACKUP_NAME ($BACKUP_SIZE) - $BACKUP_DATE"
done

echo ""
read -p "Enter backup number to restore [0]: " SELECTION
SELECTION=${SELECTION:-0}

if [ "$SELECTION" -lt 0 ] || [ "$SELECTION" -ge "${#BACKUPS[@]}" ]; then
    echo -e "${RED}❌ Invalid selection${NC}"
    exit 1
fi

SELECTED_BACKUP="${BACKUPS[$SELECTION]}"
echo ""
echo -e "${YELLOW}⚠️  WARNING: This will replace current data with backup contents${NC}"
echo "   Backup: $(basename "$SELECTED_BACKUP")"
read -p "Are you sure? Type 'yes' to continue: " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Restore cancelled"
    exit 0
fi

# Stop services
echo ""
echo "🛑 Stopping services..."
cd "$PROJECT_DIR"
docker-compose down

# Extract backup
RESTORE_TEMP=$(mktemp -d)
echo "📂 Extracting backup..."
tar -xzf "$SELECTED_BACKUP" -C "$RESTORE_TEMP"

BACKUP_FOLDER=$(ls -1 "$RESTORE_TEMP" | head -1)
BACKUP_PATH="$RESTORE_TEMP/$BACKUP_FOLDER"

# Restore data
echo "💾 Restoring data..."

if [ -f "$BACKUP_PATH/backend.tar.gz" ]; then
    rm -rf "$PROJECT_DIR/data/backend"
    tar -xzf "$BACKUP_PATH/backend.tar.gz" -C "$PROJECT_DIR/data"
    echo -e "${GREEN}✅${NC} Backend data"
fi

if [ -f "$BACKUP_PATH/gateway.tar.gz" ]; then
    rm -rf "$PROJECT_DIR/data/gateway"
    tar -xzf "$BACKUP_PATH/gateway.tar.gz" -C "$PROJECT_DIR/data"
    echo -e "${GREEN}✅${NC} Gateway data"
fi

if [ -f "$BACKUP_PATH/core.tar.gz" ]; then
    rm -rf "$PROJECT_DIR/data/core"
    tar -xzf "$BACKUP_PATH/core.tar.gz" -C "$PROJECT_DIR/data"
    echo -e "${GREEN}✅${NC} Core data"
fi

if [ -f "$BACKUP_PATH/chroma.tar.gz" ]; then
    rm -rf "$PROJECT_DIR/data/chroma"
    tar -xzf "$BACKUP_PATH/chroma.tar.gz" -C "$PROJECT_DIR/data"
    echo -e "${GREEN}✅${NC} ChromaDB"
fi

# Restore config if exists
if [ -f "$BACKUP_PATH/.env.backup" ]; then
    echo "⚙️  Restoring .env..."
    cp "$BACKUP_PATH/.env.backup" "$PROJECT_DIR/.env.restored"
    echo -e "${YELLOW}⚠️  Restored .env saved as .env.restored - review before using${NC}"
fi

# Cleanup
rm -rf "$RESTORE_TEMP"

# Start services
echo ""
echo "▶️  Starting services..."
docker-compose up -d

echo ""
echo -e "${GREEN}✅ Restore complete!${NC}"
echo ""
echo -e "${YELLOW}🐾 MasterClaw has been restored to backup state.${NC}"
