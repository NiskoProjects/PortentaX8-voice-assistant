FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG COMPOSE_VERSION="v2.24.5"
RUN apt-get update && apt-get install -y \
    docker.io curl vim net-tools iputils-ping ca-certificates unzip \
    && mkdir -p /usr/lib/docker/cli-plugins /usr/local/bin \
    && curl -SL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-aarch64" \
       -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && cp /usr/local/bin/docker-compose /usr/lib/docker/cli-plugins/docker-compose \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY docker/orchestrator/orchestrator.sh /usr/local/bin/orchestrator.sh
COPY docker/orchestrator/check_services.sh /usr/local/bin/check_services.sh
RUN chmod +x /usr/local/bin/orchestrator.sh /usr/local/bin/check_services.sh

CMD ["/usr/local/bin/orchestrator.sh"]
