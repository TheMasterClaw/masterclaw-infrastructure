#!/bin/bash
# health-check.sh - Health monitoring for MasterClaw services

SERVICES=("interface:3000" "backend:3001" "gateway:3000")
FAILED=()

for service in "${SERVICES[@]}"; do
  IFS=':' read -r name port <<< "$service"
  
  if curl -sf "http://localhost:$port/health" > /dev/null 2>&1; then
    echo "✅ $name is healthy (port $port)"
  else
    echo "❌ $name is DOWN (port $port)"
    FAILED+=("$name")
  fi
done

if [ ${#FAILED[@]} -eq 0 ]; then
  echo ""
  echo "🐾 All services healthy. MasterClaw is watching."
  exit 0
else
  echo ""
  echo "⚠️  Failed services: ${FAILED[*]}"
  exit 1
fi
