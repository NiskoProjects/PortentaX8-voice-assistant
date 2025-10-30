FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    docker.io docker-compose-plugin curl vim net-tools iputils-ping ca-certificates unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY docker/orchestrator/orchestrator.sh /workspace/orchestrator.sh
COPY docker/orchestrator/check_services.sh /workspace/check_services.sh
COPY scripts /workspace/scripts
RUN chmod +x /workspace/orchestrator.sh /workspace/check_services.sh \
    && find /workspace/scripts -type f -name '*.sh' -exec chmod +x {} +

CMD ["/workspace/orchestrator.sh"]
