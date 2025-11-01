# syntax=docker/dockerfile:1.18

############################
# Global, configurable args
############################
ARG PULUMI_VERSION=3.200.0
ARG PULUMICTL_VERSION=0.0.46
ARG KUBECTL_VERSION=1.34.0
ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG PULUMI_MCP_VERSION=0.2.0

# Docker/buildx usually set these; provide safe defaults
ARG TARGETOS=linux
ARG TARGETARCH=amd64

############################
# Stage 1: fetch artifacts
############################
FROM debian:bookworm-slim AS fetch
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ARG PULUMI_VERSION
ARG PULUMICTL_VERSION
ARG TARGETOS
ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl tar xz-utils \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/fetch

# pulumi CLI (tar.gz)
RUN curl -fsSL -o pulumi.tar.gz \
      "https://get.pulumi.com/releases/sdk/pulumi-v${PULUMI_VERSION}-linux-${TARGETARCH}.tar.gz" \
 && tar -xzf pulumi.tar.gz \
 && rm pulumi.tar.gz

# pulumictl (tar.gz)
RUN curl -fsSL -o pulumictl.tar.gz \
      "https://github.com/pulumi/pulumictl/releases/download/v${PULUMICTL_VERSION}/pulumictl-v${PULUMICTL_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz" \
 && tar -xzf pulumictl.tar.gz \
 && rm pulumictl.tar.gz \
 && find . -maxdepth 1 -type d -name "pulumictl-*" -exec mv {}/pulumictl /tmp/fetch/pulumictl \; \
 && find . -maxdepth 1 -type d -name "pulumictl-*" -exec rm -rf {} \;

############################
# Stage 2: final image
############################
FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root

ARG TARGETOS
ARG TARGETARCH
ARG KUBECTL_VERSION
ARG UNIVERSAL_WORKBENCH_TAG
ARG PULUMI_VERSION
ARG PULUMI_MCP_VERSION

# Install Pulumi CLI
RUN install -d -m 0755 /usr/local/pulumi
COPY --from=fetch /tmp/fetch/pulumi/ /usr/local/pulumi/
RUN shopt -s nullglob; \
    for bin in /usr/local/pulumi/pulumi /usr/local/pulumi/bin/*; do \
      name="$(basename "$bin")"; \
      ln -sf "$bin" "/usr/local/bin/$name"; \
    done; \
    shopt -u nullglob

# pulumictl from fetcher
COPY --from=fetch /tmp/fetch/pulumictl /usr/local/bin/pulumictl
RUN chmod +x /usr/local/bin/pulumictl

# Install kubectl (prebuilt, pinned)
RUN curl -fsSL -o /usr/local/bin/kubectl \
      "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl" \
 && chmod +x /usr/local/bin/kubectl

# Install @pulumi/mcp-server globally
RUN yarn config set prefix /usr/local \
 && yarn global add @pulumi/mcp-server@${PULUMI_MCP_VERSION} \
 && npm cache clean --force || true \
 && yarn cache clean || true

USER ubuntu

LABEL org.opencontainers.image.title="Pulumi Workbench" \
      org.opencontainers.image.description="Pulumi workbench built on the universal base image with Pulumi CLI and MCP server tooling" \
      org.opencontainers.image.version="${PULUMI_VERSION}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/pulumi-workbench-docker" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_TAG}" \
      com.spigell.workbench.mcp.version="${PULUMI_MCP_VERSION}"

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["pulumi version && pulumictl version && golangci-lint version && kubectl version --client=true --output=yaml || true"]
