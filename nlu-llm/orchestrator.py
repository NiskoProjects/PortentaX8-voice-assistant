import json
import os

from fastapi import Body, FastAPI
from fastapi.responses import JSONResponse

PORT = int(os.getenv("NLU_HTTP_PORT", "9090"))
LLM_MODEL = os.getenv("LLM_MODEL", "/models/qwen2.5-0.5b-instruct-q4_k_m.gguf")


def tiny_infer(prompt: str) -> str:
    prompt_l = prompt.lower()
    if "time" in prompt_l:
        return json.dumps({"reply": "It's handled by the skills module.", "action": {"name": "get_time", "args": {}}})
    if "status" in prompt_l:
        return json.dumps({"reply": "Checking system status.", "action": {"name": "system_status", "args": {}}})
    if prompt.strip():
        return json.dumps({"reply": prompt.strip(), "action": {"name": "say_back", "args": {"text": prompt.strip()}}})
    return json.dumps({"reply": "I didn't catch that.", "action": None})


app = FastAPI()


@app.post("/nlu")
def nlu(payload=Body(...)):
    text = payload.get("text", "").strip()
    with open("prompts/system.txt", "r", encoding="utf-8") as fh:
        sys = fh.read()
    merged = sys + "\nUser: " + text
    raw = tiny_infer(merged)
    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        data = {"reply": "(fallback)", "action": None}
    return JSONResponse(data)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=PORT)
