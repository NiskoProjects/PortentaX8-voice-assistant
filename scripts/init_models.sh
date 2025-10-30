#!/usr/bin/env bash
set -euo pipefail
mkdir -p asr-vosk/models tts-piper/voices nlu-llm/models

# Vosk small EN
cd asr-vosk/models
if [ ! -d "vosk-model-small-en-us-0.15" ]; then
  wget -q https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip
  unzip -q vosk-model-small-en-us-0.15.zip
  rm -f vosk-model-small-en-us-0.15.zip
fi
cd - >/dev/null

# Piper voice + binary
cd tts-piper/voices
if [ ! -f "piper" ]; then
  wget -q https://github.com/rhasspy/piper/releases/download/v0.0.2/piper_linux_x86_64.tar.gz || true
  tar -xf piper_linux_x86_64.tar.gz || true
  mv piper_linux_x86_64/piper piper || true
  rm -rf piper_linux_x86_64 piper_linux_x86_64.tar.gz || true
fi
if [ ! -f "en_US-amy-low.onnx" ]; then
  wget -q https://github.com/rhasspy/piper/releases/download/v0.0.2/en_US-amy-low.onnx
fi
cd - >/dev/null

echo "Models ready."
