#!/usr/bin/env bash
set -euo pipefail
echo "[probe_audio] Listing capture devices..."
arecord -l || true

CARD_ID=$(arecord -l | awk '/card /{print $2}' | tr -d ':' | head -n1)
if [ -n "${CARD_ID:-}" ]; then
  echo "[probe_audio] Using card ${CARD_ID}"
  sed -i "s/card 0/card ${CARD_ID}/" /etc/asound.conf || true
else
  echo "[probe_audio] Could not auto-detect; keeping defaults."
fi
