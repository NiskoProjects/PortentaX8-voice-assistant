#!/bin/bash
set -euo pipefail

if ! command -v docker >/dev/null; then
  echo "❌ Docker is required on the host. Please install and rerun."
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "❌ Docker Compose v2 is required. Please install and rerun."
  exit 1
fi

mkdir -p docker/orchestrator config models/vosk models/piper models/llm scripts

# Ensure host scripts are executable (handles Windows clones)
find scripts -type f -name '*.sh' -exec chmod +x {} +
find docker -type f -name '*.sh' -exec chmod +x {} +

cat > scripts/run_stack.sh <<'EOS'
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
EOS
chmod +x scripts/run_stack.sh

docker compose -f docker/docker-compose.yml up -d --build orchestrator

echo "✅ Orchestrator is up. Dropping into orchestrator shell..."
docker exec -it orchestrator bash -lc 'cd /workspace && ls -la && echo "Running apt-get update && apt-get upgrade -y..." && apt-get update && apt-get upgrade -y && echo "Downloading models via ./scripts/init_models.sh..." && ./scripts/init_models.sh && echo "Starting stack via ./scripts/run_stack.sh start..." && ./scripts/run_stack.sh start && echo "You are now inside the orchestrator shell." && exec bash'
