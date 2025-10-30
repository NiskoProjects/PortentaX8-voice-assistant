#!/usr/bin/env bash
set -euo pipefail
echo "[test_mic] Recording 2s to /var/assistant/audio/test.wav ..."
arecord -d 2 -f S16_LE -c1 -r 16000 /var/assistant/audio/test.wav
file /var/assistant/audio/test.wav || true
