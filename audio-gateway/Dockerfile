FROM debian:stable-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    pulseaudio pulseaudio-utils bluez alsa-utils python3 python3-pip python3-venv \
    dbus curl socat jq procps && \
    rm -rf /var/lib/apt/lists/*
RUN adduser --system --group --home /app assistant && usermod -aG audio assistant
USER assistant
WORKDIR /app
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt
COPY main.py ./main.py
COPY alsa/ ./alsa/
COPY pulse/ ./pulse/
COPY scripts/ ./scripts/
ENV XDG_RUNTIME_DIR=/run/pulse
ENTRYPOINT ["/app/scripts/entrypoint.sh"]
