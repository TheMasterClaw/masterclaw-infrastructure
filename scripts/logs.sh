#!/bin/bash
# logs.sh - Log management utility for MasterClaw
# Handles log size monitoring, cleanup, and rotation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Container name mappings
CONTAINERS=(
  "mc-traefik:traefik"
  "mc-interface:interface"
  "mc-backend:backend"
  "mc-core:core"
  "mc-gateway:gateway"
  "mc-chroma:chroma"
  "mc-watchtower:watchtower"
)

# Show usage
usage() {
  echo -e "${BLUE}🐾 MasterClaw Log Manager${NC}"
  echo ""
  echo "Usage: $0 [command]"
  echo ""
  echo "Commands:"
  echo "  status        Show log sizes and rotation status"
  echo "  clean         Remove all container logs (keeps containers running)"
  echo "  clean-all     Remove logs and prune unused Docker data"
  echo "  rotate        Force log rotation on all containers"
  echo "  export [svc]  Export logs for a service to ./logs-export/"
  echo ""
  echo "Examples:"
  echo "  $0 status"
  echo "  $0 clean"
  echo "  $0 export backend"
  echo ""
}

# Get container log size
get_log_size() {
  local container=$1
  docker inspect --format='{{.LogPath}}' "$container" 2>/dev/null | xargs -I {} sh -c 'ls -lh {} 2>/dev/null | awk "{print \$5}"' || echo "0B"
}

# Get container status
get_container_status() {
  local container=$1
  docker ps --filter "name=$container" --format "{{.Status}}" 2>/dev/null || echo "stopped"
}

# Calculate total log size
calculate_total_size() {
  local total=0
  for mapping in "${CONTAINERS[@]}"; do
    IFS=':' read -r container name <<< "$mapping"
    size=$(docker inspect --format='{{.LogPath}}' "$container" 2>/dev/null | xargs stat -f%z 2>/dev/null || echo "0")
    total=$((total + size))
  done
  echo "$total"
}

# Format bytes to human readable
format_size() {
  local bytes=$1
  if [ "$bytes" -lt 1024 ]; then
    echo "${bytes}B"
  elif [ "$bytes" -lt 1048576 ]; then
    echo "$(echo "scale=1; $bytes/1024" | bc)KB"
  elif [ "$bytes" -lt 1073741824 ]; then
    echo "$(echo "scale=1; $bytes/1048576" | bc)MB"
  else
    echo "$(echo "scale=1; $bytes/1073741824" | bc)GB"
  fi
}

# Show log status
show_status() {
  echo -e "${BLUE}📊 MasterClaw Log Status${NC}"
  echo "========================"
  echo ""
  
  printf "%-20s %-10s %-15s %-20s\n" "Service" "Status" "Log Size" "Log Config"
  printf "%-20s %-10s %-15s %-20s\n" "-------" "------" "--------" "----------"
  
  total_bytes=0
  for mapping in "${CONTAINERS[@]}"; do
    IFS=':' read -r container name <<< "$mapping"
    
    status=$(get_container_status "$container")
    if [[ "$status" == *"Up"* ]]; then
      status_icon="${GREEN}●${NC}"
    else
      status_icon="${RED}○${NC}"
    fi
    
    size=$(docker inspect --format='{{.LogPath}}' "$container" 2>/dev/null | xargs stat -f%z 2>/dev/null || echo "0")
    total_bytes=$((total_bytes + size))
    size_human=$(format_size "$size")
    
    # Get log config
    log_driver=$(docker inspect --format='{{.HostConfig.LogConfig.Type}}' "$container" 2>/dev/null || echo "-")
    max_size=$(docker inspect --format='{{.HostConfig.LogConfig.Config.max-size}}' "$container" 2>/dev/null || echo "-")
    max_file=$(docker inspect --format='{{.HostConfig.LogConfig.Config.max-file}}' "$container" 2>/dev/null || echo "-")
    
    if [ "$log_driver" == "json-file" ]; then
      config="${max_size}/${max_file}f"
    else
      config="$log_driver"
    fi
    
    printf "%-20b %-10b %-15s %-20s\n" "$name" "$status_icon" "$size_human" "$config"
  done
  
  echo ""
  total_human=$(format_size "$total_bytes")
  echo -e "Total log size: ${CYAN}$total_human${NC}"
  echo ""
  
  # Disk usage warning
  docker_root=$(docker info --format '{{.DockerRootDir}}' 2>/dev/null || echo "/var/lib/docker")
  if [ -d "$docker_root" ]; then
    available=$(df -h "$docker_root" 2>/dev/null | awk 'NR==2 {print $4}' || echo "?")
    usage_pct=$(df -h "$docker_root" 2>/dev/null | awk 'NR==2 {print $5}' || echo "?")
    echo -e "Docker root: ${CYAN}$docker_root${NC}"
    echo -e "Disk available: ${CYAN}$available${NC} (${usage_pct} used)"
    
    # Warning if disk usage is high
    usage_num=$(echo "$usage_pct" | tr -d '%')
    if [ "$usage_num" -gt 85 ] 2>/dev/null; then
      echo -e "${YELLOW}⚠️  Warning: Disk usage is above 85%${NC}"
      echo -e "${YELLOW}   Consider running: $0 clean${NC}"
    fi
  fi
  echo ""
}

# Clean container logs
clean_logs() {
  echo -e "${BLUE}🧹 Cleaning MasterClaw logs...${NC}"
  echo ""
  
  cleaned=0
  for mapping in "${CONTAINERS[@]}"; do
    IFS=':' read -r container name <<< "$mapping"
    
    if docker ps -q --filter "name=$container" | grep -q .; then
      # Get log path and truncate
      log_path=$(docker inspect --format='{{.LogPath}}' "$container" 2>/dev/null)
      if [ -n "$log_path" ] && [ -f "$log_path" ]; then
        size_before=$(stat -f%z "$log_path" 2>/dev/null || echo "0")
        sudo sh -c "> '$log_path'" 2>/dev/null && {
          echo -e "  ${GREEN}✅${NC} Cleared logs for $name"
          cleaned=$((cleaned + 1))
        } || {
          echo -e "  ${YELLOW}⚠️${NC} Could not clear $name (may need sudo)"
        }
      else
        echo -e "  ${YELLOW}⚠️${NC} No log file for $name"
      fi
    else
      echo -e "  ${RED}❌${NC} $name is not running"
    fi
  done
  
  echo ""
  echo -e "${GREEN}✅ Cleaned $cleaned service log(s)${NC}"
  echo ""
}

# Clean all including Docker system
clean_all() {
  echo -e "${YELLOW}⚠️  This will remove all logs AND prune Docker system data${NC}"
  echo -e "${YELLOW}   (images, containers, networks, build cache)${NC}"
  echo ""
  read -p "Are you sure? [y/N] " -n 1 -r
  echo ""
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    clean_logs
    echo ""
    echo -e "${BLUE}🗑️  Pruning Docker system...${NC}"
    docker system prune -f --volumes
    echo ""
    echo -e "${GREEN}✅ Cleanup complete${NC}"
  else
    echo "Cancelled."
  fi
  echo ""
}

# Force log rotation
rotate_logs() {
  echo -e "${BLUE}🔄 Forcing log rotation...${NC}"
  echo ""
  
  # Signal containers to reopen log files
  for mapping in "${CONTAINERS[@]}"; do
    IFS=':' read -r container name <<< "$mapping"
    
    if docker ps -q --filter "name=$container" | grep -q .; then
      # Send USR1 signal to reopen logs (if supported by app)
      docker kill --signal="USR1" "$container" 2>/dev/null && {
        echo -e "  ${GREEN}✅${NC} Signaled $name to rotate logs"
      } || {
        echo -e "  ${YELLOW}⚠️${NC} $name (signal not supported)"
      }
    else
      echo -e "  ${RED}❌${NC} $name is not running"
    fi
  done
  
  echo ""
  echo -e "${GREEN}✅ Rotation signals sent${NC}"
  echo ""
}

# Export logs
export_logs() {
  local service=$1
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local export_dir="./logs-export/${timestamp}"
  
  mkdir -p "$export_dir"
  
  if [ -n "$service" ]; then
    # Export specific service
    container="mc-$service"
    echo -e "${BLUE}📦 Exporting logs for $service...${NC}"
    
    if docker ps -q --filter "name=$container" | grep -q .; then
      docker logs "$container" > "$export_dir/${service}.log" 2>&1
      docker inspect "$container" > "$export_dir/${service}_inspect.json" 2>/dev/null
      echo -e "${GREEN}✅ Exported to $export_dir/${service}.log${NC}"
    else
      echo -e "${RED}❌ $service is not running${NC}"
    fi
  else
    # Export all
    echo -e "${BLUE}📦 Exporting all logs...${NC}"
    for mapping in "${CONTAINERS[@]}"; do
      IFS=':' read -r container name <<< "$mapping"
      
      if docker ps -q --filter "name=$container" | grep -q .; then
        docker logs "$container" > "$export_dir/${name}.log" 2>&1
        echo -e "  ${GREEN}✅${NC} $name"
      else
        echo -e "  ${RED}❌${NC} $name (not running)"
      fi
    done
    echo ""
    echo -e "${GREEN}✅ All logs exported to $export_dir/${NC}"
  fi
  echo ""
}

# Main command handler
case "${1:-status}" in
  status)
    show_status
    ;;
  clean)
    clean_logs
    ;;
  clean-all)
    clean_all
    ;;
  rotate)
    rotate_logs
    ;;
  export)
    export_logs "$2"
    ;;
  help|--help|-h)
    usage
    ;;
  *)
    echo -e "${RED}Unknown command: $1${NC}"
    echo ""
    usage
    exit 1
    ;;
esac
