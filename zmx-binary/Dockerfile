# syntax=docker/dockerfile:1.4

ARG ZMX_REF=651dd7cd93c93acfbf8f3d0322bee0d82dd1beb9
ARG ZIG_VERSION=0.15.2
ARG TARGETARCH=amd64

FROM ubuntu:24.04 AS builder

ARG ZMX_REF
ARG ZIG_VERSION
ARG TARGETARCH

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      xz-utils \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN case "${TARGETARCH}" in \
      amd64) ARCH="x86_64" ;; \
      arm64) ARCH="aarch64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    FILENAME="zig-${ARCH}-linux-${ZIG_VERSION}.tar.xz"; \
    URL="https://ziglang.org/download/${ZIG_VERSION}/${FILENAME}"; \
    curl -fsSL "${URL}" -o "${FILENAME}"; \
    tar -xJf "${FILENAME}" -C /opt; \
    rm -f "${FILENAME}"; \
    ln -s "/opt/zig-${ARCH}-linux-${ZIG_VERSION}/zig" /usr/local/bin/zig

WORKDIR /src

RUN git clone --filter=blob:none --no-checkout https://github.com/spigell/zmx.git \
 && cd zmx \
 && git fetch --depth 1 origin "${ZMX_REF}" \
 && git checkout --detach "${ZMX_REF}"

WORKDIR /src/zmx

RUN zig build -Doptimize=ReleaseSafe --prefix /opt/zmx install

FROM debian:bookworm-slim

ARG ZMX_REF
LABEL org.opencontainers.image.title="zmx Binary" \
      org.opencontainers.image.description="Slim container image that packages the zmx session persistence binary for reuse" \
      org.opencontainers.image.version="${ZMX_REF}" \
      org.opencontainers.image.source="https://github.com/spigell/zmx" \
      org.opencontainers.image.url="https://github.com/spigell/zmx" \
      org.opencontainers.image.documentation="https://github.com/spigell/zmx/blob/${ZMX_REF}/README.md" \
      org.opencontainers.image.licenses="MIT"

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      tmux \
 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /opt/zmx/bin/zmx /usr/local/bin/zmx

ENTRYPOINT ["/usr/local/bin/zmx"]
