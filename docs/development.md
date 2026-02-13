# Development Guide

## Quick Start

```bash
# Clone all repos
for repo in masterclaw-infrastructure masterclaw-core masterclaw-tools rex-deus level100-studios; do
  git clone https://github.com/TheMasterClaw/$repo.git
done

# Start development environment
cd masterclaw-infrastructure
docker-compose -f docker-compose.dev.yml up -d

# Install CLI locally
cd ../masterclaw-tools
npm link
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    MasterClaw Stack                      │
├─────────────────────────────────────────────────────────┤
│  Interface (React)  ──────▶  Nginx                      │
│       │                                                 │
│       └───────────────────▶  Backend API (Node.js)      │
│                              │                          │
│       ┌──────────────────────┘                          │
│       ▼                                                 │
│  AI Core (FastAPI/Python)  ──▶  ChromaDB (Vectors)      │
│       │                                                 │
│       └───────────────────▶  OpenAI/Anthropic           │
├─────────────────────────────────────────────────────────┤
│  Gateway (OpenClaw)  ──────▶  WhatsApp/Telegram/etc     │
└─────────────────────────────────────────────────────────┘
```

## Development Workflow

1. **Make changes** in service directory
2. **Test locally** with dev compose
3. **Run tests**: `./scripts/test.sh`
4. **Commit** with descriptive message
5. **Push** and create PR if needed

## Adding Features

### New API Endpoint (Core)
1. Add to `masterclaw_core/main.py`
2. Add model to `masterclaw_core/models.py`
3. Add tests
4. Update README

### New CLI Command (Tools)
1. Create file in `lib/<command>.js`
2. Add to `bin/mc.js`
3. Document in README

### New Component (Level100)
1. Create component directory
2. Add JSX and CSS files
3. Export in `components/index.js`
4. Add to design tokens if needed

## Testing

```bash
# Unit tests
cd masterclaw-core && pytest
cd masterclaw-tools && npm test

# Integration tests
cd masterclaw-infrastructure && ./scripts/test.sh

# Manual testing
curl http://localhost:8000/health
curl -X POST http://localhost:8000/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello"}'
```

## Environment Variables

| Variable | Dev | Prod | Description |
|----------|-----|------|-------------|
| `NODE_ENV` | development | production | Runtime mode |
| `LOG_LEVEL` | debug | info | Logging verbosity |
| `OPENAI_API_KEY` | required | required | LLM access |
| `GATEWAY_TOKEN` | optional | required | Gateway auth |

## Debugging

```bash
# View logs
mc logs mc-backend --follow

# Shell into container
docker exec -it mc-backend sh

# Debug Python
python -m pdb masterclaw_core/main.py

# Debug Node
node --inspect-brk src/index.js
```

## Contributing

1. Branch from `main`
2. Make focused commits
3. Test thoroughly
4. Document changes
5. Submit PR

---

*Build with intention.* 🐾
