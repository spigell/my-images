# syntax=docker/dockerfile:1.4

ARG CODEX_VERSION=rust-v0.39.0
ARG CODEX_BINARY_IMAGE=codex-binary
ARG CODEX_BINARY_REF=rust-v0.39.0

FROM ghcr.io/spigell/codex-binary:${CODEX_BINARY_REF} AS codex

FROM ubuntu:24.04

ARG CODEX_VERSION=rust-v0.39.0
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

ENV CODEX_UNSAFE_ALLOW_NO_SANDBOX=1
ENV CODEX_VERSION=${CODEX_VERSION}
LABEL codex.binary.ref="${CODEX_BINARY_REF}"

# Set up project directory
ENV CODEX_HOME=/workspace/codex
WORKDIR $CODEX_HOME

# Create directory (for clarity) and copy binary
RUN mkdir -p $CODEX_HOME
COPY --from=codex /usr/local/bin/codex /usr/local/bin/codex

ENTRYPOINT ["codex"]
