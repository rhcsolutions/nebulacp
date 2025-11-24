# NebulaCP - Modern Open-Source Control Panel & CMS

![NebulaCP Logo](docs/logo.png)

**Project Codename:** NebulaCP  
**Version:** 0.9.0 (Beta)  
**License:** AGPL-3.0  

A spiritual successor to HestiaCP / Virtualmin but built from the ground up with 2025-era technologies.

## 🚀 Features

### Control Panel + CMS
- **100% Docker-Free** - Native installation on Debian 12/13 & Rocky Linux 9
- **Multi-Website Management** - Host unlimited domains with SSL auto-renewal
- **AI-Powered** - Built-in text generation (Ollama) and image generation (ComfyUI)
- **Modern UI** - Next.js 15 + React 19 + Tailwind CSS + Shadcn/ui
- **REST + GraphQL API** - Full programmatic access to everything
- **CLI Tool** - Manage your server from the command line

### Technology Stack

| Layer | Technology | Reason |
|-------|-----------|---------|
| Backend | Node.js 22 + NestJS (TypeScript) | Modular, enterprise-grade |
| Frontend | Next.js 15 (App Router) + React 19 | SSR + static generation |
| UI Framework | Tailwind CSS + Shadcn/ui + Radix UI | Beautiful, accessible |
| Database | PostgreSQL 17 + Redis 7 | ACID, powerful extensions |
| Web Server | Caddy 2.8+ (HTTP/3, auto-TLS) | Zero-config TLS |
| Process Manager | systemd + PM2 | Native Linux integration |

## 📦 Installation

### One-Command Install

```bash
curl -fsSL https://raw.githubusercontent.com/rhcsolutions/nebulacp/main/install.sh | sudo bash
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/rhcsolutions/nebulacp.git
cd nebulacp
```

2. Run the installation script:
```bash
sudo bash install.sh
```

The installer will automatically:
- Install Node.js 22, PostgreSQL 17, Redis, Caddy, Nginx
- Set up the database and user accounts
- Install all dependencies
- Build the applications
- Configure systemd services
- Set up firewall rules
- Generate secure credentials

After installation, check `/root/nebulacp-credentials.txt` for access details.

## 🎯 Supported Operating Systems

- ✅ Debian 12 "Bookworm"
- ✅ Debian 13 "Trixie"
- ✅ Rocky Linux 9
- ✅ AlmaLinux 9
- ✅ Oracle Linux 9

## 🏗️ Project Structure

```
nebulacp/
├── apps/
│   ├── backend/          # NestJS API
│   ├── frontend/         # Next.js Dashboard
│   └── cli/              # Command Line Tool
├── packages/
│   ├── types/            # Shared TypeScript types
│   ├── config/           # ESLint, Tailwind configs
│   └── ui/               # Shared UI components
├── install/
│   ├── scripts/          # Installation scripts
│   └── systemd/          # Service files
└── docs/                 # Documentation
```

## 🔧 Development

### Prerequisites
- Node.js 22+
- PostgreSQL 17+
- Redis 7+

### Start Development Servers

Backend:
```bash
cd apps/backend
npm run start:dev
```

Frontend:
```bash
cd apps/frontend
npm run dev
```

## 🤖 AI Features

### Text Generation (Ollama)
- Integrated Llama 3.1, Qwen2, and other models
- Real-time text generation in the editor
- SEO optimization, content rewriting

### Image Generation (ComfyUI)
- Local Stable Diffusion XL
- Generate images directly in media library
- Background removal, upscaling

## 🔐 Security Features

- 2FA/MFA (TOTP + WebAuthn)
- Automatic OS updates
- Fail2Ban + CrowdSec integration
- WAF (Coraza)
- Malware scanning (ClamAV)
- Automatic SSL with Caddy

## 📊 Alerting & Monitoring

Integrations:
- ✅ Telegram Bot
- ✅ Slack Webhooks
- ✅ Discord
- ✅ Email
- ✅ Pushover

## 🗺️ Roadmap

- [x] Core backend API
- [x] Dashboard UI
- [x] Domain management
- [x] AI integration
- [ ] Mail server integration
- [ ] DNS management
- [ ] File manager
- [ ] Backup system
- [ ] Marketplace for themes/plugins

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 📄 License

AGPL-3.0 - See [LICENSE](LICENSE) file for details.

## 🌐 Links

- **Website:** https://nebulacp.rhcsolutions.com
- **Documentation:** https://docs.nebulacp.rhcsolutions.com
- **GitHub:** https://github.com/rhcsolutions/nebulacp
- **Discord:** https://discord.gg/nebulacp

## 💖 Acknowledgments

Inspired by:
- HestiaCP
- Virtualmin
- CyberPanel
- DirectAdmin

Built with love by the RH Solutions team and contributors.

---

**⚡ The Last Control Panel You'll Ever Install**
