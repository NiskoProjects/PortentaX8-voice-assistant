#!/bin/bash
set -euo pipefail

CMD=${1:-start}

if [ -f /workspace/docker/docker-compose.yml ]; then
  COMPOSE_FILE="/workspace/docker/docker-compose.yml"
else
  COMPOSE_FILE="docker/docker-compose.yml"
fi

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(docker compose -f "$COMPOSE_FILE")
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(docker-compose -f "$COMPOSE_FILE")
else
  echo "❌ Neither 'docker compose' nor 'docker-compose' is available." >&2
  exit 1
fi

compose() {
  "${COMPOSE_CMD[@]}" "$@"
}

case "$CMD" in
  start)
    compose up -d --build audio-gateway asr tts nlu
    ;;
  stop)
    compose down
    ;;
  logs)
    compose logs -f --tail=200
    ;;
  *)
    echo "Usage: ./scripts/run_stack.sh {start|stop|logs}"
    exit 1
    ;;
esac
