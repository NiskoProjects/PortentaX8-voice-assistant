import os
import subprocess
import tempfile

from fastapi import Body, FastAPI
from fastapi.responses import JSONResponse

VOICE = os.getenv("PIPER_VOICE", "en_US-amy-low")
AUDIO_PLAY_URL = os.getenv("AUDIO_PLAY_URL", "http://127.0.0.1:8080/audio/play")
PIPER_BIN = "/app/voices/piper"

app = FastAPI()


@app.get("/health")
def health():
    return {"ok": True, "voice": VOICE}


@app.post("/say")
def say(payload=Body(...)):
    text = payload.get("text", "").strip()
    if not text:
        return JSONResponse({"ok": False, "err": "empty"}, status_code=400)
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
        out = f.name
    subprocess.run([PIPER_BIN, "-m", f"/app/voices/{VOICE}.onnx", "-f", out, "-t", text], check=True)
    with open(out, "rb") as fh:
        pcm = fh.read()
    try:
        import requests

        requests.post(AUDIO_PLAY_URL, data=pcm, timeout=5)
    finally:
        os.unlink(out)
    return JSONResponse({"ok": True, "bytes": len(pcm)})


if __name__ == "__main__":
    import uvicorn

    print(f"[tts] Starting Piper TTS server, voice={VOICE}")
    uvicorn.run(app, host="0.0.0.0", port=8072)
