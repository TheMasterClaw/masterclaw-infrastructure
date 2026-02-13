#!/bin/bash
# ssl-cert-check.sh - Monitor SSL certificate expiration dates
# This script checks certificate expiration for all MasterClaw domains

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default warning threshold (days)
WARNING_DAYS=14
CRITICAL_DAYS=7

# Show usage
usage() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  check       Check certificate expiration (default)"
    echo "  metrics     Output Prometheus metrics format"
    echo "  renew       Force certificate renewal"
    echo ""
    echo "Options:"
    echo "  -d, --domain <domain>  Check specific domain"
    echo "  -w, --warn <days>      Warning threshold (default: 14)"
    echo "  -c, --critical <days>  Critical threshold (default: 7)"
    echo "  -h, --help             Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 check                    # Check all domains"
    echo "  $0 check -d example.com     # Check specific domain"
    echo "  $0 metrics                  # Output for Prometheus"
    echo "  $0 renew                    # Force renewal"
}

# Load domain from .env if exists
load_domain() {
    if [ -f "$PROJECT_DIR/.env" ]; then
        export $(grep -v '^#' "$PROJECT_DIR/.env" | xargs 2>/dev/null || true)
    fi
    DOMAIN="${DOMAIN:-localhost}"
}

# Check certificate expiration for a domain
check_cert() {
    local domain=$1
    local port=${2:-443}
    
    # Get expiration date
    local expiry_date
    expiry_date=$(echo | openssl s_client -servername "$domain" -connect "$domain:$port" 2>/dev/null | \
        openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    
    if [ -z "$expiry_date" ]; then
        echo "ERROR"
        return 1
    fi
    
    # Convert to seconds since epoch
    local expiry_epoch
    expiry_epoch=$(date -d "$expiry_date" +%s 2>/dev/null || date -j -f "%b %d %H:%M:%S %Y %Z" "$expiry_date" +%s 2>/dev/null)
    
    local now_epoch
    now_epoch=$(date +%s)
    
    # Calculate days until expiry
    local days_until
    days_until=$(( (expiry_epoch - now_epoch) / 86400 ))
    
    echo "$days_until"
}

# Check all MasterClaw domains
check_all() {
    load_domain
    
    local domains=(
        "$DOMAIN"
        "api.$DOMAIN"
        "gateway.$DOMAIN"
        "core.$DOMAIN"
        "traefik.$DOMAIN"
    )
    
    echo -e "${BLUE}🔒 MasterClaw SSL Certificate Check${NC}"
    echo "====================================="
    echo ""
    echo -e "Warning threshold: ${YELLOW}${WARNING_DAYS} days${NC}"
    echo -e "Critical threshold: ${RED}${CRITICAL_DAYS} days${NC}"
    echo ""
    
    local healthy=0
    local warning=0
    local critical=0
    local error=0
    
    for domain in "${domains[@]}"; do
        # Skip localhost checks
        if [[ "$domain" == *"localhost"* ]]; then
            echo -e "  ${YELLOW}⚠️${NC}  $domain: ${YELLOW}Skipping localhost${NC}"
            continue
        fi
        
        printf "  Checking %-30s ... " "$domain"
        
        local days
        days=$(check_cert "$domain" 2>/dev/null || echo "ERROR")
        
        if [ "$days" == "ERROR" ]; then
            echo -e "${RED}ERROR${NC}"
            ((error++))
        elif [ "$days" -le "$CRITICAL_DAYS" ]; then
            echo -e "${RED}CRITICAL (${days} days)${NC}"
            ((critical++))
        elif [ "$days" -le "$WARNING_DAYS" ]; then
            echo -e "${YELLOW}WARNING (${days} days)${NC}"
            ((warning++))
        else
            echo -e "${GREEN}OK (${days} days)${NC}"
            ((healthy++))
        fi
    done
    
    echo ""
    echo "Summary:"
    echo -e "  ${GREEN}Healthy: $healthy${NC}"
    echo -e "  ${YELLOW}Warning: $warning${NC}"
    echo -e "  ${RED}Critical: $critical${NC}"
    echo -e "  ${RED}Errors: $error${NC}"
    echo ""
    
    if [ $critical -gt 0 ] || [ $error -gt 0 ]; then
        echo -e "${RED}🔴 ACTION REQUIRED: Some certificates need immediate attention!${NC}"
        return 1
    elif [ $warning -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Some certificates will expire soon. Plan renewal.${NC}"
        return 0
    else
        echo -e "${GREEN}✅ All certificates are healthy!${NC}"
        return 0
    fi
}

# Output Prometheus metrics
output_metrics() {
    load_domain
    
    local domains=(
        "$DOMAIN:main"
        "api.$DOMAIN:api"
        "gateway.$DOMAIN:gateway"
        "core.$DOMAIN:core"
        "traefik.$DOMAIN:traefik"
    )
    
    echo "# HELP masterclaw_ssl_cert_expiry_days Days until SSL certificate expires"
    echo "# TYPE masterclaw_ssl_cert_expiry_days gauge"
    
    for entry in "${domains[@]}"; do
        local domain="${entry%%:*}"
        local name="${entry##*:}"
        
        # Skip localhost
        if [[ "$domain" == *"localhost"* ]]; then
            echo "masterclaw_ssl_cert_expiry_days{domain=\"$domain\",service=\"$name\"} -1"
            continue
        fi
        
        local days
        days=$(check_cert "$domain" 2>/dev/null || echo "-1")
        echo "masterclaw_ssl_cert_expiry_days{domain=\"$domain\",service=\"$name\"} $days"
    done
    
    echo ""
    echo "# HELP masterclaw_ssl_cert_check_timestamp Unix timestamp of last check"
    echo "# TYPE masterclaw_ssl_cert_check_timestamp gauge"
    echo "masterclaw_ssl_cert_check_timestamp $(date +%s)"
}

# Force certificate renewal
renew_certs() {
    load_domain
    
    echo -e "${BLUE}🔄 Forcing certificate renewal...${NC}"
    echo ""
    
    cd "$PROJECT_DIR"
    
    # Restart Traefik to trigger renewal
    docker-compose restart traefik
    
    echo ""
    echo "Traefik restarted. Certificates will be renewed automatically."
    echo "Check status with: $0 check"
}

# Parse arguments
COMMAND="${1:-check}"
shift || true

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--domain)
            DOMAIN="$2"
            shift 2
            ;;
        -w|--warn)
            WARNING_DAYS="$2"
            shift 2
            ;;
        -c|--critical)
            CRITICAL_DAYS="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Execute command
case $COMMAND in
    check)
        check_all
        ;;
    metrics)
        output_metrics
        ;;
    renew)
        renew_certs
        ;;
    *)
        echo "Unknown command: $COMMAND"
        usage
        exit 1
        ;;
esac
