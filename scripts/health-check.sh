#!/bin/bash
# health-check.sh - Comprehensive health check for MasterClaw services

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🐾 MasterClaw Health Check${NC}"
echo "=========================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running${NC}"
    exit 1
fi

# Check container status
echo "📦 Container Status:"
echo ""
cd "$PROJECT_DIR"

SERVICES=("mc-traefik:traefik" "mc-interface:interface" "mc-backend:backend" "mc-core:core" "mc-gateway:gateway" "mc-chroma:chroma")
HEALTHY=0
UNHEALTHY=0

for service in "${SERVICES[@]}"; do
    IFS=':' read -r container name <<< "$service"
    
    STATUS=$(docker ps --filter "name=$container" --format "{{.Status}}" 2>/dev/null || echo "")
    
    if [ -n "$STATUS" ]; then
        if [[ "$STATUS" == *"healthy"* ]] || [[ "$STATUS" == *"Up"* ]]; then
            echo -e "  ${GREEN}✅${NC} $name: $STATUS"
            ((HEALTHY++))
        else
            echo -e "  ${YELLOW}⚠️${NC}  $name: $STATUS"
            ((UNHEALTHY++))
        fi
    else
        echo -e "  ${RED}❌${NC} $name: Not running"
        ((UNHEALTHY++))
    fi
done

echo ""

# Check endpoint health
if [ -f "$PROJECT_DIR/.env" ]; then
    export $(grep -v '^#' "$PROJECT_DIR/.env" | xargs)
fi

echo "🌐 Endpoint Checks:"
echo ""

ENDPOINTS=(
    "https://${DOMAIN:-localhost}:Interface"
    "https://api.${DOMAIN:-localhost}:API"
    "https://gateway.${DOMAIN:-localhost}:Gateway"
    "https://core.${DOMAIN:-localhost}:Core"
)

for endpoint in "${ENDPOINTS[@]}"; do
    IFS=':' read -r url name <<< "$endpoint"
    
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [ "$STATUS_CODE" == "200" ] || [ "$STATUS_CODE" == "301" ] || [ "$STATUS_CODE" == "302" ]; then
        echo -e "  ${GREEN}✅${NC} $name ($url): $STATUS_CODE"
        ((HEALTHY++))
    else
        echo -e "  ${RED}❌${NC} $name ($url): $STATUS_CODE"
        ((UNHEALTHY++))
    fi
done

echo ""
echo "📊 Summary:"
echo -e "  ${GREEN}Healthy: $HEALTHY${NC}"
echo -e "  ${RED}Unhealthy: $UNHEALTHY${NC}"
echo ""

if [ $UNHEALTHY -eq 0 ]; then
    echo -e "${GREEN}🐾 MasterClaw is healthy and watching.${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some services need attention.${NC}"
    exit 1
fi
