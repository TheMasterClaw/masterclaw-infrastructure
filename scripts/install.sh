#!/bin/bash
# install.sh - One-command installation for MasterClaw

set -e

REPO_URL="https://github.com/TheMasterClaw/masterclaw-infrastructure"
INSTALL_DIR="${INSTALL_DIR:-/opt/masterclaw}"

echo "🐾 MasterClaw Installer"
echo "======================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  Please run as root (use sudo)"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
else
    echo "❌ Cannot detect OS"
    exit 1
fi

echo "📋 Detected OS: $OS"
echo "📁 Install directory: $INSTALL_DIR"
echo ""

# Install prerequisites
echo "🔧 Installing prerequisites..."

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "  → Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "  → Installing Docker Compose..."
    apt-get update && apt-get install -y docker-compose-plugin
fi

# Install Git
if ! command -v git &> /dev/null; then
    echo "  → Installing Git..."
    apt-get install -y git
fi

# Clone repository
echo ""
echo "📥 Downloading MasterClaw..."
if [ -d "$INSTALL_DIR" ]; then
    echo "  → Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull
else
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Create data directories
echo ""
echo "📁 Creating directories..."
mkdir -p "$INSTALL_DIR/data"/{backend,core,gateway,chroma,letsencrypt,backups}

# Setup environment
echo ""
echo "⚙️  Configuration..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "  → Created .env file - PLEASE EDIT IT!"
fi

# Create systemd service
echo ""
echo "🔌 Creating systemd service..."
cat > /etc/systemd/system/masterclaw.service << EOF
[Unit]
Description=MasterClaw AI Familiar
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable masterclaw

# Install CLI
echo ""
echo "🛠️  Installing CLI..."
if [ -d "$INSTALL_DIR/../masterclaw-tools" ]; then
    cd "$INSTALL_DIR/../masterclaw-tools"
    npm install -g .
fi

# Firewall setup
echo ""
echo "🔒 Configuring firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Edit configuration: nano $INSTALL_DIR/.env"
echo "  2. Start MasterClaw: systemctl start masterclaw"
echo "  3. Check status: mc status"
echo ""
echo "🐾 MasterClaw is ready to awaken."
