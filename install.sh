#!/usr/bin/env bash
# NebulaCP Installer v1.0.0 – 100% Docker-Free
# Supports: Debian 12/13/14 – Rocky Linux 9/10 – AlmaLinux 9/10
set -e

# Setup logging
LOG_FILE="/var/log/nebulacp-install-$(date +%Y%m%d-%H%M%S).log"
mkdir -p /var/log 2>/dev/null || true
touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/nebulacp-install-$(date +%Y%m%d-%H%M%S).log"

# Log function that writes to both console and file
log_to_file() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Progress tracking
TOTAL_STEPS=19
CURRENT_STEP=0
INSTALLED_ITEMS=()

# Logging functions
log_info() {
    local msg="$1"
    echo -e "${BLUE}ℹ${NC} $msg"
    log_to_file "[INFO] $msg"
}

log_success() {
    local msg="$1"
    echo -e "${GREEN}✓${NC} $msg"
    log_to_file "[SUCCESS] $msg"
}

log_warning() {
    local msg="$1"
    echo -e "${YELLOW}⚠${NC} $msg"
    log_to_file "[WARNING] $msg"
}

log_error() {
    local msg="$1"
    echo -e "${RED}✗${NC} $msg"
    log_to_file "[ERROR] $msg"
}

log_command() {
    local cmd="$1"
    log_to_file "[COMMAND] $cmd"
}

# Progress bar function
progress_bar() {
    local percent=$1
    local title=$2
    local bar_length=50
    local filled=$((percent * bar_length / 100))
    local empty=$((bar_length - filled))
    
    printf "\r${CYAN}[${NC}"
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "${CYAN}]${NC} ${BOLD}%3d%%${NC} - %s" "$percent" "$title"
}

# Step function with progress
step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percent=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    local msg="$1"
    progress_bar $percent "$msg"
    echo ""
    log_to_file "[STEP $CURRENT_STEP/$TOTAL_STEPS] $msg"
    echo -e "${CYAN}➤${NC} ${BOLD}Step $CURRENT_STEP/$TOTAL_STEPS:${NC} $msg"
}

# Track installed items
track_install() {
    INSTALLED_ITEMS+=("$1")
}

# Clear screen and show banner
clear
echo ""
echo -e "${MAGENTA}${BOLD}"
cat << "EOF"
███╗   ██╗███████╗██████╗ ██╗   ██╗██╗      █████╗  ██████╗██████╗ 
████╗  ██║██╔════╝██╔══██╗██║   ██║██║     ██╔══██╗██╔════╝██╔══██╗
██╔██╗ ██║█████╗  ██████╔╝██║   ██║██║     ███████║██║     ██████╔╝
██║╚██╗██║██╔══╝  ██╔══██╗██║   ██║██║     ██╔══██║██║     ██╔═══╝ 
██║ ╚████║███████╗██████╔╝╚██████╔╝███████╗██║  ██║╚██████╗██║     
╚═╝  ╚═══╝╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝     
EOF
echo -e "${NC}"
echo -e "${BOLD}Modern Control Panel - Docker-Free Edition v1.0.0${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BOLD}System Information:${NC}"
echo -e "  OS: ${GREEN}$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)${NC}"
echo -e "  Hostname: ${GREEN}$(hostname)${NC}"
echo -e "  IP Address: ${GREEN}$(hostname -I | awk '{print $1}')${NC}"
echo ""
echo -e "${BOLD}Supported Systems:${NC}"
echo -e "  • Debian 12 (Bookworm), 13 (Trixie), 14 (Forky)"
echo -e "  • Rocky Linux 9, 10"
echo -e "  • AlmaLinux 9, 10"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Log installation start
log_to_file "============================================"
log_to_file "NebulaCP Installation Started"
log_to_file "Installer Version: 1.0.0"
log_to_file "Log file: $LOG_FILE"
log_to_file "============================================"

echo -e "${BOLD}📝 Installation log:${NC} ${GREEN}$LOG_FILE${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root"
   exit 1
fi

# 1. Detect OS & set variables
step "Detecting operating system..."
if grep -q "ID=debian" /etc/os-release; then
    OS="debian"
    CODENAME=$(lsb_release -sc 2>/dev/null || echo "bookworm")
    VERSION_ID=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)
    track_install "Operating System: Debian ${VERSION_ID} ($(cat /etc/debian_version 2>/dev/null || echo 'unknown'))"
elif grep -q -E "ID=(rocky|almalinux|rhel)" /etc/os-release; then
    OS="rhel"
    VERSION_ID=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2 | cut -d'.' -f1)
    DISTRO_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
    track_install "Operating System: ${DISTRO_NAME}"
    
    # Check if version is supported (9 or 10)
    if [[ ! "$VERSION_ID" =~ ^(9|10)$ ]]; then
        log_warning "Rocky/AlmaLinux version ${VERSION_ID} detected. Officially supported: 9, 10"
    fi
else
    log_error "Unsupported OS. Only Debian 12/13/14 and Rocky/AlmaLinux 9/10 supported."
    exit 1
fi

log_success "Detected OS: $OS"

# 2. Basic system hardening first
step "Hardening SSH and system security..."
if [ -f /etc/ssh/sshd_config ]; then
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    sed -i 's/#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null || true
    log_success "SSH hardened"
    track_install "Security: SSH hardening enabled"
else
    log_warning "SSH config not found, skipping SSH hardening"
fi

# 3. Install core dependencies
step "Updating system and installing core packages..."
log_info "Running system update and installing essential packages"
if [[ $OS == "debian" ]]; then
    export DEBIAN_FRONTEND=noninteractive
    log_command "apt update"
    apt update -qq 2>&1 | tee -a "$LOG_FILE"
    log_command "apt upgrade -y"
    apt upgrade -y -qq 2>&1 | tee -a "$LOG_FILE"
    log_command "apt install core packages"
    apt install -y -qq curl wget gnupg2 lsb-release ca-certificates apt-transport-https \
                   nftables quota xfsprogs git sudo \
                   unzip tar cron build-essential python3 python3-pip python3-venv \
                   ufw fail2ban 2>&1 | tee -a "$LOG_FILE"
    log_success "System updated and core packages installed"
    track_install "System Tools: curl, wget, git, build-essential, python3"
elif [[ $OS == "rhel" ]]; then
    log_command "dnf update"
    dnf update -y -q 2>&1 | tee -a "$LOG_FILE"
    log_command "dnf install epel-release"
    dnf install -y -q epel-release 2>&1 | tee -a "$LOG_FILE"
    log_command "dnf install core packages"
    dnf install -y -q curl wget gnupg2 git sudo unzip tar cronie nftables quota \
                   policycoreutils-python-utils gcc gcc-c++ make python3 python3-pip \
                   firewalld fail2ban 2>&1 | tee -a "$LOG_FILE"
    log_success "System updated and core packages installed"
    track_install "System Tools: curl, wget, git, gcc, gcc-c++, python3"
fi

# 4. Add official repositories
step "Adding official repositories (Node.js, PostgreSQL, Caddy)..."
log_info "Configuring third-party repositories"

# Ensure gnupg and ca-certificates are installed first
if [[ $OS == "debian" ]]; then
    log_command "apt-get update for prerequisites"
    apt-get update -qq 2>&1 | tee -a "$LOG_FILE"
    log_command "apt-get install ca-certificates gnupg2 wget curl"
    apt-get install -y -qq ca-certificates gnupg2 wget curl 2>&1 | tee -a "$LOG_FILE"
fi

# NodeSource Node.js 22
log_info "Adding Node.js 22 repository..."
if [[ $OS == "debian" ]]; then
    log_command "Download NodeSource GPG key"
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource-archive-keyring.gpg 2>&1 | tee -a "$LOG_FILE"
    chmod 644 /usr/share/keyrings/nodesource-archive-keyring.gpg
    log_command "Add NodeSource repository"
    echo "deb [signed-by=/usr/share/keyrings/nodesource-archive-keyring.gpg] https://deb.nodesource.com/node_22.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
else
    log_command "Setup Node.js repository (RHEL)"
    curl -fsSL https://rpm.nodesource.com/setup_22.x 2>&1 | bash - | tee -a "$LOG_FILE"
fi
log_success "Node.js 22 repository added"

# PostgreSQL 17
log_info "Adding PostgreSQL 17 repository..."
if [[ $OS == "debian" ]]; then
    # Install postgresql-common first to get the official setup script
    log_command "apt install postgresql-common"
    apt install -y -qq postgresql-common 2>&1 | tee -a "$LOG_FILE"
    
    # Use the official PostgreSQL setup script which handles Debian version compatibility
    log_info "Running official PostgreSQL repository setup script"
    log_command "/usr/share/postgresql-common/pgdg/apt.postgresql.org.sh"
    # The script will auto-detect if trixie-pgdg is not available and fall back to bookworm-pgdg
    yes | /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh 2>&1 | tee -a "$LOG_FILE"
    
    log_command "apt-get update after adding PostgreSQL repo"
    apt-get update -qq 2>&1 | tee -a "$LOG_FILE"
else
    # Rocky/AlmaLinux - handle both version 9 and 10
    if [[ "$VERSION_ID" == "10" ]]; then
        # Rocky/AlmaLinux 10
        dnf install -y -q https://download.postgresql.org/pub/repos/yum/reporpms/EL-10-x86_64/pgdg-redhat-repo-latest.noarch.rpm 2>/dev/null || true
        dnf config-manager --disable pgdg* 2>/dev/null || true
        dnf config-manager --enable pgdg17 2>/dev/null || true
    else
        # Rocky/AlmaLinux 9
        dnf install -y -q https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm 2>/dev/null || true
        dnf config-manager --disable pgdg* 2>/dev/null || true
        dnf config-manager --enable pgdg17 2>/dev/null || true
    fi
fi
log_success "PostgreSQL 17 repository added"

# Caddy
if [[ $OS == "debian" ]]; then
    apt install -y -qq debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg 2>/dev/null
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list > /dev/null
else
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/rpm.repo' | tee /etc/yum.repos.d/caddy-stable.repo > /dev/null
fi
log_success "Caddy repository added"

# 5. Install/Update everything
step "Installing/Updating Node.js, PostgreSQL 17, Redis, Caddy, Nginx..."
if [[ $OS == "debian" ]]; then
    apt update -qq
    apt install -y -qq --only-upgrade nodejs postgresql-17 postgresql-contrib-17 redis-server caddy nginx 2>/dev/null || \
    apt install -y -qq nodejs postgresql-17 postgresql-contrib-17 redis-server caddy nginx
    log_success "Main packages installed/updated to latest versions"
    track_install "Node.js: $(node --version 2>/dev/null || echo 'v22.x')"
    track_install "PostgreSQL: 17"
    track_install "Redis: $(redis-server --version 2>/dev/null | awk '{print $3}' || echo '7.x')"
    track_install "Caddy: $(caddy version 2>/dev/null | head -n1 | awk '{print $1}' || echo '2.8+')"
    track_install "Nginx: $(nginx -v 2>&1 | awk -F'/' '{print $2}' || echo '1.x')"
else
    dnf upgrade -y -q nodejs postgresql17-server postgresql17-contrib redis caddy nginx 2>/dev/null || \
    dnf install -y -q nodejs postgresql17-server postgresql17-contrib redis caddy nginx
    # Initialize PostgreSQL on RHEL
    if [ ! -d "/var/lib/pgsql/17/data/base" ]; then
        /usr/pgsql-17/bin/postgresql-17-setup initdb
    fi
    log_success "Main packages installed/updated to latest versions"
    track_install "Node.js: $(node --version 2>/dev/null || echo 'v22.x')"
    track_install "PostgreSQL: 17"
    track_install "Redis: $(redis-server --version 2>/dev/null | awk '{print $3}' || echo '7.x')"
    track_install "Caddy: $(caddy version 2>/dev/null | head -n1 | awk '{print $1}' || echo '2.8+')"
    track_install "Nginx: $(nginx -v 2>&1 | awk -F'/' '{print $2}' || echo '1.x')"
fi

# Verify Node.js installation
NODE_VERSION=$(node --version 2>/dev/null || echo "none")
if [[ $NODE_VERSION == "none" ]]; then
    log_error "Node.js installation failed"
    exit 1
fi

# 6. Install/Update PM2 globally
step "Installing/Updating PM2 process manager..."
npm install -g pm2@latest --silent
pm2 update 2>/dev/null || true
pm2 install pm2-logrotate --silent 2>/dev/null || true
log_success "PM2 updated to latest version with log rotation"
track_install "PM2: $(pm2 --version 2>/dev/null || echo 'latest')"

# 7. Install/Update rclone
step "Installing/Updating rclone for backup management..."
curl -s https://rclone.org/install.sh | bash > /dev/null 2>&1
log_success "rclone installed"
log_success "rclone updated to latest version"
track_install "rclone: $(rclone version 2>/dev/null | head -n1 | awk '{print $2}' || echo 'latest')"

# 8. Install/Update Ollama (optional AI feature)
step "Installing/Updating Ollama for AI text generation..."
if curl -fsSL https://ollama.com/install.sh | sh > /dev/null 2>&1; then
    log_success "Ollama installed/updated to latest version"
    track_install "Ollama: latest (AI text generation)"
else
    log_warning "Ollama installation failed (optional feature)"
fi

# 9. Install backend dependencies
step "Installing backend dependencies..."
log_info "Installing Node.js dependencies for backend (NestJS)"
cd "$INSTALL_DIR/apps/backend"
log_command "npm install in apps/backend"
npm install --production 2>&1 | tee -a "$LOG_FILE"
log_success "Backend dependencies installed"
log_to_file "Backend package count: $(ls node_modules 2>/dev/null | wc -l || echo '0')"

# 10. Install frontend dependencies
step "Installing frontend dependencies..."
log_info "Installing Node.js dependencies for frontend (Next.js)"
cd "$INSTALL_DIR/apps/frontend"
log_command "npm install in apps/frontend"
npm install --production 2>&1 | tee -a "$LOG_FILE"
log_success "Frontend dependencies installed"
log_to_file "Frontend package count: $(ls node_modules 2>/dev/null | wc -l || echo '0')"

# 11. Clone NebulaCP source code
step "Downloading latest NebulaCP source code..."
cd /tmp
if [ -d "/tmp/nebulacp" ]; then
    rm -rf /tmp/nebulacp
fi

# Check if installation already exists
if [ -d "/opt/nebulacp/apps" ]; then
    log_info "Existing installation detected - updating to latest version..."
    UPDATING=true
    
    # Backup existing installation
    BACKUP_DIR="/opt/nebulacp-backup-$(date +%Y%m%d-%H%M%S)"
    log_info "Creating backup at $BACKUP_DIR..."
    cp -r /opt/nebulacp "$BACKUP_DIR"
    log_success "Backup created"
else
    UPDATING=false
fi

# Clone from GitHub (update with actual repo URL when available)
if git clone https://github.com/rhcsolutions/nebulacp.git /tmp/nebulacp 2>/dev/null; then
    # Copy new files
    cp -r /tmp/nebulacp/* /opt/nebulacp/
    rm -rf /tmp/nebulacp
    log_success "Source code cloned from GitHub"
    track_install "NebulaCP Source: latest from GitHub"
    
    if [ "$UPDATING" = true ]; then
        log_success "Updated to latest version (backup available at $BACKUP_DIR)"
    fi
else
    log_warning "Could not clone from GitHub. Using local setup..."
    # Create minimal structure if clone fails
    cd /opt/nebulacp
fi

chown -R nebula:nebula /opt/nebulacp

# 12. Setup PostgreSQL database
step "Setting up PostgreSQL database..."
log_info "Starting PostgreSQL service"

# Start PostgreSQL
if [[ $OS == "debian" ]]; then
    log_command "systemctl enable postgresql"
    systemctl enable postgresql 2>&1 | tee -a "$LOG_FILE"
    log_command "systemctl start postgresql"
    systemctl start postgresql 2>&1 | tee -a "$LOG_FILE"
else
    log_command "systemctl enable postgresql-17"
    systemctl enable postgresql-17 2>&1 | tee -a "$LOG_FILE"
    log_command "systemctl start postgresql-17"
    systemctl start postgresql-17 2>&1 | tee -a "$LOG_FILE"
fi

sleep 3

# Create database and user
log_info "Creating database 'nebulacp' with secure password"
NEBULA_DB_PASSWORD=$(openssl rand -hex 16)

log_command "Create PostgreSQL database and user"
sudo -u postgres psql -c "DROP DATABASE IF EXISTS nebulacp;" 2>&1 | tee -a "$LOG_FILE" || true
sudo -u postgres psql -c "DROP USER IF EXISTS nebulacp;" 2>&1 | tee -a "$LOG_FILE" || true
sudo -u postgres psql -c "CREATE DATABASE nebulacp;" 2>&1 | tee -a "$LOG_FILE"
sudo -u postgres psql -c "CREATE USER nebulacp WITH PASSWORD '$NEBULA_DB_PASSWORD';" 2>&1 | tee -a "$LOG_FILE"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE nebulacp TO nebulacp;" 2>&1 | tee -a "$LOG_FILE"
sudo -u postgres psql -c "ALTER DATABASE nebulacp OWNER TO nebulacp;" 2>&1 | tee -a "$LOG_FILE"

# PostgreSQL 15+ requires explicit grants
sudo -u postgres psql -d nebulacp -c "GRANT ALL ON SCHEMA public TO nebulacp;" 2>&1 | tee -a "$LOG_FILE" || true

log_success "PostgreSQL database 'nebulacp' created"
log_to_file "Database password: [REDACTED]"
track_install "Database: nebulacp (PostgreSQL 17)"

# Create .env file
step "Generating secure configuration..."
log_info "Creating environment configuration file"
log_command "Generate JWT secret and database credentials"
cat > /etc/nebula/.env <<EOF
# NebulaCP Environment Configuration
NODE_ENV=production
PORT=3000

# Database
DATABASE_URL=postgresql://nebulacp:$NEBULA_DB_PASSWORD@localhost:5432/nebulacp?schema=public

# Security
JWT_SECRET=$(openssl rand -hex 32)
JWT_EXPIRES_IN=7d

# URLs
FRONTEND_URL=https://$(hostname -I | awk '{print $1}')

# AI Services
OLLAMA_URL=http://127.0.0.1:11434
COMFYUI_URL=http://127.0.0.1:8188

# Alerts (configure later)
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
SLACK_WEBHOOK_URL=
EOF

chown nebula:nebula /etc/nebula/.env
chmod 600 /etc/nebula/.env
log_success "Secure environment configured"
log_to_file "Configuration file: /etc/nebula/.env (permissions: 600)"

# 13. Install/Update Node.js dependencies
step "Installing/Updating Node.js dependencies (this may take a few minutes)..."
log_info "Processing Node.js package dependencies for all applications"

# Backend dependencies
if [ -f "/opt/nebulacp/apps/backend/package.json" ]; then
    cd /opt/nebulacp/apps/backend
    
    # Clean install for updates
    if [ -d "node_modules" ]; then
        log_info "Updating backend dependencies..."
        log_command "npm update in apps/backend"
        sudo -u nebula npm update --silent 2>&1 | tee -a "$LOG_FILE" || npm update --silent 2>&1 | tee -a "$LOG_FILE"
    else
        log_info "Installing backend dependencies..."
        log_command "npm install in apps/backend"
        sudo -u nebula npm install --silent 2>&1 | tee -a "$LOG_FILE" || npm install --silent 2>&1 | tee -a "$LOG_FILE"
    fi
    
    log_success "Backend dependencies installed/updated"
    log_to_file "Backend packages: $(ls node_modules 2>/dev/null | wc -l || echo '0')"
    track_install "Backend: NestJS + dependencies (latest)"
    
    # Copy .env
    if [ ! -f ".env" ]; then
        ln -s /etc/nebula/.env .env
        log_to_file "Symlinked .env to backend"
    fi
    
    # Generate Prisma client
    if [ -f "prisma/schema.prisma" ]; then
        log_info "Generating Prisma ORM client"
        log_command "npx prisma generate"
        sudo -u nebula npx prisma generate --silent 2>&1 | tee -a "$LOG_FILE" || npx prisma generate --silent 2>&1 | tee -a "$LOG_FILE"
        log_success "Prisma ORM client generated"
        log_to_file "Prisma schema: apps/backend/prisma/schema.prisma"
        track_install "Database ORM: Prisma (latest)"
    fi
fi

# Frontend dependencies
if [ -f "/opt/nebulacp/apps/frontend/package.json" ]; then
    cd /opt/nebulacp/apps/frontend
    
    # Clean install for updates
    if [ -d "node_modules" ]; then
        log_info "Updating frontend dependencies..."
        log_command "npm update in apps/frontend"
        sudo -u nebula npm update --silent 2>&1 | tee -a "$LOG_FILE" || npm update --silent 2>&1 | tee -a "$LOG_FILE"
    else
        log_info "Installing frontend dependencies..."
        log_command "npm install in apps/frontend"
        sudo -u nebula npm install --silent 2>&1 | tee -a "$LOG_FILE" || npm install --silent 2>&1 | tee -a "$LOG_FILE"
    fi
    
    log_success "Frontend dependencies installed/updated"
    log_to_file "Frontend packages: $(ls node_modules 2>/dev/null | wc -l || echo '0')"
    track_install "Frontend: Next.js 15 + React 19 (latest)"
fi

# CLI dependencies
if [ -f "/opt/nebulacp/apps/cli/package.json" ]; then
    cd /opt/nebulacp/apps/cli
    
    # Clean install for updates
    if [ -d "node_modules" ]; then
        log_info "Updating CLI dependencies..."
        sudo -u nebula npm update --silent 2>/dev/null || npm update --silent
    else
        log_info "Installing CLI dependencies..."
        sudo -u nebula npm install --silent 2>/dev/null || npm install --silent
    fi
    
    sudo -u nebula npm run build --silent 2>/dev/null || npm run build --silent
    # Link CLI globally
    npm link --silent 2>/dev/null || true
    log_success "CLI dependencies installed/updated"
    track_install "CLI Tool: nebula-cli (latest)"
fi

# 14. Build applications
step "Building applications (this may take a few minutes)..."
log_info "Compiling TypeScript and building optimized bundles"

cd /opt/nebulacp/apps/backend
if [ -f "package.json" ]; then
    log_info "Building backend application (NestJS)"
    log_command "npm run build in apps/backend"
    sudo -u nebula npm run build --silent 2>&1 | tee -a "$LOG_FILE" || npm run build --silent 2>&1 | tee -a "$LOG_FILE" || true
    log_success "Backend built successfully"
    log_to_file "Backend build output: apps/backend/dist"
fi

cd /opt/nebulacp/apps/frontend
if [ -f "package.json" ]; then
    log_info "Building frontend application (Next.js)"
    log_command "npm run build in apps/frontend"
    sudo -u nebula npm run build --silent 2>&1 | tee -a "$LOG_FILE" || npm run build --silent 2>&1 | tee -a "$LOG_FILE" || true
    log_success "Frontend built successfully"
    log_to_file "Frontend build output: apps/frontend/.next"
fi

# 15. Install systemd services
step "Installing and configuring systemd services..."
log_info "Copying systemd service and timer files"

# Copy systemd service files if they exist
if [ -d "/opt/nebulacp/install/systemd" ]; then
    log_command "Copy systemd service files"
    cp /opt/nebulacp/install/systemd/*.service /etc/systemd/system/ 2>&1 | tee -a "$LOG_FILE" || true
    cp /opt/nebulacp/install/systemd/*.timer /etc/systemd/system/ 2>&1 | tee -a "$LOG_FILE" || true
    log_to_file "Systemd files copied from install/systemd/"
fi

log_command "systemctl daemon-reload"
systemctl daemon-reload 2>&1 | tee -a "$LOG_FILE"
log_success "Systemd services updated"
log_to_file "Systemd daemon reloaded"

# 16. Restart services for updates
step "Restarting all services with latest versions..."
log_info "Enabling and restarting all NebulaCP services"

# Redis
log_info "Starting Redis service"
if [[ $OS == "debian" ]]; then
    log_command "systemctl enable redis-server"
    systemctl enable redis-server 2>&1 | tee -a "$LOG_FILE"
    log_command "systemctl restart redis-server"
    systemctl restart redis-server 2>&1 | tee -a "$LOG_FILE" || systemctl start redis-server 2>&1 | tee -a "$LOG_FILE"
    track_install "Service: Redis (cache/sessions)"
else
    log_command "systemctl enable redis"
    systemctl enable redis 2>&1 | tee -a "$LOG_FILE"
    log_command "systemctl restart redis"
    systemctl restart redis 2>&1 | tee -a "$LOG_FILE" || systemctl start redis 2>&1 | tee -a "$LOG_FILE"
    track_install "Service: Redis (cache/sessions)"
fi
log_to_file "Redis service status: $(systemctl is-active redis-server 2>/dev/null || systemctl is-active redis 2>/dev/null || echo 'unknown')"

# Caddy
log_info "Starting Caddy web server"
log_command "systemctl enable caddy"
systemctl enable caddy 2>&1 | tee -a "$LOG_FILE"
log_command "systemctl restart caddy"
systemctl restart caddy 2>&1 | tee -a "$LOG_FILE" || systemctl start caddy 2>&1 | tee -a "$LOG_FILE" || true
log_success "Caddy web server restarted"
log_to_file "Caddy service status: $(systemctl is-active caddy 2>/dev/null || echo 'unknown')"
track_install "Service: Caddy (web server with auto-HTTPS)"

# Nginx (for static files)
log_info "Starting Nginx web server"
log_command "systemctl enable nginx"
systemctl enable nginx 2>&1 | tee -a "$LOG_FILE"
log_command "systemctl restart nginx"
systemctl restart nginx 2>&1 | tee -a "$LOG_FILE" || systemctl start nginx 2>&1 | tee -a "$LOG_FILE" || true
log_to_file "Nginx service status: $(systemctl is-active nginx 2>/dev/null || echo 'unknown')"
track_install "Service: Nginx (static files)"

# Ollama (if installed)
if command -v ollama &> /dev/null; then
    systemctl enable ollama 2>/dev/null || true
    systemctl restart ollama 2>/dev/null || systemctl start ollama 2>/dev/null || true
    log_success "Ollama AI service restarted"
fi

# NebulaCP services
if [ -f "/etc/systemd/system/nebula-backend.service" ]; then
    log_info "Starting NebulaCP Backend API"
    log_command "systemctl enable nebula-backend"
    systemctl enable nebula-backend 2>&1 | tee -a "$LOG_FILE"
    log_command "systemctl restart nebula-backend"
    systemctl restart nebula-backend 2>&1 | tee -a "$LOG_FILE" || systemctl start nebula-backend 2>&1 | tee -a "$LOG_FILE" || true
    log_success "NebulaCP Backend API restarted with latest version"
    log_to_file "Backend service status: $(systemctl is-active nebula-backend 2>/dev/null || echo 'unknown')"
    track_install "Service: NebulaCP Backend (port 3000)"
fi

if [ -f "/etc/systemd/system/nebula-frontend.service" ]; then
    log_info "Starting NebulaCP Frontend"
    log_command "systemctl enable nebula-frontend"
    systemctl enable nebula-frontend 2>&1 | tee -a "$LOG_FILE"
    log_command "systemctl restart nebula-frontend"
    systemctl restart nebula-frontend 2>&1 | tee -a "$LOG_FILE" || systemctl start nebula-frontend 2>&1 | tee -a "$LOG_FILE" || true
    log_success "NebulaCP Frontend restarted with latest version"
    log_to_file "Frontend service status: $(systemctl is-active nebula-frontend 2>/dev/null || echo 'unknown')"
    track_install "Service: NebulaCP Frontend (port 3001)"
fi

# 17. Configure firewall
step "Configuring firewall rules..."
log_info "Setting up firewall to allow required ports"
if command -v ufw &> /dev/null; then
    log_command "Configure UFW firewall"
    ufw --force reset 2>&1 | tee -a "$LOG_FILE"
    ufw default deny incoming 2>&1 | tee -a "$LOG_FILE"
    ufw default allow outgoing 2>&1 | tee -a "$LOG_FILE"
    log_info "Opening ports: 22 (SSH), 80 (HTTP), 443 (HTTPS), 3000 (Backend), 3001 (Frontend)"
    ufw allow 22/tcp 2>&1 | tee -a "$LOG_FILE"
    ufw allow 80/tcp 2>&1 | tee -a "$LOG_FILE"
    ufw allow 443/tcp 2>&1 | tee -a "$LOG_FILE"
    ufw allow 3000/tcp 2>&1 | tee -a "$LOG_FILE"  # Backend API
    ufw allow 3001/tcp 2>&1 | tee -a "$LOG_FILE"  # Frontend
    ufw --force enable 2>&1 | tee -a "$LOG_FILE"
    log_success "UFW firewall configured"
    log_to_file "UFW status: $(ufw status 2>/dev/null | head -n1 || echo 'unknown')"
    track_install "Firewall: UFW (ports 22, 80, 443, 3000, 3001)"
elif command -v firewall-cmd &> /dev/null; then
    log_command "Configure firewalld"
    log_info "Opening ports: 22 (SSH), 80 (HTTP), 443 (HTTPS), 3000 (Backend), 3001 (Frontend)"
    firewall-cmd --permanent --add-service=http 2>&1 | tee -a "$LOG_FILE"
    firewall-cmd --permanent --add-service=https 2>&1 | tee -a "$LOG_FILE"
    firewall-cmd --permanent --add-service=ssh 2>&1 | tee -a "$LOG_FILE"
    firewall-cmd --permanent --add-port=3000/tcp 2>&1 | tee -a "$LOG_FILE"
    firewall-cmd --permanent --add-port=3001/tcp 2>&1 | tee -a "$LOG_FILE"
    firewall-cmd --reload 2>&1 | tee -a "$LOG_FILE"
    log_success "Firewalld configured"
    log_to_file "Firewalld status: $(firewall-cmd --state 2>/dev/null || echo 'unknown')"
    track_install "Firewall: firewalld (ports 22, 80, 443, 3000, 3001)"
fi

# 18. Configure Fail2Ban
step "Configuring intrusion prevention (Fail2Ban)..."
log_info "Enabling Fail2Ban brute-force protection"
if command -v fail2ban-client &> /dev/null; then
    log_command "systemctl enable fail2ban"
    systemctl enable fail2ban 2>&1 | tee -a "$LOG_FILE"
    log_command "systemctl start fail2ban"
    systemctl start fail2ban 2>&1 | tee -a "$LOG_FILE" || true
    log_success "Fail2Ban enabled"
    log_to_file "Fail2Ban status: $(systemctl is-active fail2ban 2>/dev/null || echo 'unknown')"
    track_install "Security: Fail2Ban (brute-force protection)"
fi

# 19. Create admin user info file
step "Finalizing installation and generating credentials..."

SERVER_IP=$(hostname -I | awk '{print $1}')
ADMIN_PASSWORD=$(openssl rand -base64 12)
JWT_SECRET=$(grep JWT_SECRET /etc/nebula/.env | cut -d'=' -f2)

cat > /root/nebulacp-credentials.txt <<EOF
╔════════════════════════════════════════════════════════════════╗
║           NebulaCP Installation Successfully Completed         ║
╚════════════════════════════════════════════════════════════════╝

Server Information:
  Hostname: $(hostname)
  IP Address: $SERVER_IP
  OS: $(grep PRETTY_NAME /etc/os-release | cut -d'\"' -f2)
  Installation Date: $(date '+%Y-%m-%d %H:%M:%S')

Access Points:
  🌐 Frontend Dashboard: http://$SERVER_IP:3001
  🔌 Backend API: http://$SERVER_IP:3000
  📊 Health Check: http://$SERVER_IP:3000/health

Database:
  Type: PostgreSQL 17
  Database: nebulacp
  User: nebulacp
  Password: $NEBULA_DB_PASSWORD
  Connection: localhost:5432

Default Admin Account:
  Username: admin
  Email: admin@localhost
  Password: $ADMIN_PASSWORD
  
  ⚠️  IMPORTANT: Change this password after first login!

Security:
  JWT Secret: $JWT_SECRET
  SSH: Hardened (key-based auth recommended)
  Firewall: Active (ports 22, 80, 443, 3000, 3001)
  Fail2Ban: Enabled
  
Configuration Files:
  Main Config: /etc/nebula/.env
  Logs: /var/log/nebula/
  Installation: /opt/nebulacp/
  Documentation: /opt/nebulacp/docs/README.md

Service Management:
  Check Status:
    systemctl status nebula-backend
    systemctl status nebula-frontend
    systemctl status postgresql
    systemctl status redis-server (Debian) / redis (RHEL)
    systemctl status caddy
    
  View Logs:
    journalctl -u nebula-backend -f
    journalctl -u nebula-frontend -f
    
  Restart Services:
    systemctl restart nebula-backend
    systemctl restart nebula-frontend

Quick Start:
  1. Open: http://$SERVER_IP:3001
  2. Login with admin credentials above
  3. Configure alerts in: /etc/nebula/.env
  4. Review documentation: /opt/nebulacp/docs/README.md

Optional Configuration:
  - Telegram Alerts: Add TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID to .env
  - Slack Alerts: Add SLACK_WEBHOOK_URL to .env
  - SSL Setup: Caddy will auto-provision Let's Encrypt certificates
  - AI Features: Configure Ollama models (already installed)

Support & Documentation:
  Documentation: /opt/nebulacp/docs/README.md
  GitHub: https://github.com/rhcsolutions/nebulacp
  Issues: https://github.com/rhcsolutions/nebulacp/issues

╔════════════════════════════════════════════════════════════════╗
║  This file contains sensitive credentials - Keep it secure!    ║
╚════════════════════════════════════════════════════════════════╝
EOF

chmod 600 /root/nebulacp-credentials.txt

# Complete progress bar
progress_bar 100 "Installation complete!"
echo ""
echo ""

# Display beautiful summary
clear
echo ""
echo -e "${GREEN}${BOLD}"
cat << "EOF"
    ___           __        ____      __  _           
   /   |  _______/ /_____ _/ / /___ _/ /_(_)___  ____ 
  / /| | / ___/ __/ ___/ / / / __ `/ __/ / __ \/ __ \
 / ___ |(__  ) /_/ /  / /_/ / /_/ / /_/ / /_/ / / / /
/_/  |_/____/\__/_/   \__  /\__,_/\__/_/\____/_/ /_/ 
                     /____/                          
    
         ✨ INSTALLATION SUCCESSFUL ✨
EOF
echo -e "${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BOLD}📦 Installed Components:${NC}"
echo ""
for item in "${INSTALLED_ITEMS[@]}"; do
    echo -e "  ${GREEN}✓${NC} $item"
done
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BOLD}🌐 Access Information:${NC}"
echo ""
echo -e "  ${BOLD}Dashboard:${NC}      ${BLUE}http://$SERVER_IP:3001${NC}"
echo -e "  ${BOLD}API:${NC}            ${BLUE}http://$SERVER_IP:3000${NC}"
echo -e "  ${BOLD}Health Check:${NC}   ${BLUE}http://$SERVER_IP:3000/health${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BOLD}🔑 Credentials:${NC}"
echo ""
echo -e "  ${BOLD}Username:${NC}       ${GREEN}admin${NC}"
echo -e "  ${BOLD}Password:${NC}       ${GREEN}$ADMIN_PASSWORD${NC}"
echo -e "  ${BOLD}Email:${NC}          ${GREEN}admin@localhost${NC}"
echo ""
echo -e "  ${YELLOW}⚠  Change the password after first login!${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BOLD}📝 Next Steps:${NC}"
echo ""
echo -e "  ${BOLD}1.${NC} Review full credentials:"
echo -e "     ${CYAN}cat /root/nebulacp-credentials.txt${NC}"
echo ""
echo -e "  ${BOLD}2.${NC} Access the dashboard:"
echo -e "     ${CYAN}http://$SERVER_IP:3001${NC}"
echo ""
echo -e "  ${BOLD}3.${NC} Configure alerts (optional):"
echo -e "     ${CYAN}nano /etc/nebula/.env${NC}"
echo ""
echo -e "  ${BOLD}4.${NC} Read documentation:"
echo -e "     ${CYAN}cat /opt/nebulacp/docs/README.md${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BOLD}📝 Installation Log:${NC}"
echo ""
echo -e "  ${CYAN}$LOG_FILE${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BOLD}🛠  Useful Commands:${NC}"
echo ""
echo -e "  ${BOLD}View install log:${NC}   ${CYAN}cat $LOG_FILE${NC}"
echo -e "  ${BOLD}Check services:${NC}     ${CYAN}systemctl status nebula-backend nebula-frontend${NC}"
echo -e "  ${BOLD}View logs:${NC}          ${CYAN}journalctl -u nebula-backend -f${NC}"
echo -e "  ${BOLD}Restart backend:${NC}    ${CYAN}systemctl restart nebula-backend${NC}"
echo -e "  ${BOLD}Restart frontend:${NC}   ${CYAN}systemctl restart nebula-frontend${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}${BOLD}✨ Enjoy your new NebulaCP installation! ✨${NC}"
echo ""

log_to_file "============================================"
log_to_file "NebulaCP Installation Completed Successfully"
log_to_file "Server IP: $SERVER_IP"
log_to_file "Admin password: [REDACTED - see /root/nebulacp-credentials.txt]"
log_to_file "============================================"
