#!/bin/bash
# deploy.sh - Deploy MasterClaw to production

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🐾 MasterClaw Deployment Script"
echo "================================"

# Check prerequisites
command -v docker >/dev/null 2>&1 || { echo "❌ Docker not installed"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "❌ Docker Compose not installed"; exit 1; }

# Load environment
if [ -f "$PROJECT_DIR/.env" ]; then
    echo "📋 Loading environment..."
    export $(grep -v '^#' "$PROJECT_DIR/.env" | xargs)
else
    echo "⚠️  No .env file found. Copy .env.example to .env and configure it."
    exit 1
fi

# Validate required variables
if [ -z "$DOMAIN" ]; then
    echo "❌ DOMAIN not set in .env"
    exit 1
fi

if [ -z "$GATEWAY_TOKEN" ]; then
    echo "❌ GATEWAY_TOKEN not set in .env"
    exit 1
fi

echo ""
echo "🚀 Deploying MasterClaw..."
echo "   Domain: $DOMAIN"
echo ""

# Create data directories
echo "📁 Creating data directories..."
mkdir -p "$PROJECT_DIR/data"/{backend,core,gateway,chroma,letsencrypt}

# Pull latest images
echo "📥 Pulling latest images..."
cd "$PROJECT_DIR"
docker-compose pull

# Build services
echo "🔨 Building services..."
docker-compose build --no-cache

# Start services
echo "▶️  Starting services..."
docker-compose up -d

# Wait for health checks
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check health
echo ""
echo "🏥 Health Check:"
"$SCRIPT_DIR/health-check.sh"

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Access your MasterClaw:"
echo "   Interface: https://$DOMAIN"
echo "   API:       https://api.$DOMAIN"
echo "   Gateway:   https://gateway.$DOMAIN"
echo "   Core:      https://core.$DOMAIN"
echo ""
echo "📊 Traefik Dashboard: https://traefik.$DOMAIN"
echo ""
echo "🐾 MasterClaw is awake and watching."
