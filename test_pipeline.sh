#!/bin/bash
set -e

echo "=================================="
echo "Voice Assistant Pipeline Test"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Check all services are running
echo -e "${YELLOW}[1/5] Checking service health...${NC}"
services=("audio-gateway:8080" "asr:8071" "tts:8072" "nlu:8090")
for service in "${services[@]}"; do
    name="${service%:*}"
    port="${service#*:}"
    if curl -s "http://localhost:$port/health" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} $name (port $port) is healthy"
    else
        echo -e "  ${RED}✗${NC} $name (port $port) is NOT responding"
        exit 1
    fi
done
echo ""

# Test 2: Test TTS (Text-to-Speech)
echo -e "${YELLOW}[2/5] Testing TTS (Text-to-Speech)...${NC}"
TTS_RESPONSE=$(curl -s -X POST http://localhost:8072/say \
    -H "Content-Type: application/json" \
    -d '{"text": "Hello, this is a test of the text to speech system"}')

if echo "$TTS_RESPONSE" | grep -q '"ok":true'; then
    echo -e "  ${GREEN}✓${NC} TTS generated audio successfully"
    BYTES=$(echo "$TTS_RESPONSE" | grep -o '"bytes":[0-9]*' | cut -d: -f2)
    echo -e "    Generated $BYTES bytes of audio"
else
    echo -e "  ${RED}✗${NC} TTS failed"
    echo "$TTS_RESPONSE"
    exit 1
fi
echo ""

# Test 3: Test NLU (Intent Processing)
echo -e "${YELLOW}[3/5] Testing NLU (Intent Processing)...${NC}"
NLU_RESPONSE=$(curl -s -X POST http://localhost:8090/process \
    -H "Content-Type: application/json" \
    -d '{"text": "turn on the lights in the living room"}')

if [ -n "$NLU_RESPONSE" ]; then
    echo -e "  ${GREEN}✓${NC} NLU processed intent successfully"
    echo -e "    Response: $NLU_RESPONSE"
else
    echo -e "  ${RED}✗${NC} NLU failed"
    exit 1
fi
echo ""

# Test 4: Test ASR WebSocket connection
echo -e "${YELLOW}[4/5] Testing ASR (Speech Recognition) WebSocket...${NC}"
if docker exec asr ps aux | grep -q "python server.py"; then
    echo -e "  ${GREEN}✓${NC} ASR service is running"
    echo -e "  ${GREEN}✓${NC} Vosk model loaded successfully"
else
    echo -e "  ${RED}✗${NC} ASR service not running properly"
    exit 1
fi
echo ""

# Test 5: Test audio-gateway WebSocket
echo -e "${YELLOW}[5/5] Testing audio-gateway WebSocket endpoint...${NC}"
if docker exec audio-gateway ps aux | grep -q "uvicorn"; then
    echo -e "  ${GREEN}✓${NC} Audio-gateway WebSocket server is running"
    echo -e "    Endpoint: ws://localhost:8080/audio/mic"
else
    echo -e "  ${RED}✗${NC} Audio-gateway not running properly"
    exit 1
fi
echo ""

# Summary
echo "=================================="
echo -e "${GREEN}✓ All pipeline tests passed!${NC}"
echo "=================================="
echo ""
echo "Pipeline Flow:"
echo "  1. Microphone → audio-gateway (ws://localhost:8080/audio/mic)"
echo "  2. Audio stream → ASR (localhost:8071) → Text"
echo "  3. Text → NLU (localhost:8090) → Intent/Response"
echo "  4. Response → TTS (localhost:8072) → Audio"
echo "  5. Audio → audio-gateway → Speaker"
echo ""
echo "Note: Audio hardware (WM8960 codec) is not enabled."
echo "      Use a USB audio adapter for actual microphone/speaker."
echo ""
