import time

import psutil
import requests
from fastapi import Body, FastAPI
from fastapi.responses import JSONResponse

NLU_URL = "http://127.0.0.1:9090"
TTS_URL = "http://127.0.0.1:8070/say"

app = FastAPI()


def do_action(action: dict) -> str:
    name = action.get("name")
    if name == "get_time":
        return time.strftime("The time is %H:%M.")
    if name == "system_status":
        cpu = psutil.cpu_percent()
        mem = psutil.virtual_memory().percent
        return f"CPU {cpu:.0f}% and memory {mem:.0f}%."
    if name == "say_back":
        return action.get("args", {}).get("text", "")
    return "I cannot do that."


@app.post("/query")
def query(payload=Body(...)):
    text = payload.get("text", "")
    nlu = requests.post(f"{NLU_URL}/nlu", json={"text": text}, timeout=5).json()
    reply = nlu.get("reply", "")
    action = nlu.get("action")
    if action:
        reply = do_action(action)
    try:
        requests.post(TTS_URL, json={"text": reply}, timeout=10)
    except requests.RequestException:
        pass
    return JSONResponse({"reply": reply})
