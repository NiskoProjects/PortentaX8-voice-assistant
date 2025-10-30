#!/bin/bash
set -euo pipefail
SERVICES=(vosk piper llm probe)

echo "🔌 Service monitor started..."
while true; do
  for SVC in "${SERVICES[@]}"; do
    STATUS=$(docker inspect -f '{{.State.Running}}' "$SVC" 2>/dev/null || echo false)
    if [ "$STATUS" != "true" ]; then
      echo "⚠️  Service $SVC not running. Restarting..."
      docker compose -f /workspace/docker-compose.yml up -d "$SVC" || true
    fi
  done
  sleep 15
done
