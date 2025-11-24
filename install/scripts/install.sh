#!/usr/bin/env bash
# NebulaCP Installer v0.9.0 – 100% Docker-Free
# Supports: Debian 12/13 – Rocky Linux 9 – AlmaLinux 9
set -e

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

echo "==========================================="
echo "  NebulaCP – Modern Control Panel"
echo "  Docker-Free Edition v0.9.0"
echo "==========================================="
echo ""
echo "Detected: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'\"' -f2)"
echo ""

# 1. Detect OS & set variables
if grep -q "ID=debian" /etc/os-release; then
    OS="debian"
    CODENAME=$(lsb_release -sc 2>/dev/null || echo "bookworm")
elif grep -q -E "ID=(rocky|almalinux)" /etc/os-release; then
    OS="rhel"
else
    echo "❌ Unsupported OS. Only Debian 12/13 and Rocky/AlmaLinux 9 supported."
    exit 1
fi

echo "📦 Detected OS: $OS"
echo ""

# 2. Basic system hardening first
echo "🔒 Hardening SSH and system..."
if [ -f /etc/ssh/sshd_config ]; then
    sed -i 's/#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd || systemctl restart ssh
fi

# 3. Install core dependencies
echo "📦 Installing core packages..."
if [[ $OS == "debian" ]]; then
    apt update && apt upgrade -y
    apt install -y curl wget gnupg2 lsb-release ca-certificates apt-transport-https \
                   software-properties-common nftables quota xfsprogs git sudo \
                   unzip tar cron build-essential
elif [[ $OS == "rhel" ]]; then
    dnf update -y
    dnf install -y epel-release dnf-automatic
    dnf install -y curl wget gnupg2 git sudo unzip tar cronie nftables quota \
                   policycoreutils-python-utils gcc gcc-c++ make
fi

# 4. Add official repositories
echo "📦 Adding Node.js 22, PostgreSQL 17, Caddy..."

# NodeSource
if [[ $OS == "debian" ]]; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
else
    curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
fi

# PostgreSQL
if [[ $OS == "debian" ]]; then
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
else
    dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
fi

# Caddy
if [[ $OS == "debian" ]]; then
    apt install -y debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
else
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/rpm.repo' | tee /etc/yum.repos.d/caddy-stable.repo
fi

# 5. Install everything
echo "📦 Installing Node.js, PostgreSQL, Redis, Caddy..."
if [[ $OS == "debian" ]]; then
    apt update
    apt install -y nodejs postgresql-17 redis caddy nginx
else
    dnf install -y nodejs postgresql17-server postgresql17 redis caddy nginx
    # Initialize PostgreSQL on RHEL
    /usr/pgsql-17/bin/postgresql-17-setup initdb
fi

# 6. Install rclone
echo "📦 Installing rclone..."
curl https://rclone.org/install.sh | bash

# 7. Install Ollama (optional AI feature)
echo "🤖 Installing Ollama for AI text generation..."
curl -fsSL https://ollama.com/install.sh | sh || echo "⚠️  Ollama installation failed (optional)"

# 8. Create nebula system user
echo "👤 Creating nebula system user..."
useradd -r -s /bin/false -d /usr/local/nebula nebula || true

# 9. Create directory structure
echo "📁 Creating directory structure..."
mkdir -p /usr/local/nebula/{backend,frontend,cli}
mkdir -p /var/log/nebula
mkdir -p /etc/nebula
chown -R nebula:nebula /usr/local/nebula
chown -R nebula:nebula /var/log/nebula

# 10. Download and install NebulaCP source (placeholder - use actual repo)
echo "📥 Downloading NebulaCP source code..."
cd /usr/local/nebula
# TODO: Replace with actual git clone when repo is ready
# git clone https://github.com/rhcsolutions/nebulacp.git .
echo "⚠️  Please manually clone the NebulaCP repository to /usr/local/nebula"
echo "   git clone https://github.com/rhcsolutions/nebulacp.git /usr/local/nebula"

# 11. Setup PostgreSQL database
echo "🗄️  Setting up PostgreSQL database..."
systemctl enable --now postgresql || systemctl enable --now postgresql-17
sleep 2

NEBULA_DB_PASSWORD=$(openssl rand -hex 16)
sudo -u postgres psql -c "CREATE DATABASE nebulacp;" 2>/dev/null || true
sudo -u postgres psql -c "CREATE USER nebulacp WITH PASSWORD '$NEBULA_DB_PASSWORD';" 2>/dev/null || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE nebulacp TO nebulacp;" 2>/dev/null || true

# Create .env file
cat > /etc/nebula/.env <<EOF
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://nebulacp:$NEBULA_DB_PASSWORD@localhost:5432/nebulacp
JWT_SECRET=$(openssl rand -hex 32)
FRONTEND_URL=https://$(hostname -I | awk '{print $1}')
OLLAMA_URL=http://127.0.0.1:11434
COMFYUI_URL=http://127.0.0.1:8188
EOF

chown nebula:nebula /etc/nebula/.env
chmod 600 /etc/nebula/.env

# 12. Install systemd services
echo "⚙️  Installing systemd services..."
# These will be created in the next step

# 13. Enable services
echo "🚀 Enabling services..."
systemctl enable --now redis || systemctl enable --now redis-server
systemctl enable --now caddy

# 14. Configure firewall
echo "🔥 Configuring firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 2222/tcp  # SSH alternative port
    ufw --force enable
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --permanent --add-port=2222/tcp
    firewall-cmd --reload
fi

echo ""
echo "✅ NebulaCP installation complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Clone the NebulaCP repository to /usr/local/nebula"
echo "   2. Install dependencies: cd /usr/local/nebula/apps/backend && npm install"
echo "   3. Run migrations: npm run prisma:migrate"
echo "   4. Start services: systemctl start nebula-backend nebula-frontend"
echo ""
echo "🔑 Database password saved to: /etc/nebula/.env"
echo "🌐 Access dashboard at: https://$(hostname -I | awk '{print $1}')"
echo ""
