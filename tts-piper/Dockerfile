FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY server.py .
COPY voices/ ./voices/
EXPOSE 8070
CMD ["python","server.py"]
