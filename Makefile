.PHONY: help install dev prod stop logs status backup restore test clean

# Default target
help:
	@echo "🐾 MasterClaw Makefile"
	@echo "======================"
	@echo ""
	@echo "Setup:"
	@echo "  make install    - Install MasterClaw on this server"
	@echo "  make dev        - Start development environment"
	@echo "  make prod       - Deploy production stack"
	@echo ""
	@echo "Operations:"
	@echo "  make stop       - Stop all services"
	@echo "  make logs       - View logs (use ARGS="-f" to follow)"
	@echo "  make status     - Check service status"
	@echo "  make backup     - Create backup"
	@echo "  make restore    - Restore from backup"
	@echo "  make test       - Run tests"
	@echo ""
	@echo "Maintenance:"
	@echo "  make update     - Pull latest images"
	@echo "  make migrate    - Run database migrations"
	@echo "  make clean      - Remove containers and volumes"
	@echo "  make uninstall  - Remove MasterClaw completely"

# Installation
install:
	@echo "🔧 Installing MasterClaw..."
	@sudo ./scripts/install.sh

# Development environment
dev:
	@echo "🚀 Starting development environment..."
	@docker-compose -f docker-compose.dev.yml up -d
	@echo "✅ Dev environment running!"
	@echo "  Backend: http://localhost:3001"
	@echo "  Core: http://localhost:8000"

# Production deployment
prod:
	@echo "🚀 Deploying production stack..."
	@./scripts/deploy.sh

# Stop services
stop:
	@echo "🛑 Stopping services..."
	@docker-compose down

# View logs
logs:
	@docker-compose logs $(ARGS)

# Check status
status:
	@./scripts/health-check.sh

# Backup
backup:
	@./scripts/backup.sh

# Restore
restore:
	@./scripts/restore.sh

# Run tests
test:
	@./scripts/test.sh

# Update images
update:
	@echo "📥 Pulling latest images..."
	@docker-compose pull
	@docker-compose up -d

# Database migration
migrate:
	@./scripts/migrate.sh

# Clean up
clean:
	@echo "🧹 Cleaning up..."
	@docker-compose down -v --remove-orphans
	@docker system prune -f

# Uninstall
uninstall:
	@sudo ./scripts/uninstall.sh

# Monitoring stack
monitor:
	@echo "📊 Starting monitoring stack..."
	@docker-compose -f docker-compose.yml -f docker-compose.monitoring.yml up -d
	@echo "✅ Monitoring running!"
	@echo "  Prometheus: http://localhost:9090"
	@echo "  Grafana: http://localhost:3003"
