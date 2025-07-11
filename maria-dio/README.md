**Resoconto del Progetto **``**: passato, presente e futuro**

---

### 🕐 **Contesto generale**

Il progetto `dio_web` fa parte dell'iniziativa più ampia chiamata *MarIA*, un ecosistema self-hosted su server Ubuntu per l'interazione avanzata con agenti AI. L'interfaccia `dio_web` è realizzata in Flask ed eseguita in un container Docker gestito tramite Portainer, con codice montato esternamente e agenti CrewAI come backend di automazione. Il frontend sarà disponibile via `https://dio.bedro.ch` tramite Nginx Proxy Manager.

---

## ✅ **Situazione Attuale (Presente)**

### **Struttura attuale del codice**

- Codice dell'app Flask: `/srv/maria/dio/app`
- Struttura Flask: modulare con `create_app()` in `__init__.py`
- Entry-point: `/srv/maria/dio/app/wsgi.py`
- Codice agenti: `/srv/maria/dio/app/agents/`
- Virtualenv locale per test: `/srv/maria/dio/venv/`

### **Docker & Build**

- Directory immagine Docker: `/srv/cargo/build/image/maria/dio_web`
  - Include: `Dockerfile`, `requirements.txt`
  - Soft link: `/srv/maria/src/image/dio -> /srv/cargo/build/image/maria/dio_web`
- Immagine Docker: `dio_web:local`
- Stack Docker con Portainer: include volume bindato del codice:
  ```yaml
  volumes:
    - /srv/maria/dio:/app
  ```

### **Volumi Docker**

- Volumi persistenti dati generali: `/srv/cargo/volumes/maria/dio`
- Cache pip (per ottimizzare build): `/srv/cargo/python-cache`

### **Problemi riscontrati**

1. **Import inconsistente** tra struttura Flask e layout Docker (es. `from app.agents...` -> corretto `from agents...`)
2. **Assenza codice durante build**: inizialmente solo `Dockerfile` e `requirements.txt` erano copiati nell'immagine.
3. **Incompatibilità tra versioni di CrewAI, LangChain, Pydantic, ChromaDB, ecc.**
4. **Deprecazioni** multiple da Pydantic 1 → 2, LangChain >= 0.3, Numpy 2.0, ecc.
5. **Errori come**:
   - `ModuleNotFoundError: No module named 'app'`
   - `ImportError: cannot import name 'LangSmithParams'`
   - `AttributeError: 'FileTool' object has no attribute 'get'`
   - `KeyError: 'tools'` in `CrewAgentExecutor`

---

## 📜 **Stato desiderato (Futuro)**

### **Obiettivo**

Far funzionare in modo stabile l'interfaccia `dio_web` con:

- Backend Flask avviabile nel container
- Supporto agenti CrewAI funzionanti (FileTool, ShellTool, ecc.)
- API su route MCP: `/mcp-webhook`, `/run-agent-task`, ecc.
- Integrazione con memoria (ChromaDB) e database MariaDB
- Dashboard accessibile pubblicamente su `dio.bedro.ch`

### **Piano di stabilizzazione**

1. **Bloccare versions compatibili nel **``
2. **Separare ambiente sviluppo da quello containerizzato**
3. **Eliminare virtualenv dal volume bindato (**``**)**
4. **Testare agenti CrewAI uno a uno (es. file\_agent, shell\_agent)**
5. **Isolare e sostituire pacchetti deprecati (LangChain Core, Pydantic, ecc.)**

---

## ⏳ **Riepilogo delle directory chiave**

| Scopo                | Percorso                               |
| -------------------- | -------------------------------------- |
| Codice Flask         | `/srv/maria/dio/app`                   |
| Entry-point WSGI     | `/srv/maria/dio/app/wsgi.py`           |
| Codice agenti CrewAI | `/srv/maria/dio/app/agents/`           |
| Build Docker         | `/srv/cargo/build/image/maria/dio_web` |
| Symlink build        | `/srv/maria/src/image/dio`             |
| Volume runtime app   | `/srv/cargo/volumes/maria/dio`         |
| Cache pip            | `/srv/cargo/python-cache`              |

---

## 🚀 **Prossimi Passi**

-

---

✍️ **Nota finale** Il sistema sarà progettato per facilitare l'estensione, con moduli indipendenti e routing flessibile. Un nuovo agente AI può contribuire al progetto usando questa base per automatizzare task, creare un sistema esperto o interagire con l'ambiente Linux via script e strumenti intelligenti.

Pedro è il maintainer principale. Ogni modifica significativa deve mantenere coerenza con questa visione.

