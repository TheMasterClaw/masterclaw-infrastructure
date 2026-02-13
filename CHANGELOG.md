# Changelog

All notable changes to the MasterClaw ecosystem.

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
