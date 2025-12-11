# syntax=docker/dockerfile:1.4

ARG ZMX_VERSION=0.1.0
ARG ZIG_VERSION=0.15.2
ARG TARGETARCH=amd64

FROM ubuntu:24.04 AS builder

ARG ZMX_VERSION
ARG ZIG_VERSION
ARG TARGETARCH

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      xz-utils \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN set -euxo pipefail; \
    case "${TARGETARCH}" in \
      amd64) ARCH="x86_64" ;; \
      arm64) ARCH="aarch64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    FILENAME="zig-linux-${ARCH}-${ZIG_VERSION}.tar.xz"; \
    URL="https://ziglang.org/download/${ZIG_VERSION}/${FILENAME}"; \
    curl -fsSL "${URL}" -o "${FILENAME}"; \
    tar -xJf "${FILENAME}" -C /opt; \
    rm -f "${FILENAME}"; \
    ln -s "/opt/zig-linux-${ARCH}-${ZIG_VERSION}/zig" /usr/local/bin/zig

WORKDIR /src

RUN set -euxo pipefail; \
    git clone --branch "v${ZMX_VERSION}" --depth 1 https://github.com/neurosnap/zmx.git

WORKDIR /src/zmx

RUN zig build -Doptimize=ReleaseSafe --prefix /opt/zmx install

FROM scratch

ARG ZMX_VERSION
LABEL org.opencontainers.image.title="zmx Binary" \
      org.opencontainers.image.description="Slim container image that packages the zmx session persistence binary for reuse" \
      org.opencontainers.image.version="${ZMX_VERSION}"

COPY --from=builder /opt/zmx/bin/zmx /usr/local/bin/zmx

ENTRYPOINT ["/usr/local/bin/zmx"]
