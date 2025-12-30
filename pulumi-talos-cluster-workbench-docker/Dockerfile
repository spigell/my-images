# syntax=docker/dockerfile:1.18
############################
# Configurable args
############################
ARG PULUMI_WORKBENCH_TAG=3.210.0
ARG K9S_VERSION=0.50.16
ARG PACKER_VERSION=1.12.0

# Set by buildx/BuildKit (defaults for classic docker build)
ARG TARGETOS=linux
ARG TARGETARCH=amd64

############################
# Stage 1: fetch artifacts
############################
FROM debian:bookworm-slim AS fetch
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ARG K9S_VERSION
ARG PACKER_VERSION
ARG TARGETOS
ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl unzip xz-utils tar \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/fetch

# k9s .deb (per-arch): k9s_linux_amd64.deb / k9s_linux_arm64.deb
RUN curl -fsSL -o k9s.deb \
  "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_${TARGETOS}_${TARGETARCH}.deb"

# packer prebuilt binary (per-arch): packer_*.zip
RUN curl -fsSL -o packer.zip \
  "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_${TARGETOS}_${TARGETARCH}.zip" \
  && unzip packer.zip \
  && chmod +x packer

############################
# Stage 2: final image
############################
FROM ghcr.io/spigell/pulumi-workbench:${PULUMI_WORKBENCH_TAG}

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

USER root
ENV HOME=/root

# Copy artifacts from fetcher
COPY --from=fetch /tmp/fetch/k9s.deb /tmp/k9s.deb
COPY --from=fetch /tmp/fetch/packer /usr/local/bin/packer

# Install runtime deps, install k9s, cleanup
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update \
 && (dpkg -i /tmp/k9s.deb || (apt-get -y -f install && dpkg -i /tmp/k9s.deb)) \
 && rm -f /tmp/k9s.deb \
 && rm -rf /var/lib/apt/lists/*

USER ubuntu
ENV HOME=/home/ubuntu

LABEL org.opencontainers.image.title="Pulumi Talos Cluster Workbench" \
      org.opencontainers.image.description="Pulumi Talos environment built on the universal workbench stack with K9s and Packer tooling" \
      org.opencontainers.image.version="${PULUMI_WORKBENCH_TAG}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/pulumi-talos-cluster-workbench-docker" \
      com.spigell.workbench.base-image="pulumi-workbench" \
      com.spigell.workbench.base-image-tag="${PULUMI_WORKBENCH_TAG}" \
      com.spigell.workbench.k9s.version="${K9S_VERSION}" \
      com.spigell.workbench.packer.version="${PACKER_VERSION}"

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["k9s version --short || true && packer version || true && pulumi version || true"]
