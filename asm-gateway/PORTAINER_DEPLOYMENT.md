# 🐳 ASM Gateway - Portainer Deployment Guide

**Step-by-step instructions for deploying ASM Gateway via Portainer**

---

## 📋 Prerequisites

- ✅ Portainer installed and accessible
- ✅ MARIA stack running (for ChromaDB access)
- ✅ Git repository `bEDROch/SRCargo` accessible
- ✅ `/main/data/chromadb` directory exists
- ✅ `/srv/cargo/portainer/build/env/asm-gateway/.env` created

---

## 🚀 Deployment Steps

### **Step 1: Prepare Environment File**

File already created at:
```
/srv/cargo/portainer/build/env/asm-gateway/.env
```

**Verify contents**:
```bash
cat /srv/cargo/portainer/build/env/asm-gateway/.env
```

**Customize** if needed:
- `ASM_MCP_API_KEY` - Set secure API key
- `ASM_CORS_ORIGINS` - Add your domains
- `ASM_DEBUG` - Set to `true` for development

---

### **Step 2: Deploy Stack in Portainer**

1. **Open Portainer UI**: `http://localhost:9000` (or your Portainer URL)

2. **Navigate to Stacks**:
   - Click **Stacks** in left menu
   - Click **➕ Add stack** button

3. **Configure Stack**:
   ```
   Name:           asm-gateway
   Build method:   Repository
   ```

4. **Git Configuration**:
   ```
   Repository URL:      https://github.com/bEDROch/SRCargo
   Repository reference: refs/heads/main
   Compose path:        asm-gateway/docker-compose.yml
   ```

5. **Environment Variables** (Optional):
   - Click **Advanced mode**
   - Load from: `/srv/cargo/portainer/build/env/asm-gateway/.env`
   
   Or add manually:
   ```
   ASM_PORT=8100
   ASM_DEBUG=false
   ASM_MONGODB_URL=mongodb://mongodb:27017
   ```

6. **Deploy Stack**:
   - Click **Deploy the stack**
   - Wait for deployment (2-3 minutes first time)

---

### **Step 3: Verify Deployment**

#### **In Portainer UI**:
1. **Stacks** → **asm-gateway** → Should show:
   - ✅ `asm-gateway` (running)
   - ✅ `asm-mongodb` (running)

2. **Check Logs**:
   - Click on `asm-gateway` container
   - **Logs** tab → Should see:
     ```
     INFO: Started server process
     INFO: Uvicorn running on http://0.0.0.0:8100
     🚀 Starting ASM Gateway v3.0.0
     ```

#### **Via Terminal**:
```bash
# Test health endpoint
curl http://localhost:8100/health/

# Expected output:
# {"status":"healthy","service":"ASM Gateway","version":"3.0.0",...}

# Test MCP discovery
curl http://localhost:8100/mcp/discover

# Open API docs
open http://localhost:8100/docs
```

---

## 🔧 Post-Deployment Configuration

### **Network Connectivity**

Verify connection to MARIA network:
```bash
docker network ls | grep maria
docker exec -it asm-gateway ping chromadb
```

### **MongoDB Setup**

First-time initialization:
```bash
# Access MongoDB
docker exec -it asm-mongodb mongosh

# Create database
use mania

# Create collections
db.createCollection("documents")
db.createCollection("search_history")

# Create indexes
db.documents.createIndex({ "title": "text", "content": "text" })
db.search_history.createIndex({ "timestamp": 1 })

exit
```

### **ChromaDB Verification**

```bash
# Check ChromaDB data access
docker exec -it asm-gateway ls -la /data/chromadb

# Should show:
# chroma.sqlite3
# collections/
```

---

## 📊 Monitoring

### **Container Stats**

In Portainer:
- **Containers** → **asm-gateway** → **Stats** tab
- Monitor CPU, Memory, Network usage

### **Logs**

```bash
# Real-time logs
docker logs -f asm-gateway

# Last 100 lines
docker logs --tail 100 asm-gateway

# Since timestamp
docker logs --since 2025-11-09T00:00:00 asm-gateway
```

### **Health Checks**

Automated health check every 30s:
```bash
docker inspect asm-gateway | grep -A 10 Health
```

---

## 🔄 Updates

### **Method 1: Portainer UI**

1. **Stacks** → **asm-gateway**
2. Click **Pull and redeploy**
3. Wait for update

### **Method 2: Git Webhook**

Configure in Portainer:
1. **Stacks** → **asm-gateway** → **Editor**
2. Enable **Automatic updates**
3. Set webhook URL in GitHub repo

### **Method 3: Manual**

```bash
# Pull latest code
cd /srv/cargo/drydock/srcargo
git pull origin main

# Rebuild in Portainer UI
# or via CLI:
cd /srv/cargo/drydock/srcargo/asm-gateway
docker-compose pull
docker-compose up -d --force-recreate
```

---

## 🚨 Troubleshooting

### **Container Won't Start**

1. **Check logs**:
   ```bash
   docker logs asm-gateway
   ```

2. **Verify environment**:
   ```bash
   docker exec -it asm-gateway env | grep ASM_
   ```

3. **Test dependencies**:
   ```bash
   # MongoDB
   docker exec -it asm-gateway curl http://mongodb:27017
   
   # Source code mounted
   docker exec -it asm-gateway ls -la /app
   ```

### **Port Already in Use**

```bash
# Find process using port 8100
sudo lsof -i :8100

# Kill process (if safe)
sudo kill -9 <PID>

# Or change port in docker-compose.yml
ports:
  - "8101:8100"  # Use different host port
```

### **MongoDB Connection Failed**

```bash
# Check MongoDB container
docker ps | grep asm-mongodb

# Test connection
docker exec -it asm-gateway bash
pip install pymongo
python3 << EOF
from pymongo import MongoClient
client = MongoClient('mongodb://mongodb:27017')
print(client.admin.command('ping'))
EOF
```

### **ChromaDB Access Issues**

```bash
# Verify shared volume
ls -la /main/data/chromadb

# Check permissions
docker exec -it asm-gateway whoami
docker exec -it asm-gateway ls -la /data/chromadb

# Fix if needed
sudo chown -R 1000:1000 /main/data/chromadb
```

---

## 🔐 Security Checklist

Before production:
- [ ] Change `ASM_MCP_API_KEY` to strong secret
- [ ] Set `ASM_DEBUG=false`
- [ ] Configure proper `ASM_CORS_ORIGINS`
- [ ] Enable `ASM_MCP_AUTH_ENABLED=true`
- [ ] Setup Redis for rate limiting
- [ ] Configure Traefik SSL certificates
- [ ] Review MongoDB access controls

---

## 📚 Additional Resources

- **Architecture**: `/main/dev/net/integrations/asm/ASM_INTEGRATION_ARCHITECTURE.md`
- **API Docs**: http://localhost:8100/docs
- **GitHub Issue**: https://github.com/DEVC0ManIA/mAIn/issues/83
- **Portainer Docs**: https://docs.portainer.io/

---

## 🎯 Quick Reference

| Component | URL | Credentials |
|-----------|-----|-------------|
| **ASM Gateway** | http://localhost:8100 | API Key in .env |
| **OpenAPI Docs** | http://localhost:8100/docs | - |
| **Health Check** | http://localhost:8100/health/ | - |
| **MongoDB** | mongodb://localhost:27018 | No auth (local) |
| **Portainer** | http://localhost:9000 | Your credentials |

---

**Need Help?**  
Check logs first: `docker logs asm-gateway`  
GitHub Issues: https://github.com/DEVC0ManIA/mAIn/issues

---

**Last Updated**: 2025-11-09  
**Maintainer**: DEVC0ManIA
