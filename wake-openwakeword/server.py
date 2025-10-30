import asyncio
import os

import numpy as np
import websockets
from openwakeword.model import Model

AUDIO_WS_URL = os.getenv("AUDIO_WS_URL", "ws://127.0.0.1:8080/audio/mic")
MODEL_PATH = os.getenv("WAKE_MODEL", "/app/models/hey-nisko.onnx")
THRESH = float(os.getenv("WAKE_THRESHOLD", "0.5"))

print(f"[wake] connecting to {AUDIO_WS_URL}, model={MODEL_PATH}, thresh={THRESH}")

model = Model(wakeword_models=[MODEL_PATH])


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
