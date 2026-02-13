# MasterClaw Ecosystem 🐾

**The complete AI familiar infrastructure built for Rex deus.**

## Overview

This repository contains the deployment infrastructure. For the complete ecosystem, see:

| Repository | Purpose | Status |
|-----------|---------|--------|
| [MasterClawInterface](https://github.com/TheMasterClaw/MasterClawInterface) | React frontend | ✅ Active |
| [masterclaw-core](https://github.com/TheMasterClaw/masterclaw-core) | AI brain (FastAPI) | ✅ Active |
| [masterclaw-tools](https://github.com/TheMasterClaw/masterclaw-tools) | CLI utilities | ✅ Active |
| [rex-deus](https://github.com/TheMasterClaw/rex-deus) | Personal configs 🔒 | ✅ Active |
| [level100-studios](https://github.com/TheMasterClaw/level100-studios) | Design system | ✅ Active |
| **masterclaw-infrastructure** | **Deployment** | **✅ Active** |

## Quick Start

### One-Line Install
```bash
curl -fsSL https://raw.githubusercontent.com/TheMasterClaw/masterclaw-infrastructure/main/scripts/install.sh | sudo bash
```

### Manual Setup
```bash
# Clone
git clone https://github.com/TheMasterClaw/masterclaw-infrastructure.git
cd masterclaw-infrastructure

# Configure
cp .env.example .env
# Edit .env with your settings

# Deploy
make prod
# or: ./scripts/deploy.sh
```

## Commands

Use the Makefile for common operations:

```bash
make dev          # Start development environment
make prod         # Deploy production
make status       # Check health
make backup       # Create backup
make restore      # Restore from backup
make logs         # View logs
make logs-status  # Show log sizes and rotation
make logs-clean   # Clean up container logs
make test         # Run tests
make monitor      # Start monitoring stack
```

## Architecture

```
┌─────────────────────────────────────────────┐
│              Traefik (SSL/Proxy)            │
├─────────────────────────────────────────────┤
│  Interface │  Backend API  │  AI Core      │
│  (React)   │  (Node.js)    │  (Python)     │
├─────────────────────────────────────────────┤
│  Gateway   │  ChromaDB     │  SQLite/Redis │
│ (OpenClaw) │  (Vectors)    │  (Data)       │
├─────────────────────────────────────────────┤
│        Prometheus + Grafana (Monitoring)    │
└─────────────────────────────────────────────┘
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| Interface | 80/443 | React frontend |
| Backend API | 3001 | REST API |
| AI Core | 8000 | FastAPI + LLM routing |
| Gateway | 3000 | OpenClaw connection |
| ChromaDB | - | Vector database |
| Prometheus | 9090 | Metrics |
| Grafana | 3003 | Dashboards |

## Directory Structure

```
.
├── docker-compose.yml              # Production stack
├── docker-compose.dev.yml          # Development stack
├── docker-compose.monitoring.yml   # Monitoring stack
├── docker-compose.override.yml     # Dev overrides
├── Makefile                        # Common commands
├── scripts/                        # Automation scripts
│   ├── install.sh                 # One-line installer
│   ├── deploy.sh                  # Production deploy
│   ├── backup.sh                  # Backup data
│   ├── restore.sh                 # Restore data
│   ├── test.sh                    # Run tests
│   ├── migrate.sh                 # DB migrations
│   ├── health-check.sh            # Health check
│   ├── logs.sh                    # Log management
│   ├── setup.sh                   # Server setup
│   └── uninstall.sh               # Remove everything
├── services/                       # Service definitions
│   ├── interface/                 # Frontend Dockerfile
│   ├── backend/                   # Backend Dockerfile
│   └── core/                      # AI Core Dockerfile
├── monitoring/                     # Prometheus/Grafana config
└── docs/                          # Documentation
```

## Monitoring

Start monitoring stack:
```bash
make monitor
```

Access dashboards:
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3003 (admin/admin)

## Log Management

MasterClaw includes automatic log rotation to prevent disk space issues.

**View log status:**
```bash
make logs-status
# or: ./scripts/logs.sh status
# or: mc log status
```

**Clean up logs:**
```bash
make logs-clean
# or: ./scripts/logs.sh clean
# or: mc log clean
```

**Export logs:**
```bash
./scripts/logs.sh export [service]
# or: mc log export [service]
```

Log rotation settings (configured in `docker-compose.yml`):
| Service | Max Size | Max Files |
|---------|----------|-----------|
| traefik | 10MB | 5 |
| interface | 10MB | 3 |
| backend | 50MB | 5 |
| core | 50MB | 5 |
| gateway | 20MB | 3 |
| chroma | 10MB | 3 |
| watchtower | 5MB | 2 |

## Backup & Recovery

**Create backup:**
```bash
make backup
# or: ./scripts/backup.sh
```

**Restore:**
```bash
make restore
# or: ./scripts/restore.sh
```

Backups are stored in `./backups/` with automatic rotation.

## Development

See [docs/development.md](./docs/development.md) for detailed development guide.

```bash
# Start dev environment
make dev

# Run tests
make test

# View logs
make logs ARGS="-f mc-backend"
```

## Environment Variables

Copy `.env.example` to `.env` and configure:

| Variable | Required | Description |
|----------|----------|-------------|
| `DOMAIN` | ✅ | Your domain name |
| `ACME_EMAIL` | ✅ | For SSL certificates |
| `GATEWAY_TOKEN` | ✅ | OpenClaw gateway token |
| `OPENAI_API_KEY` | ⚠️ | For AI features |
| `ANTHROPIC_API_KEY` | ❌ | Alternative AI provider |

## Security

- Automatic SSL via Let's Encrypt
- Rate limiting on all endpoints
- Security headers applied
- No ports exposed except 80/443

## Support

- CLI: `mc help`
- Docs: See `docs/` directory
- Issues: GitHub Issues

---

*Built for Rex. Powered by MasterClaw.* 🐾
