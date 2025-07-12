# Istruzioni per Agenti AI nel Progetto MarIA

## Configurazione Linguistica
- Lingua principale: Italiano
- Documentazione: Preferibilmente in italiano
- Commenti nel codice: Italiano o inglese (mantenere coerenza con il file esistente)
- Output degli strumenti: Preservare la lingua originale

## Panoramica del Progetto
MarIA è un ecosistema di assistenti AI self-hosted su Ubuntu, progettato per la gestione intelligente di dispositivi e progetti. Il sistema è composto da più servizi containerizzati orchestrati tramite Docker e Portainer.

## Componenti Chiave

### Architettura del Servizio
- `dio_web`: Interfaccia web e API basate su Flask
- `dio_db`: Database MariaDB per la persistenza dei dati AI
- `dio_chroma`: Database vettoriale ChromaDB per la memoria AI
- `dio_mcp`: Server agent protocollo Model Context

### Tecnologie Core
- LLM: Ollama locale (Hermes 2) e OpenAI GPT-4
- Backend: Flask con agenti CrewAI
- Storage: MariaDB + ChromaDB
- Containerizzazione: Docker con orchestrazione Portainer

## Flusso di Lavoro per lo Sviluppo

### Struttura delle Directory
```
/srv/maria/dio/
├── app/                  # App Flask + cruscotto MCP
├── scripts/             # Script di sistema (ZSH, Python, Bash)
├── memory/             # Persistenza della memoria AI
├── templates/          # Interfaccia web
├── static/             # Risorse frontend
└── db/                # Storage del database
```

### Variabili d'Ambiente
Variabili critiche da configurare in Portainer:
- `DIO_DATA`: Percorso base per i dati dell'applicazione
- `PYTHON_CACHE`: Posizione della cache dei pacchetti Python
- `OPENAI_API_KEY`: Credenziali API OpenAI
- `DIO_DB_*`: Configurazione del database
- `MODEL_PROVIDER`: Selezione del fornitore LLM

### Build e Distribuzione
1. Le immagini sono costruite localmente come `dio_web:local`
2. Lo stack è distribuito tramite Portainer utilizzando un file compose sincronizzato con GitHub
3. I mount dei volumi preservano codice e dati al di fuori dei container

### Agenti e Automazione
Agenti CrewAI disponibili:
- `shell_agent`: Esecuzione di comandi di sistema
- `docker_agent`: Gestione dei container
- `code_agent`: Operazioni sul codice sorgente
- `fs_agent`: Operazioni sul filesystem

## Modelli Comuni

### Struttura degli Import
- Utilizzare importazioni relative all'interno dell'app Flask
- Esempio: `from agents...` non `from app.agents...`

### Controlli di Salute
Tutti i servizi implementano controlli di salute HTTP:
- `dio_web`: endpoint /health
- `dio_db`: ping mysqladmin
- `dio_chroma`: /api/v1/heartbeat
- `dio_mcp`: /health

### Gestione delle Risorse
I servizi hanno limiti di risorse definiti:
- Limiti di CPU e memoria configurati per servizio
- I servizi in background utilizzano riserve conservative
- Interfaccia web allocata con più risorse per reattività

## Risoluzione dei Problemi
1. Controllare lo stato di salute del servizio in Portainer
2. Verificare che le variabili d'ambiente siano impostate correttamente
3. Esaminare i log del servizio per errori di avvio
4. Assicurarsi che i permessi sui volumi montati siano corretti

## Migliori Pratiche
1. Utilizzare agenti CrewAI per compiti di automazione
2. Mantenere la compatibilità delle versioni tra le dipendenze
3. Testare le modifiche prima nell'ambiente di sviluppo
4. Seguire i modelli di controllo della salute stabiliti
