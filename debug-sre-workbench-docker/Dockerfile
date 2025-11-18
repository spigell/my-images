# syntax=docker/dockerfile:1.18

ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG KUBECTL_VERSION=1.29.6
ARG HELM_VERSION=3.15.2
ARG K9S_VERSION=0.32.5
ARG TALOSCTL_VERSION=1.11.2
ARG ETCD_VERSION=3.5.15
ARG TARGETOS=linux
ARG TARGETARCH=amd64

FROM debian:bookworm-slim AS fetch
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ARG K9S_VERSION
ARG TALOSCTL_VERSION
ARG ETCD_VERSION
ARG TARGETOS
ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl tar xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/fetch

RUN curl -fsSL -o k9s.deb \
      "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_${TARGETOS}_${TARGETARCH}.deb"

RUN curl -fsSL -o talosctl \
      "https://github.com/siderolabs/talos/releases/download/v${TALOSCTL_VERSION}/talosctl-${TARGETOS}-${TARGETARCH}" \
    && chmod +x talosctl

RUN arch="${TARGETARCH}"; \
    if [ "${TARGETARCH}" = "amd64" ]; then arch="amd64"; fi; \
    if [ "${TARGETARCH}" = "arm64" ]; then arch="arm64"; fi; \
    curl -fsSL -o etcd.tar.gz \
      "https://github.com/etcd-io/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-${TARGETOS}-${arch}.tar.gz"; \
    tar -xzf etcd.tar.gz; \
    mv "etcd-v${ETCD_VERSION}-${TARGETOS}-${arch}/etcdctl" /tmp/fetch/etcdctl; \
    chmod +x /tmp/fetch/etcdctl; \
    rm -rf "etcd-v${ETCD_VERSION}-${TARGETOS}-${arch}" etcd.tar.gz

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG TARGETOS
ARG TARGETARCH
ARG KUBECTL_VERSION
ARG HELM_VERSION
ARG K9S_VERSION
ARG TALOSCTL_VERSION
ARG ETCD_VERSION
ARG UNIVERSAL_WORKBENCH_TAG

COPY --from=fetch /tmp/fetch/k9s.deb /tmp/k9s.deb
COPY --from=fetch /tmp/fetch/talosctl /usr/local/bin/talosctl
COPY --from=fetch /tmp/fetch/etcdctl /usr/local/bin/etcdctl

# Docker CLI comes from apt since the universal base keeps the system lean
RUN apt-get update \
    && apt-get install -y --no-install-recommends docker.io \
    && rm -rf /var/lib/apt/lists/*

# Install K9s
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update \
    && (dpkg -i /tmp/k9s.deb || (apt-get -y -f install && dpkg -i /tmp/k9s.deb)) \
    && rm -f /tmp/k9s.deb \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -fsSL -o /usr/local/bin/kubectl \
      "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl" \
    && chmod +x /usr/local/bin/kubectl

# Install Helm
RUN workdir="$(mktemp -d)" \
    && arch="${TARGETARCH}" \
    && if [ "${TARGETARCH}" = "amd64" ]; then arch="amd64"; fi \
    && if [ "${TARGETARCH}" = "arm64" ]; then arch="arm64"; fi \
    && curl -fsSL -o "${workdir}/helm.tar.gz" \
         "https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${arch}.tar.gz" \
    && tar -xzf "${workdir}/helm.tar.gz" -C "${workdir}" \
    && mv "${workdir}/${TARGETOS}-${arch}/helm" /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf "${workdir}"

USER ubuntu
ENV HOME=/home/ubuntu

LABEL org.opencontainers.image.title="Debug SRE Workbench" \
      org.opencontainers.image.description="Universal workbench derivative with Kubernetes debugging tools (kubectl, Helm, Docker CLI, K9s, Talosctl, etcdctl, Poetry, uv)" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/debug-sre-workbench-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_TAG}" \
      com.spigell.workbench.kubectl.version="${KUBECTL_VERSION}" \
      com.spigell.workbench.helm.version="${HELM_VERSION}" \
      com.spigell.workbench.k9s.version="${K9S_VERSION}" \
      com.spigell.workbench.talosctl.version="${TALOSCTL_VERSION}" \
      com.spigell.workbench.etcdctl.version="${ETCD_VERSION}"

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["kubectl version --client=true --output=yaml && helm version --short && docker --version && k9s version --short && talosctl version --short && etcdctl version || true"]
