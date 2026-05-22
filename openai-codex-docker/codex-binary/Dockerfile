# syntax=docker/dockerfile:1.24

ARG CODEX_VERSION=v0.133.0 # renovate: datasource=github-releases depName=spigell-codex-binary packageName=openai/codex
ARG DEBIAN_IMAGE_TAG=trixie-20260518 # renovate: datasource=docker depName=debian
ARG CODEX_TARBALL=codex-x86_64-unknown-linux-musl.tar.gz
ARG CODEX_BINARY_NAME=codex-x86_64-unknown-linux-musl
ARG CODEX_BASE_URL=https://github.com/openai/codex/releases/download

FROM debian:${DEBIAN_IMAGE_TAG} AS downloader

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
    && wget -qO /tmp/${CODEX_TARBALL} "${CODEX_BASE_URL}/rust-${CODEX_VERSION}/${CODEX_TARBALL}" \
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
