#!/bin/bash
# logs-query.sh - Query logs from Loki via CLI

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

LOKI_URL="${LOKI_URL:-http://localhost:3100}"

show_help() {
    echo -e "${BLUE}🐾 MasterClaw Log Query${NC}"
    echo "======================="
    echo ""
    echo "Query logs from Loki log aggregation"
    echo ""
    echo "Usage:"
    echo "  ./logs-query.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  search <query>     Search logs with LogQL query"
    echo "  service <name>     Show logs for a specific service"
    echo "  errors             Show error logs only"
    echo "  tail               Follow logs in real-time"
    echo "  labels             List available labels"
    echo ""
    echo "Options:"
    echo "  --since <duration>  Time range (default: 1h, e.g., 5m, 24h, 7d)"
    echo "  --limit <n>         Maximum results (default: 100)"
    echo ""
    echo "Examples:"
    echo "  ./logs-query.sh service mc-core"
    echo "  ./logs-query.sh errors --since 24h"
    echo "  ./logs-query.sh search '{service=\"mc-core\"} |= \"error\"' --since 1h"
    echo "  ./logs-query.sh tail --service mc-backend"
    echo ""
}

# Default values
SINCE="1h"
LIMIT=100
SERVICE=""

# Parse arguments
COMMAND="${1:-}"
shift || true

while [[ $# -gt 0 ]]; do
    case $1 in
        --since)
            SINCE="$2"
            shift 2
            ;;
        --limit)
            LIMIT="$2"
            shift 2
            ;;
        --service)
            SERVICE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            # Collect remaining args as query
            QUERY="${QUERY} $1"
            shift
            ;;
    esac
done

# Convert duration to seconds for Loki API
duration_to_seconds() {
    local duration="$1"
    local num=$(echo "$duration" | sed 's/[^0-9]//g')
    local unit=$(echo "$duration" | sed 's/[0-9]//g')
    
    case "$unit" in
        m) echo $((num * 60)) ;;
        h) echo $((num * 3600)) ;;
        d) echo $((num * 86400)) ;;
        *) echo $num ;;
    esac
}

# Build time range
START=$(( $(date +%s) - $(duration_to_seconds "$SINCE") ))
END=$(date +%s)

# Check if Loki is accessible
check_loki() {
    if ! curl -s "$LOKI_URL/ready" > /dev/null 2>&1; then
        echo -e "${RED}❌ Loki is not accessible at $LOKI_URL${NC}"
        echo "   Is the monitoring stack running? Try: make monitor"
        exit 1
    fi
}

query_loki() {
    local query="$1"
    
    check_loki
    
    echo -e "${BLUE}🔍 Querying Loki...${NC}"
    echo -e "   Query: ${YELLOW}${query}${NC}"
    echo -e "   Since: ${SINCE}"
    echo -e "   Limit: ${LIMIT}"
    echo ""
    
    # URL encode the query
    local encoded_query=$(echo "$query" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))" 2>/dev/null || echo "$query")
    
    local response=$(curl -s "${LOKI_URL}/loki/api/v1/query_range?query=${encoded_query}&start=${START}000000000&end=${END}000000000&limit=${LIMIT}")
    
    # Check if response contains results
    if echo "$response" | grep -q '"result":\[\]'; then
        echo -e "${YELLOW}No logs found matching your query.${NC}"
        return
    fi
    
    # Parse and display results (requires jq)
    if command -v jq &> /dev/null; then
        echo "$response" | jq -r '.data.result[] | 
            .stream as $labels | 
            .values[] | 
            "\(.[0] | tonumber / 1000000000 | strftime("%Y-%m-%d %H:%M:%S")) \($labels.service // "unknown"): \(.[1])"'
    else
        # Fallback without jq
        echo "$response"
    fi
}

tail_logs() {
    local query="$1"
    
    check_loki
    
    echo -e "${BLUE}🔴 Tailing logs (Ctrl+C to exit)...${NC}"
    echo ""
    
    local encoded_query=$(echo "$query" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))" 2>/dev/null || echo "$query")
    
    # Use tail API
    curl -sN "${LOKI_URL}/loki/api/v1/tail?query=${encoded_query}&limit=${LIMIT}" 2>/dev/null | while read line; do
        if command -v jq &> /dev/null; then
            echo "$line" | jq -r '.streams[]?.values[]? | "\(.[0]): \(.[1])"' 2>/dev/null || true
        else
            echo "$line"
        fi
    done
}

# Execute command
case "$COMMAND" in
    search)
        QUERY=$(echo "$QUERY" | xargs)  # trim whitespace
        if [ -z "$QUERY" ]; then
            echo -e "${RED}Error: Search query is required${NC}"
            show_help
            exit 1
        fi
        query_loki "$QUERY"
        ;;
    service)
        if [ -z "$SERVICE" ] && [ -z "$QUERY" ]; then
            echo -e "${RED}Error: Service name is required${NC}"
            show_help
            exit 1
        fi
        SERVICE="${SERVICE:-$(echo "$QUERY" | xargs)}"
        query_loki "{service=\"${SERVICE}\"}"
        ;;
    errors)
        if [ -n "$SERVICE" ]; then
            query_loki "{service=\"${SERVICE}\"} |= \"error\" or \"ERROR\" or \"Error\""
        else
            query_loki "{job=\"docker\"} |= \"error\" or \"ERROR\" or \"Error\""
        fi
        ;;
    tail)
        if [ -n "$SERVICE" ]; then
            tail_logs "{service=\"${SERVICE}\"}"
        else
            tail_logs "{job=\"docker\"}"
        fi
        ;;
    labels)
        check_loki
        echo -e "${BLUE}📋 Available Labels:${NC}"
        curl -s "${LOKI_URL}/loki/api/v1/label" | jq -r '.data[]' 2>/dev/null || curl -s "${LOKI_URL}/loki/api/v1/label"
        ;;
    *)
        show_help
        exit 0
        ;;
esac
