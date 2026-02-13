# MasterClaw Infrastructure

## 🚀 Quick Start

```bash
# 1. Clone and enter
git clone https://github.com/TheMasterClaw/masterclaw-infrastructure.git
cd masterclaw-infrastructure

# 2. Configure environment
cp .env.example .env
# Edit .env with your domain and tokens

# 3. Deploy
./scripts/deploy.sh

# 4. Check health
./scripts/health-check.sh
```

## 📁 Structure

```
.
├── docker-compose.yml          # Production stack
├── docker-compose.dev.yml      # Development stack
├── .env.example                # Configuration template
├── scripts/
│   ├── deploy.sh              # Deploy to production
│   ├── backup.sh              # Backup all data
│   ├── restore.sh             # Restore from backup
│   ├── setup.sh               # Initial server setup
│   └── health-check.sh        # Check service health
└── services/
    ├── interface/             # Frontend Dockerfile
    ├── backend/               # Backend Dockerfile
    └── core/                  # AI Core Dockerfile
```

## 🏗️ Services

| Service | Port | Description |
|---------|------|-------------|
| Traefik | 80, 443 | Reverse proxy with SSL |
| Interface | 80 | React frontend |
| Backend | 3001 | Node.js API |
| Core | 8000 | Python AI brain |
| Gateway | 3000 | OpenClaw gateway |
| Chroma | - | Vector database |

## 🔧 Scripts

### Deploy
```bash
./scripts/deploy.sh
```
Deploys the full stack with SSL certificates.

### Backup
```bash
./scripts/backup.sh
# Or with custom retention
BACKUP_DIR=/backups RETENTION_DAYS=30 ./scripts/backup.sh
```

### Restore
```bash
./scripts/restore.sh
```
Interactive restore from backup archives.

### Health Check
```bash
./scripts/health-check.sh
```
Checks all services and endpoints.

### Setup (new server)
```bash
./scripts/setup.sh
```
Installs Docker, Docker Compose, and configures firewall.

## 🌐 Domains

After deployment, access your services at:

- **Interface**: https://mc.yourdomain.com
- **API**: https://api.mc.yourdomain.com
- **Gateway**: https://gateway.mc.yourdomain.com
- **Core**: https://core.mc.yourdomain.com
- **Traefik Dashboard**: https://traefik.mc.yourdomain.com

## 🔄 Development

```bash
# Start development stack
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## 🔒 Security

- Automatic SSL via Let's Encrypt
- No ports exposed except 80/443
- Internal networking between services
- Firewall configured by setup.sh

## 📚 Related

- [MasterClawInterface](https://github.com/TheMasterClaw/MasterClawInterface) — The UI
- [masterclaw-core](https://github.com/TheMasterClaw/masterclaw-core) — AI brain
- [masterclaw-tools](https://github.com/TheMasterClaw/masterclaw-tools) — CLI

---

*Built for Rex. Powered by MasterClaw.* 🐾
