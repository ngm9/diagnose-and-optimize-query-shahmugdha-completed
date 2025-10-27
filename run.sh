#!/bin/bash
set -e

echo "[+] Starting PostgreSQL environment with docker-compose..."
docker-compose -f /root/task/docker-compose.yml up -d

# Wait for readiness
timeout=60
until docker exec insightsnow_pg pg_isready -U insightsuser -d insightsnowdb || [ $timeout -le 0 ]; do
  echo "[+] Waiting for PostgreSQL to be ready... ($timeout s left)"
  sleep 2
  timeout=$((timeout - 2))
done
if [ $timeout -le 0 ]; then
  echo "[-] Timeout: PostgreSQL did not start correctly."
  exit 1
fi

echo "[+] PostgreSQL service is running and ready."

if docker exec insightsnow_pg psql -U insightsuser -d insightsnowdb -c '\l'; then
  echo "[+] Database connection verified."
else
  echo "[-] Unable to connect to database."
  exit 1
fi
