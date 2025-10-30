# Portenta X8 Voice Assistant (All Local, Docker)

Components:
- Wake word: OpenWakeWord ("Hey Nisko")
- ASR: Vosk (small en-US)
- NLU: tiny local LLM via llama.cpp (Qwen2.5-0.5B-Instruct Q4_K_M)
- TTS: Piper (small English voice)
- Audio: audio-gateway container with ALSA + Pulse; robust mic/BT pairing
- All internal (no MQTT)

## Quick start
```bash
cp .env.example .env
# set BT_SPEAKER_MAC if known
./scripts/init_models.sh
docker compose build
./scripts/dev_up.sh
# test audio
docker exec -it audio-gateway /app/scripts/test_mic.sh
docker exec -it audio-gateway /app/scripts/test_speaker.sh
```
