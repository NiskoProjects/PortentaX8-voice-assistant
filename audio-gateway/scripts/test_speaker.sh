#!/usr/bin/env bash
set -euo pipefail
echo "[test_speaker] Generating 440Hz sine for 1s"
sox -n -t raw -r 16000 -e signed-integer -b 16 -c 1 - synth 1 sine 440 | \
  curl -sS -X POST --data-binary @- http://127.0.0.1:${AUDIO_GATEWAY_PORT:-8080}/audio/play
echo
