# syntax=docker/dockerfile:1.18

ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG CODEX_BINARY_REF=rust-v0.80.0
ARG SPLITRAIL_VERSION=3.2.2

FROM ghcr.io/spigell/codex-binary:${CODEX_BINARY_REF} AS codex

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
LABEL codex.binary.ref="${CODEX_BINARY_REF}"
LABEL org.opencontainers.image.title="OpenAI Codex Workbench" \
      org.opencontainers.image.description="Codex runtime layered on the universal workbench base image" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/openai-codex-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_TAG}"
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ARG SPLITRAIL_VERSION

USER root
ENV HOME=/root

ENV CODEX_UNSAFE_ALLOW_NO_SANDBOX=1

RUN ARCHIVE="splitrail-v${SPLITRAIL_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
 && ARCHDIR="splitrail-v${SPLITRAIL_VERSION}-x86_64-unknown-linux-gnu" \
 && curl -fsSL "https://github.com/Piebald-AI/splitrail/releases/download/v${SPLITRAIL_VERSION}/${ARCHIVE}" -o "/tmp/${ARCHIVE}" \
 && tar -xvf "/tmp/${ARCHIVE}" -C /tmp \
 && install -m 0755 "/tmp/${ARCHDIR}/splitrail" /usr/local/bin/splitrail \
 && rm -rf "/tmp/${ARCHIVE}" "/tmp/${ARCHDIR}"

COPY --from=codex /usr/local/bin/codex /usr/local/bin/codex

RUN install -d /etc/codex
COPY config/config.toml /etc/codex/config.toml

USER ubuntu
ENV HOME=/home/ubuntu

ENTRYPOINT ["codex"]
