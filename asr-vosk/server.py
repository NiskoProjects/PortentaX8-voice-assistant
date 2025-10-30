import asyncio
import json
import os
import queue
import threading

import numpy as np
import websockets
from fastapi import FastAPI
from fastapi.responses import JSONResponse
from vosk import KaldiRecognizer, Model

AUDIO_WS_URL = os.getenv("AUDIO_WS_URL", "ws://127.0.0.1:8080/audio/mic")
MODEL_DIR = os.getenv("VOSK_MODEL", "/app/models/vosk-model-small-en-us-0.15")
RATE = 16000

print(f"[asr] loading model {MODEL_DIR}")
model = Model(MODEL_DIR)
rec = KaldiRecognizer(model, RATE)
rec.SetWords(True)

buf: "queue.Queue[bytes]" = queue.Queue(maxsize=50)
app = FastAPI()
last_text = ""


@app.get("/health")
def health():
    return {"ok": True}


@app.post("/transcribe_once")
def transcribe_once():
    return JSONResponse({"text": last_text})


def consume():
    global last_text
    while True:
        audio = buf.get()
        if rec.AcceptWaveform(audio):
            res = json.loads(rec.Result())
            last_text = res.get("text", "")
            if last_text:
                print("[asr] final:", last_text)


async def produce():
    async with websockets.connect(AUDIO_WS_URL) as ws:
        while True:
            data = await ws.recv()
            f32 = np.frombuffer(data, dtype=np.float32)
            s16 = (np.clip(f32, -1.0, 1.0) * 32767.0).astype(np.int16).tobytes()
            try:
                buf.put_nowait(s16)
            except queue.Full:
                pass


def main():
    threading.Thread(target=consume, daemon=True).start()
    loop = asyncio.get_event_loop()
    loop.create_task(produce())
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8071)


if __name__ == "__main__":
    main()
