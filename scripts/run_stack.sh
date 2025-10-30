#!/bin/bash
set -euo pipefail

CMD=${1:-start}

if [ -f /workspace/docker/docker-compose.yml ]; then
  COMPOSE_FILE="/workspace/docker/docker-compose.yml"
else
  COMPOSE_FILE="docker/docker-compose.yml"
fi

compose() {
  docker compose -f "$COMPOSE_FILE" "$@"
}

case "$CMD" in
  start)
    compose up -d vosk piper llm probe
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
