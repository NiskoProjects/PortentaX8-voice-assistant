#!/usr/bin/env bash
set -euo pipefail

docker compose up -d
echo "Services up. Check health:"
curl -s http://127.0.0.1:${AUDIO_GATEWAY_PORT:-8080}/health || true
curl -s http://127.0.0.1:8071/health || true
curl -s http://127.0.0.1:8070/health || true
