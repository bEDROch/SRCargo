# 📚 BookStack Deployment - Internal Documentation Hub

**Status**: ✅ Ready for Deployment  
**URL**: https://docs.bedro.ch (via nginx-proxy-manager)  
**Internal Port**: 6875  
**Issue**: [#71](https://github.com/DEVC0ManIA/mAIn/issues/71)

---

## 🎯 Purpose

Internal documentation hub for mAIn Enterprise system:
- Technical documentation (L3 level)
- Knowledge base articles
- Integration guides
- Procedures and runbooks
- Team wiki and collaboration

---

## 📦 Quick Start

### 1. Prepare Directories

```bash
# Create volume directories
sudo mkdir -p /srv/cargo/volumes/bookstack/{db,config,data,storage}

# Set permissions (PUID=1005, PGID=1005)
sudo chown -R 1005:1005 /srv/cargo/volumes/bookstack/

# Verify
ls -la /srv/cargo/volumes/bookstack/
```

### 2. Configure Environment

```bash
# Copy example env
cd /srv/cargo/drydock/srcargo/bookstack/
cp .env.example .env

# Edit configuration
nano .env

# Set strong passwords:
#   MYSQL_ROOT_PASSWORD
#   MYSQL_PASSWORD
```

### 3. Deploy Stack

```bash
# Launch BookStack
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs -f bookstack

# Wait for healthy status (30-60s)
docker ps | grep bookstack
```

### 4. Initial Setup

1. **Access**: http://10.84.3.100:6875
2. **Default Login**:
   - Email: `admin@admin.com`
   - Password: `password`
3. **⚠️ CRITICAL**: Change admin credentials immediately\!
4. **Configure**:
   - Settings → Application URL: `https://docs.bedro.ch`
   - Settings → Registration: Disable public registration
   - Users → Create team accounts

---

## 🔧 Configuration

### Nginx Proxy Manager Setup

**Add Proxy Host**:
```
Domain Names: docs.bedro.ch
Scheme: http
Forward Hostname/IP: 10.84.3.100
Forward Port: 6875
Block Common Exploits: ✅
Websockets Support: ❌
Access List: (Optional - restrict by IP)

SSL:
- Force SSL: ✅
- HTTP/2: ✅
- HSTS Enabled: ✅
- Certificate: Let's Encrypt (Auto-renew)
```

### API Token Generation

For ChromaDB sync integration:

1. Settings → API Tokens
2. Create new token: `ChromaDB Sync`
3. Permissions: `content:read`
4. Save token to secrets:

```bash
# Store API token securely
echo "YOUR_TOKEN_ID:YOUR_TOKEN_SECRET" > /main/.secrets/keys/bookstack_api_token.txt
chmod 600 /main/.secrets/keys/bookstack_api_token.txt
```

---

## 📊 Usage

### Shelf Organization

**Recommended Structure**:
```
📚 AEQUILIBRIA Documentation
  → Book: Architecture & Design
  → Book: Integration Guides
  → Book: Troubleshooting

📚 mAIn Technical Docs
  → Book: Core System
  → Book: Tools & Scripts
  → Book: API Reference

📚 Team Knowledge Base
  → Book: Procedures
  → Book: Runbooks
  → Book: FAQ
```

### ChromaDB Synchronization

Sync BookStack content to RAG system:

```bash
# Manual sync
/main/env/venv/bin/python3 /main/core/system/scripts/sync_bookstack_to_chromadb.py

# Sync specific shelf
/main/env/venv/bin/python3 /main/core/system/scripts/sync_bookstack_to_chromadb.py --shelf AEQUILIBRIA

# Dry run (test without writing)
/main/env/venv/bin/python3 /main/core/system/scripts/sync_bookstack_to_chromadb.py --dry-run
```

**Setup Automatic Sync** (cron):
```bash
# Run sync daily at 02:00
0 2 * * * /main/env/venv/bin/python3 /main/core/system/scripts/sync_bookstack_to_chromadb.py >> /main/logs/bookstack_sync.log 2>&1
```

---

## 🔍 Monitoring

### Health Check

```bash
# Container status
docker ps | grep bookstack

# Logs
docker-compose logs -f bookstack
docker-compose logs -f bookstack-db

# Database check
docker exec bookstack-db mysql -u bookstack -p -e "SHOW DATABASES;"

# Disk usage
du -sh /srv/cargo/volumes/bookstack/*
```

### Backup

```bash
# Database backup
docker exec bookstack-db mysqldump -u bookstack -p bookstack > bookstack_backup_$(date +%Y%m%d).sql

# Files backup
tar -czf bookstack_files_$(date +%Y%m%d).tar.gz /srv/cargo/volumes/bookstack/data/ /srv/cargo/volumes/bookstack/storage/

# Move to backup location
mv bookstack_*.{sql,tar.gz} /srv/cargo/backup/bookstack/
```

---

## 🚨 Troubleshooting

### Container Won't Start

```bash
# Check logs for errors
docker-compose logs bookstack

# Common issues:
# 1. Database not healthy → wait longer
# 2. Permission denied → check /srv/cargo/volumes/bookstack/ ownership
# 3. Port conflict → check port 6875 availability
```

### Can't Access Web UI

```bash
# Test internal access
curl http://localhost:6875

# Check firewall
sudo ufw status | grep 6875

# Verify reverse proxy
curl -I https://docs.bedro.ch
```

### Database Connection Failed

```bash
# Check database container
docker ps | grep bookstack-db
docker-compose logs bookstack-db

# Test connection from BookStack container
docker exec bookstack mysql -h bookstack-db -u bookstack -p
```

---

## 📚 Resources

- **Official Docs**: https://www.bookstackapp.com/docs/
- **API Documentation**: https://www.bookstackapp.com/docs/admin/hacking-bookstack/#api-documentation
- **Docker Image**: https://docs.linuxserver.io/images/docker-bookstack
- **GitHub**: https://github.com/BookStackApp/BookStack

---

## 🔗 Integration

### With Deepwiki (Issue #70)

BookStack = Manual curated documentation  
Deepwiki = AI-powered auto-documentation

**Synergy**:
- BookStack: Strategic docs, guides, policies
- Deepwiki: Auto-generated from code/commits
- Both sync to ChromaDB for unified RAG

### With PME System

Create issues from documentation tasks:
- Document new feature → Linear issue
- Update procedure → Jira task
- Knowledge gap identified → PME tracking

---

**Last Updated**: 2025-11-07  
**Maintained by**: MarIA Team  
**Status**: 🚀 Production Ready
