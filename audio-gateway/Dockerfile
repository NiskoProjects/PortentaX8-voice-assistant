FROM debian:stable-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    alsa-utils python3 python3-pip \
    sox curl socat jq procps sudo && \
    rm -rf /var/lib/apt/lists/*
RUN adduser --system --group --home /app assistant && usermod -aG audio assistant
RUN echo "assistant ALL=(ALL) NOPASSWD: /bin/sh" >> /etc/sudoers
WORKDIR /app
COPY audio-gateway/requirements.txt .
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt
COPY audio-gateway/main.py ./main.py
COPY audio-gateway/alsa/ ./alsa/
COPY audio-gateway/pulse/ ./pulse/
COPY audio-gateway/scripts/ ./scripts/
RUN chmod +x ./scripts/*.sh && chown -R assistant:assistant /app
USER assistant
ENV PATH="/usr/local/bin:${PATH}"
ENTRYPOINT ["/app/scripts/entrypoint.sh"]
