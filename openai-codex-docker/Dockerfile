# syntax=docker/dockerfile:1.18

ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG CODEX_BINARY_REF=rust-v0.63.0

FROM ghcr.io/spigell/codex-binary:${CODEX_BINARY_REF} AS codex

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
LABEL codex.binary.ref="${CODEX_BINARY_REF}"
LABEL org.opencontainers.image.title="OpenAI Codex Workbench" \
      org.opencontainers.image.description="Codex runtime layered on the universal workbench base image" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/openai-codex-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_TAG}"
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ENV CODEX_UNSAFE_ALLOW_NO_SANDBOX=1

COPY --from=codex /usr/local/bin/codex /usr/local/bin/codex

USER ubuntu
ENV HOME=/home/ubuntu

ENTRYPOINT ["codex"]
