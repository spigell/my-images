# syntax=docker/dockerfile:1.18

############################
# Global, configurable args
############################
ARG PULUMI_TAG=3.192.0
ARG PULUMICTL_VERSION=0.0.46
ARG DELVE_VERSION=1.24.2
ARG GOLANGCI_LINT_VERSION=2.1.6
ARG KUBECTL_VERSION=1.34.0

# Docker/buildx usually set these; provide safe defaults
ARG TARGETOS=linux
ARG TARGETARCH=amd64

############################
# Stage 1: build dlv
############################
FROM golang:1.25.1-bookworm AS dlv-builder
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ARG DELVE_VERSION

ENV GOBIN=/out PATH=/go/bin:/usr/local/go/bin:$PATH
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go install github.com/go-delve/delve/cmd/dlv@v${DELVE_VERSION}

############################
# Stage 2: fetch artifacts
############################
FROM debian:bookworm-slim AS fetch
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# ✨ Re-declare ARGs used in this stage
ARG PULUMICTL_VERSION
ARG GOLANGCI_LINT_VERSION
ARG TARGETOS
ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl tar xz-utils \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/fetch

# pulumictl (tar.gz)
RUN curl -fsSL -o pulumictl.tar.gz \
      "https://github.com/pulumi/pulumictl/releases/download/v${PULUMICTL_VERSION}/pulumictl-v${PULUMICTL_VERSION}-${TARGETOS}-amd64.tar.gz" \
 && tar -xzf pulumictl.tar.gz

# golangci-lint (.deb) — kept as in your original flow
RUN curl -fsSL -o golangci-lint.deb \
      "https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64.deb"

############################
# Stage 3: final image
############################
FROM pulumi/pulumi:${PULUMI_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# ✨ Re-declare ARGs used in this stage
ARG KUBECTL_VERSION
ARG TARGETOS
ARG TARGETARCH

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
      vim curl tar sudo bash-completion make iproute2 rsync \
    && rm -rf /var/lib/apt/lists/*

# kubectl (prebuilt, pinned)
RUN curl -fsSL -o /usr/local/bin/kubectl \
      "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl" \
 && chmod +x /usr/local/bin/kubectl

# dlv from builder
COPY --from=dlv-builder /out/dlv /usr/local/bin/dlv

# pulumictl + golangci-lint from fetcher
COPY --from=fetch /tmp/fetch/pulumictl /usr/local/bin/pulumictl
COPY --from=fetch /tmp/fetch/golangci-lint.deb /tmp/golangci-lint.deb
RUN dpkg -i /tmp/golangci-lint.deb || apt-get -y -f install && rm /tmp/golangci-lint.deb

# QoL
RUN echo 'source /usr/share/bash-completion/bash_completion || true' >> /etc/bash.bashrc

# Provided by --build-context setup-git-helper=path/to/repo-root/shared
COPY --from=setup-git-helper --chmod=0755 /setup-git-workbench.sh /usr/local/bin/setup-git-workbench

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["pulumi version && pulumictl version && golangci-lint version && dlv version && kubectl version --client=true --output=yaml || true"]
