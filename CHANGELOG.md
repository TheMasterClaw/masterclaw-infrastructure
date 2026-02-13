# Changelog

All notable changes to the MasterClaw ecosystem.

## [0.4.0] - 2026-02-13

### Added
- **SSL Certificate Monitoring** - Prevent production outages from expired certificates
  - New `scripts/ssl-cert-check.sh` - Check certificate expiration
  - Prometheus alert rules for certificate expiration (14-day warning, 7-day critical)
  - New CLI commands: `mc ssl check`, `mc ssl status`, `mc ssl metrics`, `mc ssl renew`
  - New Makefile target: `make ssl-check`
  - Supports custom warning/critical thresholds
  - Automatic detection of all MasterClaw domains (main, api, gateway, core, traefik)
  - Prometheus metrics output for monitoring integration
  - Force renewal capability via Traefik restart

### Infrastructure
- Enhanced Prometheus alerting with SSL certificate expiration rules
- SSL certificate metrics integration with existing monitoring stack

## [0.3.0] - 2026-02-13

### Added
- **Log Aggregation with Loki** - Centralized, searchable log storage
  - Grafana Loki for log aggregation and storage
  - Promtail for container log shipping
  - 30-day log retention with configurable limits
  - Integrated with Grafana (datasource + dashboard)
  - New `scripts/logs-query.sh` for CLI log queries
  - New Makefile target: `make logs-query`
  - Query logs by service, time range, or content
  - Real-time log tailing via CLI
  - Error log filtering
  - Log volume visualization in Grafana

### Infrastructure
- Extended monitoring stack with Loki + Promtail
- Pre-configured Grafana datasource for Loki
- New "MasterClaw Logs" dashboard with:
  - Live log stream viewer
  - Log volume by service over time
  - Error rate visualization
- All MasterClaw container logs automatically collected


## [0.2.1] - 2026-02-13

### Added
- **Log Rotation** - Automatic Docker log rotation to prevent disk space issues
  - Configured per-service limits (5-50MB, 2-5 files)
  - New `scripts/logs.sh` for log management
  - New CLI commands: `mc log status`, `mc log clean`, `mc log export`
  - New Makefile targets: `make logs-status`, `make logs-clean`
- **Log Management Features**:
  - View log sizes and rotation status
  - Clean up container logs safely
  - Export logs for debugging
  - Disk usage warnings

### Infrastructure
- Added `logging` configuration to all Docker Compose services
- Prevents production outages from runaway logs

## [0.2.0] - 2026-02-13

### Added
- **Memory Backup System** - Automatic backups and recovery
- **Monitoring Stack** - Prometheus + Grafana integration
- **Rate Limiting** - Request throttling and abuse prevention
- **Request Logging** - Comprehensive access logs
- **Security Headers** - Enhanced security middleware
- **WebSocket Support** - Real-time bidirectional communication
- **CLI Enhancements**:
  - `mc memory` commands (backup, restore, search)
  - `mc task` commands (list, add, done)
  - `mc heal` - Self-diagnosis
  - `mc doctor` - Full diagnostics
  - `mc chat` - Quick chat
  - `mc export` - Data export
- **Makefile** - Easy command shortcuts
- **Install Script** - One-line installation
- **Uninstall Script** - Clean removal
- **API Documentation** - Complete endpoint reference
- **Contributing Guide** - Developer contribution guide

### Changed
- Improved error handling with custom exceptions
- Enhanced health checks with detailed status
- Better Docker Compose organization
- Updated all documentation

### Security
- Added rate limiting (60 req/min)
- Security headers on all responses
- API key authentication support

## [0.1.0] - 2026-02-13

### Added
- Initial release of MasterClaw ecosystem
- **Infrastructure**:
  - Docker Compose production stack
  - Traefik reverse proxy with SSL
  - Automated backup scripts
  - Deployment automation
  - CI/CD with GitHub Actions
- **Core AI Brain**:
  - FastAPI application
  - LLM router (OpenAI + Anthropic)
  - Memory store (ChromaDB + JSON)
  - Chat endpoints with streaming
  - Memory search and management
- **CLI Tools**:
  - `mc status` - Health monitoring
  - `mc logs` - Log viewer
  - `mc backup` - Backup trigger
  - `mc config` - Configuration
  - `mc revive` - Service restart
  - `mc update` - Update check
- **Personal Configs**:
  - Multiple persona prompts
  - Context files (preferences, projects, etc.)
  - Session notes template
- **Design System**:
  - React components (Button, Card, Input, Avatar)
  - Design tokens (colors, typography, spacing)
  - Brand guidelines
- **5 GitHub Repositories**:
  - masterclaw-infrastructure
  - masterclaw-core
  - masterclaw-tools
  - rex-deus
  - level100-studios

---

*MasterClaw evolves.* 🐾
