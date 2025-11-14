# SRCargo - Production Docker Stacks

**Portainer-managed production container stacks for bEDROch infrastructure**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://www.docker.com/)
[![Portainer](https://img.shields.io/badge/Portainer-Managed-13BEF9?logo=portainer)](https://www.portainer.io/)

---

## 📋 Overview

Centralized repository for all production Docker Compose stacks managed via Portainer CE 2.27.9 LTS.

**Infrastructure**: Dual host (Publo + local workstation)  
**Management**: Portainer Community Edition  
**Backup Strategy**: Daily automated backups to Google Drive + NextCloud  
**Environment Files**: Centralized in `/srv/cargo/env/`

---

## 🗂️ Stack Inventory

| Stack | Services | Status | Port(s) | Description |
|-------|----------|--------|---------|-------------|
| **asm-gateway** | 2 | ✅ Active | 8100 | AI Knowledge Management (ChromaDB + MongoDB) |
| **bedrocket** | 2 | ✅ Active | 3000 | Rocket.Chat + MongoDB 6.0 |
| **bookstack** | 2 | ⚠️ Limited | 6875 | Documentation Wiki (requires manual setup) |
| **bot** | 3 | ✅ Active | 3030 | Discord Espresso Bot + Dashboard + MongoDB 7 |
| **dashome** | 1 | ✅ Active | 1080 | Dashy Dashboard |
| **flowsint** | 3 | ✅ Active | 8090 | Workflow Integration (Redis + Neo4j + API) |
| **irc-server** | 2 | ✅ Active | 6667, 6697, 9000 | InspIRCd + TheLounge Web Client |
| **maria-dio** | 1 | ✅ Active | 8182 | MarIA DIO AI Service |
| **mediawiki_0** | 2 | ✅ Active | 8082 | MediaWiki + MariaDB |
| **paperless** | 3 | ✅ Active | 8400 | Paperless-ngx + PostgreSQL 15 + Redis 7 |
| **proxyman** | 1 | ✅ Active | 80, 443, 8081 | Traefik Reverse Proxy |
| **wordpress** | 2 | ✅ Active | 8080 | WordPress + MariaDB |

**Total**: 12 stacks, 25 containers

---

## 🚀 Quick Start

### Prerequisites
- Docker Engine 28.5.2 (⚠️ **NOT Docker 29** - known Portainer incompatibility)
- Portainer CE 2.27.9 LTS
- Access to `/srv/cargo/` volumes
- Environment files in `/srv/cargo/env/`

### Import Stack via Portainer Web Editor

1. **Portainer** → Stacks → **Add Stack**
2. **Name**: `{stack-name}` (use exact names from inventory)
3. **Build method**: **Web editor** (NOT file upload - parser issues)
4. **Copy/paste YAML** from `/srv/cargo/env/PORTAINER_IMPORT_YAMLS.md`
5. **Deploy Stack**

**Import Guide**: See `/srv/cargo/env/PORTAINER_IMPORT_YAMLS.md` for ready-to-paste YAML files

### Clone Repository

```bash
git clone https://github.com/bEDROch/SRCargo.git
cd SRCargo
```

---

## 📁 Repository Structure

```
srcargo/
├── asm-gateway/          # AI Knowledge Management stack
│   ├── docker-compose.yml
│   └── README.md
├── bedrocket/            # Rocket.Chat stack
│   ├── docker-compose.yml
│   └── README.md
├── bookstack/            # Documentation wiki
│   ├── docker-compose.yml
│   ├── README.md
│   └── .env.example
├── bot/                  # Discord bot + dashboard
│   └── docker-compose.yml
├── dashome/              # Dashy dashboard
│   └── docker-compose.yml
├── flowsint/             # Workflow integration
│   ├── docker-compose.yaml
│   └── README.md
├── irc-server/           # IRC server + web client
│   └── docker-compose.yml
├── maria-dio/            # MarIA AI service
│   ├── docker-compose.yml
│   └── README.md
├── mediawiki_0/          # MediaWiki instance
│   └── docker-compose.yml
├── paperless/            # Document management
│   ├── docker-compose.yml
│   └── README.md
├── proxyman/             # Traefik reverse proxy
│   ├── docker-compose.yml
│   └── README.md
└── wordpress/            # WordPress blog
    └── docker-compose.yml
```

---

## 🔐 Environment Files

**Location**: `/srv/cargo/env/{stack}/.env`

Environment files are **NOT** in this repository (security). See `/srv/cargo/env/README.md` for:
- Stack → env file mapping
- Environment variable documentation
- Portainer import instructions

**Example structure**:
```
/srv/cargo/env/
├── asm-gateway/.env
├── dashome/.env
├── flowsint/.env
├── paperless/.env
├── wordpress/.env
└── ...
```

---

## 🛡️ Security Notes

- All production passwords stored in `/srv/cargo/env/` (not tracked in git)
- `.gitignore` prevents accidental env file commits
- Discord bot token exposed in compose (secure via network isolation)
- Traefik uses Cloudflare API for SSL (token in env file)

**Password Rotation**: Update env files + restart stack via Portainer

---

## 💾 Backup Strategy

### Portainer Guardian CLI

Automated backup tool: `/home/Agenti0/.local/bin/portainer-guardian`

**Daily backup includes**:
- Portainer database (`portainer.db`)
- All stack configurations
- Environment files

**Backup locations**:
- Local: `/srv/cargo/portainer/backups/`
- Cloud: Google Drive (`gdrive-backups:BACKUPS/@Publo/portainer/`)
- Cloud: NextCloud (`nextcloud-triky:portainer/`)

**Manual backup**:
```bash
sudo portainer-guardian backup
```

### Stack Recovery

See `/srv/cargo/env/PORTAINER_IMPORT_YAMLS.md` for pre-generated import YAML files with embedded environment variables.

---

## 🔧 Maintenance

### Docker 29 Incompatibility

**Critical**: Docker 29.0.0 breaks Portainer CE 2.27.9 LTS

**Current version (safe)**: Docker 28.5.2 with package holds:
```bash
sudo apt-mark hold docker-ce docker-ce-cli docker-ce-rootless-extras containerd.io
```

**Monitor fix**: GitHub issue [#12934](https://github.com/portainer/portainer/issues/12934)

### Stack Health Check

```bash
# Via Portainer Guardian CLI
portainer-guardian check

# Manual check
docker ps --filter "name=*" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Logs

Stack logs available via Portainer UI or:
```bash
docker logs {container-name}
```

---

## 📚 Documentation

- **Portainer Import Guide**: `/srv/cargo/env/PORTAINER_IMPORT_YAMLS.md`
- **Environment Files**: `/srv/cargo/env/README.md`
- **Backup Documentation**: `/srv/cargo/portainer/tools/README.md`
- **Individual Stacks**: Each stack has its own `README.md`

---

## 🔗 Related Resources

- **Portainer**: https://www.portainer.io/
- **Docker Docs**: https://docs.docker.com/
- **Traefik**: https://doc.traefik.io/traefik/
- **Rocket.Chat**: https://docs.rocket.chat/
- **Paperless-ngx**: https://docs.paperless-ngx.com/

---

## 📜 License

MIT License - See [LICENSE](LICENSE) file for details

---

## 👤 Maintainer

**bEDROch** (Pedro)  
- GitHub: [@bEDROch](https://github.com/bEDROch)
- Infrastructure: Dual-host (Publo production + local workstation)

---

## 🆘 Support & Issues

**Portainer Issues**: GitHub [portainer/portainer](https://github.com/portainer/portainer)  
**Stack-specific**: Open issue in this repository  
**Emergency Recovery**: See backup documentation

---

**Last Updated**: November 14, 2025  
**Stack Count**: 12 production stacks, 25 containers  
**Status**: ✅ All systems operational
