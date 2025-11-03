FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY nlu-llm/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY nlu-llm/orchestrator.py .
COPY nlu-llm/prompts/ ./prompts/
EXPOSE 9090
CMD ["python","orchestrator.py"]
