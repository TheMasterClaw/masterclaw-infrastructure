#!/bin/bash
# test.sh - Run all tests for MasterClaw services

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🧪 MasterClaw Test Suite"
echo "========================"
echo ""

FAILED=0

# Test backend
echo "📦 Testing Backend..."
cd "$PROJECT_DIR/services/backend"
if [ -f "package.json" ]; then
    if npm test 2>/dev/null; then
        echo "✅ Backend tests passed"
    else
        echo "⚠️  Backend tests not configured or failed"
        FAILED=$((FAILED + 1))
    fi
else
    echo "⚠️  No backend tests found"
fi
echo ""

# Test core
echo "🧠 Testing Core..."
cd "$PROJECT_DIR/services/core"
if [ -f "requirements.txt" ]; then
    if command -v pytest >/dev/null 2>&1; then
        if pytest 2>/dev/null; then
            echo "✅ Core tests passed"
        else
            echo "⚠️  Core tests failed"
            FAILED=$((FAILED + 1))
        fi
    else
        echo "⚠️  pytest not installed"
    fi
else
    echo "⚠️  No core tests found"
fi
echo ""

# Test integration
echo "🔗 Testing Integration..."
cd "$PROJECT_DIR"

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services are running"
    
    # Test health endpoints
    for service in "http://localhost:3001/health:Backend" "http://localhost:8000/health:Core"; do
        IFS=':' read -r url name <<< "$service"
        if curl -sf "$url" >/dev/null 2>&1; then
            echo "✅ $name health check passed"
        else
            echo "❌ $name health check failed"
            FAILED=$((FAILED + 1))
        fi
    done
else
    echo "⚠️  Services not running - start with: docker-compose up -d"
fi
echo ""

# Summary
echo "========================"
if [ $FAILED -eq 0 ]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ $FAILED test(s) failed"
    exit 1
fi
