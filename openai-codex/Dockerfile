# syntax=docker/dockerfile:1.4

ARG CODEX_BINARY_REF=rust-v0.39.0

FROM ghcr.io/spigell/codex-binary:${CODEX_BINARY_REF} AS codex
FROM ubuntu:24.04

ARG CODEX_BINARY_REF

# Install basic development tools, ca-certificates, and iptables/ipset, then clean up apt cache to reduce image size
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  dnsutils \
  fzf \
  gh \
  git \
  gnupg2 \
  iproute2 \
  ipset \
  iptables \
  jq \
  less \
  man-db \
  procps \
  unzip \
  ripgrep \
  zsh \
  && rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION=1.24.5
ENV GOLANG_AMD64_SHA256=10ad9e86233e74c0f6590fe5426895de6bf388964210eac34a6d83f38918ecdc
ENV GOLANG_ARM64_SHA256=0df02e6aeb3d3c06c95ff201d575907c736d6c62cfa4b6934c11203f1d600ffa

RUN set -eux; \
  arch="${TARGETARCH:-amd64}"; \
  case "$arch" in \
    arm64) go_sha256="$GOLANG_ARM64_SHA256";; \
    amd64) go_sha256="$GOLANG_AMD64_SHA256";; \
    *) echo "unsupported TARGETARCH: $arch" >&2; exit 1;; \
  esac; \
  curl -fsSLo /tmp/go.tgz "https://golang.org/dl/go${GOLANG_VERSION}.linux-${arch}.tar.gz"; \
  echo "${go_sha256} /tmp/go.tgz" | sha256sum -c -; \
  tar -C /usr/local -xzf /tmp/go.tgz; \
  rm /tmp/go.tgz; \
  /usr/local/go/bin/go version

ENV GOPATH=/go
ENV PATH="${GOPATH}/bin:/usr/local/go/bin:${PATH}"
ENV CODEX_UNSAFE_ALLOW_NO_SANDBOX=1
LABEL codex.binary.ref="${CODEX_BINARY_REF}"

# Set up project directory
ENV CODEX_HOME=/workspace/codex
WORKDIR $CODEX_HOME

# Create directory (for clarity) and copy binary
RUN mkdir -p $CODEX_HOME
COPY --from=codex /usr/local/bin/codex /usr/local/bin/codex

ENTRYPOINT ["codex"]
