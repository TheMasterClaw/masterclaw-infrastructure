#!/bin/bash
# migrate.sh - Database migration script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🗄️  MasterClaw Database Migration"
echo "================================="
echo ""

# Check if running in Docker or locally
if [ -f "$PROJECT_DIR/.env" ]; then
    source "$PROJECT_DIR/.env"
fi

DB_PATH="${DATABASE_PATH:-$PROJECT_DIR/data/backend/mc.db}"
SCHEMA_PATH="$PROJECT_DIR/services/backend/schema.sql"

echo "Database: $DB_PATH"
echo "Schema: $SCHEMA_PATH"
echo ""

# Ensure directory exists
mkdir -p "$(dirname "$DB_PATH")"

# Apply schema
if [ -f "$SCHEMA_PATH" ]; then
    echo "📋 Applying schema..."
    sqlite3 "$DB_PATH" < "$SCHEMA_PATH"
    echo "✅ Schema applied"
else
    echo "❌ Schema file not found: $SCHEMA_PATH"
    exit 1
fi

# Show current tables
echo ""
echo "📊 Current tables:"
sqlite3 "$DB_PATH" ".tables"

echo ""
echo "✅ Migration complete"
