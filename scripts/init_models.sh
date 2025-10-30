#!/bin/bash
set -euo pipefail
mkdir -p /workspace/models/vosk /workspace/models/piper /workspace/models/llm

if [ ! -d /workspace/models/vosk/model ]; then
  echo "⬇️  Downloading Vosk small-en model..."
  curl -L -o /tmp/vosk.zip https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip
  unzip -q /tmp/vosk.zip -d /workspace/models/vosk
  mv /workspace/models/vosk/vosk-model-small-en-us-0.15 /workspace/models/vosk/model
  rm -f /tmp/vosk.zip
fi

if [ ! -f /workspace/models/piper/en_US-amy-medium.onnx ]; then
  echo "⬇️  Downloading Piper voice en_US-amy-medium..."
  curl -L -o /workspace/models/piper/en_US-amy-medium.onnx \
    https://github.com/rhasspy/piper/releases/download/v1.2.0/en_US-amy-medium.onnx
fi

if [ ! -f /workspace/models/llm/tiny.gguf ]; then
  echo "⬇️  Downloading tiny GGUF (placeholder)..."
  curl -L -o /workspace/models/llm/tiny.gguf \
    https://huggingface.co/sshleifer/tiny-gpt2/resolve/main/pytorch_model.bin?download=true || true
fi

echo "✅ Models initialized."
