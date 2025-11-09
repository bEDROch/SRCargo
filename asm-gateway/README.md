# 🚀 ASM Gateway - Docker Compose Stack

**AI-native Knowledge Management Gateway with MCP Protocol Support**

---

## 📦 Stack Overview

| Service | Port | Description |
|---------|------|-------------|
| **asm-gateway** | 8100 | FastAPI application with MCP protocol |
| **mongodb** | 27018 | MongoDB for keyword search |
| **chromadb** | - | Via MARIA network (shared) |

---

## 🎯 Quick Start (Portainer)

### **1. Setup Environment File**

Create `/srv/cargo/portainer/build/env/asm-gateway/.env`:

```bash
# ASM Gateway Configuration
ASM_HOST=0.0.0.0
ASM_PORT=8100
ASM_DEBUG=false

# Database
ASM_MONGODB_URL=mongodb://mongodb:27017
ASM_MONGODB_DATABASE=mania
ASM_CHROMADB_PERSIST_PATH=/data/chromadb

# API Settings
ASM_RATE_LIMIT_PER_MINUTE=100
ASM_SEARCH_MAX_RESULTS=50
ASM_SEARCH_TIMEOUT=10.0

# CORS
ASM_CORS_ORIGINS=["http://localhost:3000","http://localhost:5173"]
```

### **2. Deploy in Portainer**

1. **Stacks** → **Add Stack**
2. **Name**: `asm-gateway`
3. **Build Method**: Repository
4. **Repository URL**: `https://github.com/bEDROch/SRCargo`
5. **Repository Path**: `asm-gateway`
6. **Environment File**: `/srv/cargo/portainer/build/env/asm-gateway/.env`
7. **Deploy**

### **3. Verify Deployment**

```bash
# Check health
curl http://localhost:8100/health/

# Check MCP capabilities
curl http://localhost:8100/mcp/discover

# View OpenAPI docs
open http://localhost:8100/docs
```

---

## 🔧 Configuration

### **Environment Variables**

All variables use `ASM_` prefix:

| Variable | Default | Description |
|----------|---------|-------------|
| `ASM_HOST` | `0.0.0.0` | Bind address |
| `ASM_PORT` | `8100` | HTTP port |
| `ASM_DEBUG` | `false` | Debug mode |
| `ASM_MONGODB_URL` | - | MongoDB connection string |
| `ASM_CHROMADB_PERSIST_PATH` | `/data/chromadb` | ChromaDB data path |

Full list: See `app/config.py`

### **Volumes**

| Host Path | Container Path | Description |
|-----------|----------------|-------------|
| `/main/dev/net/integrations/asm/gateway` | `/app` | Source code |
| `/main/data/chromadb` | `/data/chromadb` | ChromaDB data |
| `/srv/cargo/build/mongodb/asm` | `/data/db` | MongoDB data |

---

## 📊 Monitoring

### **Health Checks**

- **Liveness**: `GET /health/live`
- **Readiness**: `GET /health/ready`
- **Detailed**: `GET /health/detailed`
- **Metrics**: `GET /health/metrics` (Prometheus format)

### **Logs**

```bash
# Portainer UI: Containers → asm-gateway → Logs

# Or via Docker CLI:
docker logs -f asm-gateway
```

---

## 🔗 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | API info |
| `/health/` | GET | Health check |
| `/docs` | GET | OpenAPI documentation |
| `/query/` | POST | Single search query |
| `/query/batch` | POST | Batch search |
| `/mcp/discover` | GET | MCP capabilities |
| `/mcp/tools/invoke` | POST | MCP tool invocation |
| `/sync/trigger` | POST | Trigger document sync |
| `/admin/collections` | GET | List ChromaDB collections |

---

## 🚨 Troubleshooting

### **Port Conflicts**

If port 8100 is busy:
```yaml
# In docker-compose.yml
ports:
  - "8101:8100"  # Change host port
```

### **MongoDB Connection**

```bash
# Test MongoDB access
docker exec -it asm-gateway bash
pip install pymongo
python3 -c "from pymongo import MongoClient; print(MongoClient('mongodb://mongodb:27017').admin.command('ping'))"
```

### **ChromaDB Access**

```bash
# Verify ChromaDB path
docker exec -it asm-gateway ls -la /data/chromadb
```

---

## 🔄 Updates

### **Pull Latest Code**

Portainer will auto-pull from GitHub when you redeploy.

Or manually:
```bash
cd /main/dev/net/integrations/asm/gateway
git pull origin main
docker-compose restart asm-gateway
```

### **Rebuild Image**

```bash
docker-compose up -d --build
```

---

## 🔐 Security

- **API Key Authentication**: Configured via `ASM_MCP_AUTH_ENABLED`
- **Rate Limiting**: Redis-based (optional)
- **CORS**: Restricted origins in production

---

## 📚 Documentation

- **Architecture**: `/main/dev/net/integrations/asm/ASM_INTEGRATION_ARCHITECTURE.md`
- **Implementation Status**: `/main/dev/net/integrations/asm/IMPLEMENTATION_STATUS.md`
- **GitHub Issue**: https://github.com/DEVC0ManIA/mAIn/issues/83

---

## 🎯 Network Architecture

```
┌─────────────────────────────────────────┐
│         Portainer Stack                 │
│  ┌───────────────────────────────────┐  │
│  │   asm-gateway (Python/FastAPI)    │  │
│  │   Port: 8100                      │  │
│  └───────────┬───────────────────────┘  │
│              │                           │
│  ┌───────────┴───────────┐              │
│  │   MongoDB (Port 27018) │              │
│  └───────────────────────┘              │
└──────────────┬──────────────────────────┘
               │
               │ maria-network (external)
               ▼
┌──────────────────────────────────────────┐
│         MARIA Stack (Existing)           │
│  ┌────────────────────────────────────┐  │
│  │   ChromaDB                         │  │
│  │   Volume: /main/data/chromadb      │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘
```

---

**Maintainer**: DEVC0ManIA  
**Last Updated**: 2025-11-09
