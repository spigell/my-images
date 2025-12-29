# syntax=docker/dockerfile:1.4

ARG ZMX_REF=cb35332c5774828358c17a96e7a0846c7f846668
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
      amd64) ARCH="x86_64"; ZIG_TARGET="x86_64-linux-musl" ;; \
      arm64) ARCH="aarch64"; ZIG_TARGET="aarch64-linux-musl" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    FILENAME="zig-${ARCH}-linux-${ZIG_VERSION}.tar.xz"; \
    URL="https://ziglang.org/download/${ZIG_VERSION}/${FILENAME}"; \
    curl -fsSL "${URL}" -o "${FILENAME}"; \
    tar -xJf "${FILENAME}" -C /opt; \
    rm -f "${FILENAME}"; \
    ln -s "/opt/zig-${ARCH}-linux-${ZIG_VERSION}/zig" /usr/local/bin/zig; \
    echo "${ZIG_TARGET}" >/tmp/zig-target

WORKDIR /src

RUN git clone --filter=blob:none --no-checkout https://github.com/neurosnap/zmx.git \
 && cd zmx \
 && git fetch --depth 1 origin "${ZMX_REF}" \
 && git checkout --detach "${ZMX_REF}"

WORKDIR /src/zmx

RUN ZIG_TARGET="$(cat /tmp/zig-target)"; \
    zig build -Doptimize=ReleaseSafe -Dtarget="${ZIG_TARGET}" --prefix /opt/zmx install

FROM scratch

ARG ZMX_REF
LABEL org.opencontainers.image.title="zmx Binary" \
      org.opencontainers.image.description="Scratch container image that packages the static zmx session persistence binary for reuse" \
      org.opencontainers.image.version="${ZMX_REF}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images" \
      org.opencontainers.image.url="https://github.com/spigell/my-images" \
      org.opencontainers.image.documentation="https://github.com/spigell/my-images/blob/main/zmx-binary/Dockerfile" \
      org.opencontainers.image.licenses="MIT"

COPY --from=builder /opt/zmx/bin/zmx /zmx

ENTRYPOINT ["/zmx"]
