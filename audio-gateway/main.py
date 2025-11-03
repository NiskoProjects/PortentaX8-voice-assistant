import os
import asyncio
import json
import subprocess
import tempfile
from typing import Set

import numpy as np
from fastapi import FastAPI, WebSocket
from fastapi.responses import JSONResponse
from starlette.websockets import WebSocketDisconnect

app = FastAPI()
clients: Set[WebSocket] = set()
AUDIO_RATE = 16000


@app.get("/health")
def health():
    return {"ok": True}


@app.websocket("/audio/mic")
async def mic_stream(ws: WebSocket):
    await ws.accept()
    clients.add(ws)
    fifo = "/tmp/mic.f32"
    try:
        while True:
            await asyncio.sleep(0.02)
            try:
                with open(fifo, "rb", buffering=0) as f:
                    data = f.read(3200)
                    if data:
                        await ws.send_bytes(data)
            except FileNotFoundError:
                await asyncio.sleep(0.1)
    except WebSocketDisconnect:
        pass
    finally:
        clients.discard(ws)


@app.post("/audio/play")
async def audio_play(raw: bytes):
    with tempfile.NamedTemporaryFile(delete=False) as f:
        f.write(raw)
        path = f.name
    try:
        # Play to headphone jack using ALSA
        subprocess.run(
            [
                "aplay",
                "-D", "hw:0,0",
                "-f", "S16_LE",
                "-r", "16000",
                "-c", "1",
                "-q",
                path,
            ],
            check=False,
        )
    finally:
        os.unlink(path)
    return JSONResponse({"played": True})
