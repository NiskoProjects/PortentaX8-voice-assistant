import asyncio
import os

import numpy as np
import websockets
from openwakeword.model import Model

AUDIO_WS_URL = os.getenv("AUDIO_WS_URL", "ws://127.0.0.1:8080/audio/mic")
WAKE_WORD = os.getenv("WAKE_WORD", "hey_jarvis")  # Use built-in model
THRESH = float(os.getenv("WAKE_THRESHOLD", "0.5"))

print(f"[wake] connecting to {AUDIO_WS_URL}, wake_word={WAKE_WORD}, thresh={THRESH}")

# Use built-in pretrained model instead of custom file
model = Model(wakeword_models=[WAKE_WORD])


async def main():
    async with websockets.connect(AUDIO_WS_URL) as ws:
        while True:
            data = await ws.recv()
            audio = np.frombuffer(data, dtype=np.float32)
            scores = model.predict(audio)
            if scores and max(scores.values()) >= THRESH:
                print("[wake] Hey Nisko detected")
                await asyncio.sleep(0.7)


asyncio.run(main())
