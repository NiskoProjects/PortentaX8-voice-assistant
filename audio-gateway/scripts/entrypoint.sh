#!/usr/bin/env bash
set -euo pipefail

echo "[audio-gateway] Starting with line-in mic and headphone jack output"

# Configure ALSA for line-in and headphone jack
sudo sh -c 'cp /app/alsa/asound.conf /etc/asound.conf' 2>/dev/null || true

# Probe audio devices
/app/scripts/probe_audio.sh || true

# Start arecord from line-in -> float32 fifo
rm -f /tmp/mic.f32
mkfifo /tmp/mic.f32 || true
echo "[audio-gateway] Starting microphone capture from line-in (hw:0,0)"
( arecord -D hw:0,0 -f S16_LE -c1 -r 16000 -q | sox -t raw -r 16000 -e signed-integer -b 16 -c 1 - -t raw -e floating-point -b 32 -c 1 - rate 16000 > /tmp/mic.f32 ) &

# Launch API
echo "[audio-gateway] Starting API server on port ${AUDIO_GATEWAY_PORT:-8080}"
exec uvicorn main:app --host 0.0.0.0 --port "${AUDIO_GATEWAY_PORT:-8080}"
