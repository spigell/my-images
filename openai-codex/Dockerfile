# ---- Builder stage ----
FROM ubuntu:24.04 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV CODEX_VERSION=rust-v0.39.0
ENV CODEX_TARBALL=codex-x86_64-unknown-linux-gnu.tar.gz
ENV CODEX_URL=https://github.com/openai/codex/releases/download/${CODEX_VERSION}/${CODEX_TARBALL}

RUN wget -q ${CODEX_URL} && \
    tar -xzf ${CODEX_TARBALL} && \
    chmod +x codex-x86_64-unknown-linux-gnu

# ---- Final runtime stage ----
FROM ubuntu:24.04

# Install basic development tools, ca-certificates, and iptables/ipset, then clean up apt cache to reduce image size
RUN apt-get update && apt-get install -y --no-install-recommends \
  aggregate \
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

# Set up project directory
ENV CODEX_HOME=/workspace/codex
WORKDIR $CODEX_HOME

# Create directory (for clarity) and copy binary
RUN mkdir -p $CODEX_HOME
COPY --from=builder /codex-x86_64-unknown-linux-gnu /usr/local/bin/codex

ENTRYPOINT ["codex"]

