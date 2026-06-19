# syntax=docker/dockerfile:1.25

ARG UNIVERSAL_WORKBENCH_IMAGE_TAG=sha-dev
ARG CODEX_BINARY_IMAGE=ghcr.io/spigell/codex-binary
ARG CODEX_BINARY_IMAGE_TAG=sha-dev

FROM ${CODEX_BINARY_IMAGE}:${CODEX_BINARY_IMAGE_TAG} AS codex

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_IMAGE_TAG}
LABEL codex.binary.ref="${CODEX_BINARY_IMAGE_TAG}"
LABEL org.opencontainers.image.title="OpenAI Codex Workbench" \
      org.opencontainers.image.description="Codex runtime layered on the universal workbench base image" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/openai-codex-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_IMAGE_TAG}"
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ENV CODEX_UNSAFE_ALLOW_NO_SANDBOX=1

RUN apt-get update \
 && apt-get install -y --no-install-recommends bubblewrap=0.9.0-1ubuntu0.1 \
 && rm -rf /var/lib/apt/lists/*

COPY --from=codex /usr/local/bin/codex /usr/local/bin/codex

RUN install -d /etc/codex
COPY config/config.toml /etc/codex/config.toml

USER ubuntu
ENV HOME=/home/ubuntu

ENTRYPOINT ["codex"]
