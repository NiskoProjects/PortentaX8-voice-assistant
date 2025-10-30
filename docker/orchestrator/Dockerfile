FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG COMPOSE_VERSION="v2.24.5"
RUN apt-get update && apt-get install -y \
    docker.io curl vim net-tools iputils-ping ca-certificates unzip \
    && mkdir -p /usr/local/lib/docker/cli-plugins \
    && curl -SL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-arm64" \
       -o /usr/local/lib/docker/cli-plugins/docker-compose \
    && chmod +x /usr/local/lib/docker/cli-plugins/docker-compose \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY docker/orchestrator/orchestrator.sh /workspace/orchestrator.sh
COPY docker/orchestrator/check_services.sh /workspace/check_services.sh
COPY scripts /workspace/scripts
RUN chmod +x /workspace/orchestrator.sh /workspace/check_services.sh \
    && find /workspace/scripts -type f -name '*.sh' -exec chmod +x {} +

CMD ["/workspace/orchestrator.sh"]
