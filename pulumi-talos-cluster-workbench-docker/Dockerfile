# syntax=docker/dockerfile:1.18
############################
# Configurable args
############################
ARG PULUMI_WORKBENCH_TAG=3.192.0
ARG K9S_VERSION=0.32.5
ARG TALOSCTL_VERSION=1.8.2

# Set by buildx/BuildKit (defaults for classic docker build)
ARG TARGETOS=linux
ARG TARGETARCH=amd64

############################
# Stage 1: fetch artifacts
############################
FROM debian:bookworm-slim AS fetch
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ARG K9S_VERSION
ARG TALOSCTL_VERSION
ARG TARGETOS
ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl xz-utils tar \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/fetch

# k9s .deb (per-arch): k9s_linux_amd64.deb / k9s_linux_arm64.deb
RUN curl -fsSL -o k9s.deb \
  "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_${TARGETOS}_${TARGETARCH}.deb"

# talosctl prebuilt binary (per-arch): talosctl-linux-amd64 / talosctl-linux-arm64
RUN curl -fsSL -o talosctl \
  "https://github.com/siderolabs/talos/releases/download/v${TALOSCTL_VERSION}/talosctl-${TARGETOS}-${TARGETARCH}" \
  && chmod +x talosctl

############################
# Stage 2: final image
############################
FROM ghcr.io/spigell/pulumi-workbench:${PULUMI_WORKBENCH_TAG}

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

# Copy artifacts from fetcher
COPY --from=fetch /tmp/fetch/k9s.deb /tmp/k9s.deb
COPY --from=fetch /tmp/fetch/talosctl /usr/local/bin/talosctl

# Install runtime deps, install k9s, cleanup
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl dpkg \
 && dpkg -i /tmp/k9s.deb || apt-get -y -f install \
 && rm -f /tmp/k9s.deb \
 && rm -rf /var/lib/apt/lists/*

# QoL (optional)
RUN echo 'source /usr/share/bash-completion/bash_completion || true' >> /etc/bash.bashrc || true

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["k9s version --short || true && talosctl version --short || true && pulumi version || true"]
