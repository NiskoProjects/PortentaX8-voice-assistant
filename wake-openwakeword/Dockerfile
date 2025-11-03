FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends sox && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY wake-openwakeword/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY wake-openwakeword/server.py .
RUN mkdir -p ./models
CMD ["python","server.py"]
