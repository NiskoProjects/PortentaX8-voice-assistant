FROM debian:stable-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    pulseaudio pulseaudio-utils alsa-utils python3 python3-pip python3-venv \
    sox curl socat jq procps sudo && \
    rm -rf /var/lib/apt/lists/*
RUN adduser --system --group --home /app assistant && usermod -aG audio assistant
RUN echo "assistant ALL=(ALL) NOPASSWD: /bin/sh" >> /etc/sudoers
USER assistant
WORKDIR /app
COPY audio-gateway/requirements.txt .
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt
COPY audio-gateway/main.py ./main.py
COPY audio-gateway/alsa/ ./alsa/
COPY audio-gateway/pulse/ ./pulse/
COPY audio-gateway/scripts/ ./scripts/
RUN chmod +x ./scripts/*.sh
ENV XDG_RUNTIME_DIR=/run/pulse
ENTRYPOINT ["/app/scripts/entrypoint.sh"]
