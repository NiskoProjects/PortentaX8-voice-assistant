#!/usr/bin/env bash
set -euo pipefail
arecord -d 5 -f S16_LE -c1 -r 16000 /var/assistant/audio/rec5s.wav
