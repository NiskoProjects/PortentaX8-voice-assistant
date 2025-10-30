#!/bin/bash
set -euo pipefail

echo "🧭 Starting Ubuntu orchestrator on Portenta X8..."
while ! docker info >/dev/null 2>&1; do
  echo "Waiting for Docker daemon..."
  sleep 2
done

if [ ! -f /workspace/docker-compose.yml ]; then
  echo "Linking compose file..."
  ln -sf /workspace/docker/docker-compose.yml /workspace/docker-compose.yml || true
fi

if [ -x /workspace/scripts/init_models.sh ]; then
  echo "🚀 Initializing models (idempotent)..."
  /workspace/scripts/init_models.sh || true
fi

/workspace/check_services.sh &
exec tail -f /dev/null
