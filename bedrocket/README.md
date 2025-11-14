# bedrocket (Rocket.Chat)

**Stack**: bedrocket  
**Services**: rocketchat, mongo  
**Ports**: 3000 (Rocket.Chat web)

## Components

- **rocketchat**: Rocket.Chat messaging platform (latest)
- **mongo**: MongoDB 6.0 database

## Volumes

- `/srv/cargo/volumes/rocketchat/uploads` → Rocket.Chat uploads
- `/srv/cargo/volumes/rocketchat/configdb` → MongoDB config
- `/srv/cargo/volumes/rocketchat/mongodb` → MongoDB data

## Environment

- `ROOT_URL`: http://localhost:3000
- `MONGO_URL`: mongodb://mongo:27017/rocketchat
- `TZ`: Europe/Zurich

## Deployment

```bash
docker compose up -d
```

## Portainer Import

Use **Web editor** method (not file upload) to import this stack in Portainer 2.27.9 LTS.
