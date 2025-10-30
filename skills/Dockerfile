FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY skills_server.py .
COPY skills/ ./skills/
EXPOSE 8072
CMD ["python","skills_server.py"]
