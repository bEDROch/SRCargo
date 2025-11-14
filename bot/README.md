# bot (Discord Bot)

**Stack**: bot  
**Services**: discord-bot  
**Ports**: None (Discord connection only)

## Components

- **discord-bot**: Custom Discord bot service

## Volumes

See docker-compose.yml for volume mappings.

## Deployment

```bash
docker compose up -d
```

## Notes

Requires Discord bot token configured via environment variables or mounted config.
