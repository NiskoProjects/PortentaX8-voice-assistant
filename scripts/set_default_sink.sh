#!/usr/bin/env bash
set -euo pipefail

docker exec -it audio-gateway bash -lc 'S=$(pactl list short sinks | awk "{print $2}" | grep -i bluez | head -n1); [ -n "$S" ] && pactl set-default-sink "$S" && echo "Default sink: $S" || echo "No BT sink"'
