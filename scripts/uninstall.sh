#!/bin/bash
# uninstall.sh - Remove MasterClaw from system

set -e

INSTALL_DIR="${INSTALL_DIR:-/opt/masterclaw}"

echo "🗑️  MasterClaw Uninstaller"
echo "=========================="
echo ""
echo "⚠️  WARNING: This will remove MasterClaw and all data!"
echo "   Installation directory: $INSTALL_DIR"
echo ""
read -p "Are you sure? Type 'uninstall' to continue: " CONFIRM

if [ "$CONFIRM" != "uninstall" ]; then
    echo "❌ Cancelled"
    exit 0
fi

echo ""
echo "🛑 Stopping services..."
systemctl stop masterclaw 2>/dev/null || true
systemctl disable masterclaw 2>/dev/null || true

# Stop Docker containers
if [ -f "$INSTALL_DIR/docker-compose.yml" ]; then
    echo "🐳 Stopping containers..."
    cd "$INSTALL_DIR"
    docker-compose down -v 2>/dev/null || true
fi

# Remove systemd service
echo "🔌 Removing systemd service..."
rm -f /etc/systemd/system/masterclaw.service
systemctl daemon-reload

# Remove installation directory
echo "🗑️  Removing files..."
read -p "Keep data directory for backups? (y/n): " KEEP_DATA

if [ "$KEEP_DATA" = "y" ]; then
    # Move data to backup location
    BACKUP_DIR="/root/masterclaw-data-backup-$(date +%Y%m%d)"
    mkdir -p "$BACKUP_DIR"
    mv "$INSTALL_DIR/data" "$BACKUP_DIR/" 2>/dev/null || true
    echo "  → Data backed up to: $BACKUP_DIR"
fi

rm -rf "$INSTALL_DIR"

echo ""
echo "✅ MasterClaw has been uninstalled"
echo ""

if [ "$KEEP_DATA" = "y" ]; then
    echo "📦 Your data is saved at: $BACKUP_DIR"
fi
