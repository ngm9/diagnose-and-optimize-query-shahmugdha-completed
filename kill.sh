#!/bin/bash
set -e

echo "[+] Stopping insightsnow_pg and cleaning up resources..."
docker-compose -f /root/task/docker-compose.yml down --volumes --remove-orphans || true

echo "[+] Removing PostgreSQL Docker image(s)..."
docker rmi -f postgres:15-alpine || true

rm -rf /root/task/data/pgdata || true

echo "[+] Pruning all unused Docker system resources..."
docker system prune -a --volumes -f || true

rm -rf /root/task || true

echo "[+] Cleanup completed successfully! Droplet is now clean."
