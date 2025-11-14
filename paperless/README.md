# paperless (Paperless-ngx)

**Stack**: paperless  
**Services**: paperless-web, paperless-db, paperless-redis  
**Ports**: 8400 (web interface)

## Components

- **paperless-web**: Paperless-ngx document management (latest)
- **paperless-db**: PostgreSQL 15 database
- **paperless-redis**: Redis 7 cache

## Volumes

- `/home/pedro/Documenti/IAuto/consume` → Document intake
- `/home/pedro/Documenti/IAuto/export` → Document export
- `/srv/cargo/volumes/paperless/data` → Application data
- `/srv/cargo/volumes/paperless/media` → Document storage
- `/srv/cargo/volumes/paperless/db` → PostgreSQL data

## Environment

- `PAPERLESS_URL`: https://doc.bedro.ch
- `PAPERLESS_ADMIN_USER`: admin
- `PAPERLESS_DBHOST`: paperless-db
- `PAPERLESS_REDIS`: redis://paperless-redis:6379
- `TZ`: Europe/Zurich

## Deployment

```bash
docker compose up -d
```

## Notes

All environment variables are embedded in docker-compose.yml (no separate .env files needed for Portainer import).
