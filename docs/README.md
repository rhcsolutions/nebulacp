# NebulaCP Documentation

## Getting Started

### Prerequisites
- A fresh VPS with Debian 12/13 or Rocky Linux 9
- At least 2GB RAM and 20GB disk space
- Root access

### Quick Install

```bash
curl -fsSL https://get.nebulacp.rhcsolutions.com | bash
```

## Configuration

### Database Setup
The installer automatically creates a PostgreSQL database. Credentials are stored in `/etc/nebula/.env`.

### First Login
After installation, access the dashboard at `https://YOUR_SERVER_IP`

Default credentials are generated and displayed after installation.

### Adding Your First Domain

1. Navigate to "Domains" in the sidebar
2. Click "Add Domain"
3. Enter your domain name
4. Choose PHP version
5. Click "Create"

SSL certificates are automatically generated via Caddy.

## Architecture

### Backend (NestJS)
- Location: `/usr/local/nebula/apps/backend`
- Port: 3000
- Service: `nebula-backend.service`

### Frontend (Next.js)
- Location: `/usr/local/nebula/apps/frontend`
- Port: 3001
- Service: `nebula-frontend.service`

### Database
- PostgreSQL 17
- Database name: `nebulacp`
- Managed via Prisma ORM

## API Documentation

### Authentication
All API endpoints require authentication via JWT cookie or Bearer token.

### Endpoints

#### Domains
- `GET /domains` - List all domains
- `POST /domains` - Create domain
- `GET /domains/:id` - Get domain details
- `DELETE /domains/:id` - Delete domain

#### AI
- `POST /ai/text` - Generate text
- `POST /ai/image` - Generate image

## Troubleshooting

### Check Service Status
```bash
systemctl status nebula-backend
systemctl status nebula-frontend
```

### View Logs
```bash
journalctl -u nebula-backend -f
journalctl -u nebula-frontend -f
```

### Reset Database
```bash
cd /usr/local/nebula/apps/backend
npm run prisma:migrate:reset
```

## Advanced Configuration

### Custom SSL Certificates
Place certificates in `/etc/caddy/certs/` and configure Caddyfile.

### Backup Configuration
Edit `/etc/nebula/backup.conf` to configure automated backups.

## Support

- GitHub Issues: https://github.com/rhcsolutions/nebulacp/issues
- Discord: https://discord.gg/nebulacp
- Email: support@rhcsolutions.com
