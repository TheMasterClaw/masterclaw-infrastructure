# MasterClaw Infrastructure 🏗️

Infrastructure, deployment configs, Docker compose, SSL, and backup automation for the MasterClaw ecosystem.

## Quick Start

```bash
# Clone and enter
git clone https://github.com/TheMasterClaw/masterclaw-infrastructure.git
cd masterclaw-infrastructure

# Start everything
docker-compose up -d

# View logs
docker-compose logs -f
```

## What's Included

- **Docker Compose** — Full stack orchestration
- **Reverse Proxy** — Traefik with automatic SSL
- **Backup Scripts** — Automated daily backups
- **Monitoring** — Health checks and alerts
- **Deployment** — Scripts for Railway, AWS, VPS

## Architecture

```
┌─────────────────────────────────────────┐
│  Traefik (Reverse Proxy + SSL)          │
├─────────────────────────────────────────┤
│  MasterClaw Interface (Port 3000)       │
├─────────────────────────────────────────┤
│  MasterClaw Backend (Port 3001)         │
├─────────────────────────────────────────┤
│  OpenClaw Gateway (Port 3002)           │
├─────────────────────────────────────────┤
│  SQLite / PostgreSQL                    │
└─────────────────────────────────────────┘
```

## Repositories

- [masterclaw-interface](https://github.com/TheMasterClaw/MasterClawInterface) — The UI
- [masterclaw-core](https://github.com/TheMasterClaw/masterclaw-core) — The AI brain
- [masterclaw-tools](https://github.com/TheMasterClaw/masterclaw-tools) — CLI utilities
- [rex-deus](https://github.com/TheMasterClaw/rex-deus) — Personal configs (private)
- [level100-studios](https://github.com/TheMasterClaw/level100-studios) — Parent org

---

*Built for Rex. Powered by MasterClaw.* 🐾
