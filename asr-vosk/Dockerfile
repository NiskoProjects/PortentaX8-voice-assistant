FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends sox libatomic1 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY asr-vosk/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY asr-vosk/server.py .
RUN mkdir -p ./models
CMD ["python","server.py"]
