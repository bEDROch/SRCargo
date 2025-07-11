**Resoconto del Progetto MarIA-Dio: passato, presente e futuro**

---

### 🕐 **Contesto generale e Visione**

Il progetto `dio_web` fa parte dell'iniziativa più ampia chiamata *MarIA*, un ecosistema self-hosted su server Ubuntu (nome: `publo`) per l'interazione avanzata con agenti AI. L'obiettivo è creare un sistema **etico, modulare e intelligente** che assista nella gestione quotidiana dei dispositivi, dei progetti e del codice.

L'interfaccia `dio_web` è realizzata in Flask ed eseguita in un container Docker gestito tramite Portainer, con codice montato esternamente e agenti CrewAI come backend di automazione. Il frontend è disponibile via `https://dio.bedro.ch` tramite Nginx Proxy Manager.

#### Caratteristiche Principali:
- **Assistente IA nel terminale** con comportamento simile a Warp
- Capacità di lettura comandi e output con correzioni automatiche
- Accesso al contesto (cartella corrente, progetti attivi, stato Docker)
- Funzioni agentiche per shell, file, docker, codice
- Modalità di esecuzione: **Manuale** (con conferma) e **Adhoc** (autonoma)

---

## ✅ **Situazione Attuale (Presente)**

### **Struttura attuale del codice**

```
/srv/maria/dio/
├── app/                  # Flask app MCP + dashboard
├── scripts/              # Script ZSH, Python, Bash
├── memory/              # Memorie temporanee e persistenti
├── templates/           # Interfaccia web
├── static/              # Dashboard (JS, CSS, immagini)
├── db/                  # MariaDB container con dati IA
└── venv/               # Virtualenv python (non nel container)
```

Dettagli chiave:
- Struttura Flask: modulare con `create_app()` in `__init__.py`
- Entry-point: `/srv/maria/dio/app/wsgi.py`
- Codice agenti: `/srv/maria/dio/app/agents/`
- MCP server attivo su `dio.bedro.ch/mcp`

### **Componenti del Sistema**

- **LLM Locale**: Hermes 2 (Ollama)
- **API Esterne**: OpenAI GPT-4 (con chiave personale)
- **Agenti CrewAI disponibili**:
  - `shell_agent`
  - `docker_agent`
  - `code_agent`
  - `fs_agent`

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

1. **Bloccare versions compatibili nel requirements.txt**
2. **Separare ambiente sviluppo da quello containerizzato**
3. **Eliminare virtualenv dal volume bindato del container**
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

## 🚀 **Prossimi Passi e Obiettivi**

### Fase 1: Interpretazione intelligente del prompt
- Riconoscere la natura del prompt: spiegazione, fix, ricerca, creazione file/script, operazione Docker
- Associare il prompt a un agente esistente appropriato
- Utilizzare il contesto (cartella, output, file)

### Fase 2: Elaborazione e proposta
- Fornire risposte chiare e mirate
- Proporre azioni specifiche:
  - `esegui comando`
  - `genera file`
  - `applica patch`
  - `mostra spiegazione`
  - `apri documentazione`
- Gestire modalità manual/adhoc appropriatamente

### Fase 3: Output strutturato (Warp-friendly)
Implementare output JSON strutturato per Warp, esempio:
```json
{
  "reply": "Il container dio_web non espone la porta 5555. Puoi aggiungere '5555:5555' nel docker-compose.",
  "actions": [
    {
      "label": "Apri docker-compose.yml",
      "type": "open_file",
      "path": "/srv/maria/dio/docker-compose.yml"
    },
    {
      "label": "Modifica e riavvia stack",
      "type": "run_script",
      "path": "/srv/maria/dio/scripts/fix_ports.sh"
    }
  ],
  "mode": "manual"
}
```

### ⚠️ Misure di Sicurezza
- In modalità `adhoc`, richiedere conferma per comandi distruttivi (`rm`, `wipe`, `docker prune`)
- Implementare meccanismo di interruzione per ogni step automatico
- Mantenere log delle operazioni eseguite

---

## 🎯 **Architettura del Sistema Agentico**

### Core System
1. **Orchestratore Centrale (MarIA Core)**
   - Gestisce il ciclo di vita degli agenti
   - Mantiene il contesto globale
   - Coordina le comunicazioni tra agenti
   - Gestisce la memoria condivisa e il database

2. **Sistema di Memoria**
   - ChromaDB per memoria vettoriale
   - MariaDB per dati strutturati
   - Sistema di file per cache e dati temporanei

3. **Interfacce di Comunicazione**
   - MCP Server per comunicazioni esterne
   - Endpoint RESTful per tools esterni
   - WebSocket per comunicazioni real-time
   - CLI per interazioni dirette

### Agenti Specializzati
1. **Agenti di Sistema**
   - `shell_agent`: operazioni di sistema
   - `docker_agent`: gestione container
   - `fs_agent`: gestione filesystem
   - `code_agent`: analisi e modifica codice

2. **Agenti di Task**
   - `research_agent`: ricerche online
   - `email_agent`: gestione email
   - `scraping_agent`: estrazione dati web
   - `scheduler_agent`: pianificazione task

3. **Agenti di Monitoraggio**
   - `security_agent`: monitoraggio sicurezza
   - `resource_agent`: monitoraggio risorse
   - `log_agent`: analisi log
   - `health_agent`: stato del sistema

### Modalità Operative
1. **Modalità Autonoma**
   - Task scheduling automatico
   - Monitoraggio proattivo
   - Auto-ottimizzazione
   - Reporting periodico

2. **Modalità Assistita**
   - Risposta a comandi diretti
   - Suggerimenti proattivi
   - Validazione azioni critiche
   - Feedback in tempo reale

### Integrazioni Esterne
1. **Tools di Sviluppo**
   - VS Code via extensions
   - Warp Terminal
   - Git tools
   - CI/CD pipelines

2. **Servizi Cloud**
   - API OpenAI/GPT-4
   - Servizi di storage
   - Servizi di monitoring
   - Backup solutions

### Sicurezza e Controllo
- Autenticazione multi-factor
- Logging completo delle azioni
- Backup automatizzati
- Controlli di sicurezza
- Limitazioni su azioni critiche
- Modalità di recovery

## 🎯 **Obiettivo Finale: Terminal AI Assistant**

Come traguardo finale del progetto, si prevede lo sviluppo di un'applicazione terminale nativa simile a Warp (warp.dev), che integri completamente le capacità di MarIA. Questo obiettivo rappresenta l'evoluzione naturale del sistema, ma viene pianificato come fase successiva per permettere prima il consolidamento dell'infrastruttura core.

### Caratteristiche Previste
- **UI Terminal Nativa**: interfaccia terminale moderna e reattiva
- **Integrazione MarIA**: accesso diretto al sistema di agenti
- **Context-Aware**: comprensione del contesto del terminale in tempo reale
- **Smart Autocompletion**: suggerimenti intelligenti basati sul contesto
- **Command History**: storico comandi con ricerca semantica
- **AI Commands**: comandi speciali per interagire con MarIA
- **Real-Time Assistance**: suggerimenti e correzioni in tempo reale
- **Themeable**: temi e personalizzazione dell'interfaccia

### Priorità Attuali
Per raggiungere questo obiettivo, il focus immediato rimane su:
1. Stabilizzazione del core system MarIA
2. Perfezionamento del sistema di agenti
3. Ottimizzazione delle performance
4. Consolidamento dell'architettura di base

✍️ **Nota finale** Il sistema è progettato per essere modulare, sicuro e facilmente estensibile. Ogni agente opera in modo autonomo ma coordinato, contribuendo a un ecosistema intelligente che può sia assistere attivamente che operare in background secondo necessità. La visione finale include un'interfaccia terminale nativa che renderà l'interazione con MarIA ancora più naturale ed efficiente.

Pedro è il maintainer principale. Ogni modifica significativa deve mantenere coerenza con questa visione architettonica.

