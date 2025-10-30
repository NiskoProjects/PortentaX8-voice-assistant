#!/bin/bash
set -euo pipefail
CMD=${1:-start}
case "$CMD" in
  start)
    docker exec -it orchestrator bash -lc "docker compose -f /workspace/docker-compose.yml up -d vosk piper llm probe"
    ;;
  stop)
    docker exec -it orchestrator bash -lc "docker compose -f /workspace/docker-compose.yml down"
    ;;
  logs)
    docker exec -it orchestrator bash -lc "docker compose -f /workspace/docker-compose.yml logs -f --tail=200"
    ;;
  *)
    echo "Usage: ./scripts/run_stack.sh {start|stop|logs}"
    exit 1
    ;;
esac
