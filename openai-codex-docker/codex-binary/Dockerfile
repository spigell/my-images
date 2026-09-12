# syntax=docker/dockerfile:1.27

ARG CODEX_VERSION=v0.154.0 # renovate: datasource=github-releases depName=spigell-codex-binary packageName=openai/codex
ARG DEBIAN_IMAGE_TAG=trixie-20260713 # renovate: datasource=docker depName=debian
ARG CODEX_TARBALL=codex-x86_64-unknown-linux-musl.tar.gz
ARG CODEX_BINARY_NAME=codex-x86_64-unknown-linux-musl
ARG CODEX_CODE_MODE_HOST_TARBALL=codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz
ARG CODEX_CODE_MODE_HOST_BINARY_NAME=codex-code-mode-host-x86_64-unknown-linux-musl
ARG CODEX_BASE_URL=https://github.com/openai/codex/releases/download

FROM debian:${DEBIAN_IMAGE_TAG} AS downloader

ARG CODEX_VERSION
ARG CODEX_TARBALL
ARG CODEX_BINARY_NAME
ARG CODEX_CODE_MODE_HOST_TARBALL
ARG CODEX_CODE_MODE_HOST_BINARY_NAME
ARG CODEX_BASE_URL

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/codex \
    && wget -qO /tmp/${CODEX_TARBALL} "${CODEX_BASE_URL}/rust-${CODEX_VERSION}/${CODEX_TARBALL}" \
    && wget -qO /tmp/${CODEX_CODE_MODE_HOST_TARBALL} "${CODEX_BASE_URL}/rust-${CODEX_VERSION}/${CODEX_CODE_MODE_HOST_TARBALL}" \
    && tar -xzf /tmp/${CODEX_TARBALL} -C /tmp \
    && tar -xzf /tmp/${CODEX_CODE_MODE_HOST_TARBALL} -C /tmp \
    && install -m 0755 /tmp/${CODEX_BINARY_NAME} /opt/codex/codex \
    && install -m 0755 /tmp/${CODEX_CODE_MODE_HOST_BINARY_NAME} /opt/codex/codex-code-mode-host \
    && rm -rf \
      /tmp/${CODEX_TARBALL} \
      /tmp/${CODEX_BINARY_NAME} \
      /tmp/${CODEX_CODE_MODE_HOST_TARBALL} \
      /tmp/${CODEX_CODE_MODE_HOST_BINARY_NAME}

FROM scratch

ARG CODEX_VERSION
LABEL org.opencontainers.image.title="Codex Binary" \
      org.opencontainers.image.description="Slim container image that packages the Codex binary for reuse" \
      org.opencontainers.image.version="${CODEX_VERSION}"

COPY --from=downloader /opt/codex/codex /usr/local/bin/codex
COPY --from=downloader /opt/codex/codex-code-mode-host /usr/local/bin/codex-code-mode-host

ENTRYPOINT ["/usr/local/bin/codex"]
