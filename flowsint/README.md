# Flowsint Service Deployment

**Deploy Status**: 🔧 Ready for deployment  
**Version**: 1.0.0  
**Created**: 2025-11-14  
**Integration**: ASM/PME Universal Task Sync

## 📋 Overview

Flowsint orchestration stack per gestione declarative task flows con supporto AEQUILIBRIA (ethics + security validation).

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flowsint Stack                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐    ┌──────────────┐                 │
│  │ Flowsint API │    │Celery Worker │                 │
│  │  (FastAPI)   │    │  (Tasks)     │                 │
│  │  Port: 8090  │    │              │                 │
│  └──────┬───────┘    └──────┬───────┘                 │
│         │                   │                          │
│    ┌────┴─────────────┬─────┴────┐                    │
│    │                  │          │                     │
│ ┌──▼──────┐   ┌───────▼──┐  ┌───▼────┐               │
│ │  Redis  │   │  Neo4j   │  │ Flower │               │
│ │  :6380  │   │  :7475   │  │ :5555  │               │
│ └─────────┘   └──────────┘  └────────┘               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 📂 File Structure

```
/srv/cargo/drydock/srcargo/flowsint/
├── docker-compose.yaml      # Stack definition
├── deploy_flowsint.sh       # Deployment hook
└── README.md               # This file

/srv/cargo/portainer/build/env/
└── flowsint.env            # Environment variables

/srv/maria/cargo/volumes/flowsint/
├── redis/                  # Redis persistence
├── neo4j/                  # Neo4j data + logs
└── logs/                   # Application logs

/main/dev/net/integrations/pme/flows/
└── universal_task_sync.py  # POC flow (mounted in containers)
```

## 🚀 Quick Start

### Initial Deployment

```bash
cd /srv/cargo/drydock/srcargo/flowsint
./deploy_flowsint.sh
```

### Update Stack

```bash
./deploy_flowsint.sh --update
```

### Check Status

```bash
./deploy_flowsint.sh --status
```

### View Logs

```bash
./deploy_flowsint.sh --logs
```

### Restart Services

```bash
./deploy_flowsint.sh --restart
```

## 🔐 Security Configuration

**⚠️ IMPORTANTE**: Prima del deploy production, modifica password in `/srv/cargo/portainer/build/env/flowsint.env`:

```bash
# Neo4j
NEO4J_PASSWORD=changeme_flowsint_neo4j_secure_password

# Flower
FLOWER_PASSWORD=changeme_flower_secure_password
```

## 🔗 Service Endpoints

| Service | URL | Description |
|---------|-----|-------------|
| **Flowsint API** | http://localhost:8090 | FastAPI REST endpoint |
| **Neo4j Browser** | http://localhost:7475 | Graph database UI |
| **Redis** | localhost:6380 | Message broker |
| **Flower Dashboard** | http://localhost:5555 | Celery monitoring |

## 🧪 Integration with ASM/PME

Lo stack monta automaticamente:
- **POC Flow**: `/main/dev/net/integrations/pme/flows` → `/app/flows` (container)
- **Telemetry**: `/main/logs` → `/app/telemetry` (read-only)

### Test POC Flow

```bash
# Inside container
docker exec -it flowsint-api /bin/bash
python /app/flows/universal_task_sync.py --task-id MAIN-123
```

## 📊 AEQUILIBRIA Validation

Config in `flowsint.env`:
- **ETHICS_THRESHOLD**: 0.53 (score minimo per approval)
- **GUARDIAN_ENABLED**: true (security scan attivo)

Flow steps con validazione:
1. `normalize_task` → standardizza formato
2. `validate_ethics` → AEQUILIBRIA Ethics Auditor check
3. `validate_security` → GuardianSec scan
4. `sync_to_sources` → propagate a Jira/Linear/Notion
5. `create_implementation` → MISS tracking
6. `log_telemetry` → metrics export

## 🛠️ Troubleshooting

### Services not starting

```bash
docker compose -f docker-compose.yaml logs flowsint-api
docker compose -f docker-compose.yaml logs flowsint-worker
```

### Neo4j connection failed

Verifica password in env file e attendi `start_period: 40s`.

### Redis connection refused

Verifica porta 6380 disponibile:
```bash
netstat -tuln | grep 6380
```

### Volume permissions

```bash
sudo chown -R $(id -u):$(id -g) /srv/maria/cargo/volumes/flowsint
```

## 📈 Monitoring

### Celery Tasks (Flower)

http://localhost:5555 → login con `FLOWER_USER`/`FLOWER_PASSWORD`

### Neo4j Query Browser

http://localhost:7475 → login con `NEO4J_USER`/`NEO4J_PASSWORD`

```cypher
// View task graph
MATCH (t:Task)-[r]->(dep:Task)
RETURN t, r, dep
LIMIT 25
```

### Redis CLI

```bash
docker exec -it flowsint-redis redis-cli
> PING
> INFO stats
```

## 🔄 Migration from Legacy Scripts

Vedi `/main/dev/net/integrations/pme/flows/README.md` per mapping:
- `notion_sync.py` → `flows/notion_sync_flow.py`
- `linear_sync.py` → `flows/linear_sync_flow.py`
- `jira_sync.py` → `flows/jira_sync_flow.py`

## 📚 References

- [Flowsint Integration Proposal](../../../FLOWSINT_INTEGRATION_PROPOSAL.md)
- [ASM/PME Architecture](../../../README.md)
- [AEQUILIBRIA Ethics](../../../../docs/governance/AEQUILIBRIA_INTEGRATION.md)
- [Issue #118 - Universal Task Sync](https://github.com/DEVC0ManIA/mAIn/issues/118)
- [Issue #114 - Orchestrated Delegation](https://github.com/DEVC0ManIA/mAIn/issues/114)

## 🆘 Support

- **Logs**: `/srv/maria/cargo/volumes/flowsint/logs/`
- **Telemetry**: `/main/logs/flowsint_telemetry.json`
- **Health Check**: `curl http://localhost:8090/health`

---

**Deployment Checklist**:
- [ ] Password modificate in `flowsint.env`
- [ ] Volumi creati in `/srv/maria/cargo/volumes/flowsint/`
- [ ] Docker Compose syntax validated
- [ ] Health checks green (30s post-deploy)
- [ ] POC flow montato correttamente
- [ ] Telemetry path accessibile
- [ ] Neo4j browser connesso
- [ ] Flower dashboard accessibile
