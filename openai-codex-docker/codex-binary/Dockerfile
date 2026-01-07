# syntax=docker/dockerfile:1.4

ARG CODEX_VERSION=rust-v0.78.0
ARG CODEX_TARBALL=codex-x86_64-unknown-linux-gnu.tar.gz
ARG CODEX_BINARY_NAME=codex-x86_64-unknown-linux-gnu
ARG CODEX_BASE_URL=https://github.com/openai/codex/releases/download

FROM ubuntu:24.04 AS downloader

ARG CODEX_VERSION
ARG CODEX_TARBALL
ARG CODEX_BINARY_NAME
ARG CODEX_BASE_URL

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/codex \
    && wget -qO /tmp/${CODEX_TARBALL} "${CODEX_BASE_URL}/${CODEX_VERSION}/${CODEX_TARBALL}" \
    && tar -xzf /tmp/${CODEX_TARBALL} -C /tmp \
    && install -m 0755 /tmp/${CODEX_BINARY_NAME} /opt/codex/codex \
    && rm -rf /tmp/${CODEX_TARBALL} /tmp/${CODEX_BINARY_NAME}

FROM scratch

ARG CODEX_VERSION
LABEL org.opencontainers.image.title="Codex Binary" \
      org.opencontainers.image.description="Slim container image that packages the Codex binary for reuse" \
      org.opencontainers.image.version="${CODEX_VERSION}"

COPY --from=downloader /opt/codex/codex /usr/local/bin/codex

ENTRYPOINT ["/usr/local/bin/codex"]
