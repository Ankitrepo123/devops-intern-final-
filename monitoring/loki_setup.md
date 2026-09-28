# Loki Observability Setup

## Components

The observability stack consists of:

- Loki: log aggregation
- Promtail: Docker log collection and forwarding
- Grafana: log visualization and LogQL queries

## Startup

From the repository root:

```bash
docker compose -f monitoring/docker-compose.yaml up -d
