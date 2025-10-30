#!/usr/bin/env bash
set -euo pipefail

docker exec -it audio-gateway /app/scripts/bt_autopair.sh
