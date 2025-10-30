#!/usr/bin/env bash
set -euo pipefail

# Ensure pulse runtime
mkdir -p /run/pulse
pulseaudio -D --system=false --disallow-exit --exit-idle-time=-1 \
  --log-target=stderr --load="module-native-protocol-unix" \
  --file=/app/pulse/system.pa || true

# Configure ALSA
sudo sh -c 'cp /app/alsa/asound.conf /etc/asound.conf' 2>/dev/null || true

# Probe audio & BT
/app/scripts/probe_audio.sh || true
/app/scripts/bt_autopair.sh || true

# Start arecord -> float32 fifo
rm -f /tmp/mic.f32
mkfifo /tmp/mic.f32 || true
( arecord -f S16_LE -c1 -r 16000 -q | sox -t raw -r 16000 -e signed-integer -b 16 -c 1 - -t raw -e floating-point -b 32 -c 1 - rate 16000 > /tmp/mic.f32 ) &

# Launch API
exec uvicorn main:app --host 0.0.0.0 --port "${AUDIO_GATEWAY_PORT:-8080}"
