# Portenta X8 Voice Assistant (All Local, Docker)

A fully local voice assistant running on Arduino Portenta X8 with all processing done on-device.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Portenta X8 Host                        │
│                                                             │
│  ┌──────────────┐                                          │
│  │ Orchestrator │ (Docker-in-Docker manager)               │
│  │  Container   │                                          │
│  └──────┬───────┘                                          │
│         │ manages via /var/run/docker.sock                 │
│         │                                                   │
│  ┌──────▼────────────────────────────────────────────┐    │
│  │         Service Containers (siblings)              │    │
│  │                                                     │    │
│  │  ┌─────────────┐  ┌──────┐  ┌──────┐  ┌──────┐  │    │
│  │  │audio-gateway│  │ ASR  │  │ TTS  │  │ NLU  │  │    │
│  │  │   :8080     │  │:8071 │  │:8072 │  │:8090 │  │    │
│  │  └──────┬──────┘  └───┬──┘  └───┬──┘  └───┬──┘  │    │
│  │         │             │         │         │       │    │
│  │    WebSocket      Vosk API  Piper API  LLM API   │    │
│  └─────────┼─────────────┼─────────┼─────────┼──────┘    │
│            │             │         │         │            │
│       Mic Stream    Text→Audio  Audio→Text  Intent       │
└────────────┼─────────────┼─────────┼─────────┼───────────┘
             │             │         │         │
        Line-in/USB    localhost  localhost localhost
```

## Components

- **Wake Word**: OpenWakeWord (disabled by default, needs model)
- **ASR (Speech Recognition)**: Vosk (small en-US model)
- **NLU (Intent Processing)**: Local LLM via llama.cpp (Qwen2.5-0.5B-Instruct)
- **TTS (Text-to-Speech)**: Piper (en_US-amy-medium voice)
- **Audio Gateway**: FastAPI WebSocket server for audio I/O
- **Orchestrator**: Docker-in-Docker container managing all services

## Quick Start

### 1. Clone and Setup
```bash
git clone https://github.com/NiskoProjects/PortentaX8-voice-assistant
cd PortentaX8-voice-assistant
```

### 2. Start the Voice Assistant
```bash
# On Portenta X8
./scripts/bootstrap.sh
```

This will:
- Build the orchestrator container
- Download required models (Vosk, Piper, LLM)
- Start all voice assistant services
- Enter orchestrator shell

### 3. Manage Services
```bash
# Inside orchestrator shell
cd /workspace

# Start all services
./scripts/run_stack.sh start

# View logs
./scripts/run_stack.sh logs

# Stop services
./scripts/run_stack.sh stop
```

### 4. Test the Pipeline
```bash
# On Portenta host
./test_pipeline.sh
```

## Service Details

### Audio Gateway (Port 8080)
- **WebSocket**: `ws://localhost:8080/audio/mic` - Audio stream from microphone
- **HTTP POST**: `http://localhost:8080/audio/play` - Play audio to speaker
- **Health**: `http://localhost:8080/health`

### ASR - Vosk (Port 8071)
- Converts audio stream to text
- Uses Vosk small English model
- **Health**: `http://localhost:8071/health`

### TTS - Piper (Port 8072)
- Converts text to speech audio
- Uses en_US-amy-medium voice
- **POST**: `http://localhost:8072/say` with `{"text": "..."}`
- **Health**: `http://localhost:8072/health`

### NLU - LLM (Port 8090)
- Processes text for intent understanding
- Uses local Qwen2.5 model
- **POST**: `http://localhost:8090/process` with `{"text": "..."}`
- **Health**: `http://localhost:8090/health`

## Audio Hardware

**Note**: The Portenta X8 MAX Carrier's WM8960 codec is not enabled by default in the standard Linux-microPlatform image.

**Options**:
1. **USB Audio Adapter** (Recommended): Plug in a USB audio adapter with mic and headphone jacks
2. **Enable WM8960**: Requires custom device tree overlay (contact Arduino support)
3. **HDMI Audio**: Currently configured but limited functionality

The voice assistant services work correctly; only the audio hardware interface needs configuration.

## Pipeline Flow

1. **Audio Input**: Microphone → audio-gateway WebSocket
2. **Speech Recognition**: Audio stream → ASR (Vosk) → Text
3. **Intent Processing**: Text → NLU (LLM) → Response
4. **Speech Synthesis**: Response → TTS (Piper) → Audio
5. **Audio Output**: Audio → audio-gateway → Speaker

## Directory Structure

```
PortentaX8-voice-assistant/
├── audio-gateway/          # Audio I/O service
├── asr-vosk/              # Speech recognition service
├── tts-piper/             # Text-to-speech service
├── nlu-llm/               # Intent processing service
├── wake-openwakeword/     # Wake word detection (optional)
├── docker/
│   ├── orchestrator/      # Container manager
│   └── docker-compose.yml # Service definitions
├── scripts/
│   ├── bootstrap.sh       # Initial setup
│   ├── run_stack.sh       # Service management
│   └── init_models.sh     # Model downloads
├── models/                # AI models (downloaded)
│   ├── vosk/
│   ├── piper/
│   └── llm/
└── test_pipeline.sh       # Integration test
```

## Troubleshooting

### Services not starting
```bash
# Check orchestrator logs
docker logs orchestrator

# Rebuild services
docker exec -it orchestrator bash
cd /workspace
./scripts/run_stack.sh stop
./scripts/run_stack.sh start
```

### ASR model not loading
```bash
# Verify model files exist
ls -la ~/LA/PortentaX8-voice-assistant/models/vosk/model/
# Should show: am/ conf/ graph/ ivector/ README
```

### No audio output
```bash
# Check audio devices
aplay -l
arecord -l

# Test with USB audio adapter if available
```

## Development

### Viewing Logs
```bash
# All services
docker-compose -f /workspace/docker/docker-compose.yml logs -f

# Specific service
docker logs asr -f
docker logs tts -f
```

### Rebuilding a Service
```bash
docker exec -it orchestrator bash
cd /workspace
docker-compose -f docker/docker-compose.yml up -d --build asr
```

## Status

✅ **Working**:
- All 4 core services running
- ASR with Vosk model loaded
- TTS with Piper voice
- NLU with local LLM
- Audio-gateway API endpoints
- Docker orchestration

⚠️ **Known Issues**:
- WM8960 audio codec not enabled (hardware limitation)
- Wake word service disabled (needs model configuration)
- Audio requires USB adapter or codec enablement

## License

MIT
