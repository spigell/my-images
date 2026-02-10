# syntax=docker/dockerfile:1.18

ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG KUBECTL_VERSION=1.34.2
ARG HELM_VERSION=3.19.2
ARG K9S_VERSION=0.50.16
ARG TALOSCTL_VERSION=1.12.0
ARG GKE_AUTH_PLUGIN_VERSION=551.0.0
ARG GCLOUD_VERSION=551.0.0
ARG ETCD_VERSION=3.6.5
ARG KREW_VERSION=latest
ARG LINEAGE_VERSION=0.5.0
ARG TARGETOS=linux
ARG TARGETARCH=amd64

FROM debian:bookworm-slim AS fetch
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ARG K9S_VERSION
ARG KUBECTL_VERSION
ARG HELM_VERSION
ARG TALOSCTL_VERSION
ARG GKE_AUTH_PLUGIN_VERSION
ARG GCLOUD_VERSION
ARG ETCD_VERSION
ARG KREW_VERSION
ARG TARGETOS
ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git tar xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/fetch

RUN curl -fsSL -o k9s.deb \
      "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_${TARGETOS}_${TARGETARCH}.deb"

RUN curl -fsSL -o talosctl \
      "https://github.com/siderolabs/talos/releases/download/v${TALOSCTL_VERSION}/talosctl-${TARGETOS}-${TARGETARCH}" \
    && chmod +x talosctl

RUN curl -fsSL -o kubectl \
      "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl" \
    && chmod +x kubectl

RUN workdir="$(mktemp -d)" \
    && arch="${TARGETARCH}" \
    && if [ "${TARGETARCH}" = "amd64" ]; then arch="amd64"; fi \
    && if [ "${TARGETARCH}" = "arm64" ]; then arch="arm64"; fi \
    && curl -fsSL -o "${workdir}/helm.tar.gz" \
         "https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${arch}.tar.gz" \
    && tar -xzf "${workdir}/helm.tar.gz" -C "${workdir}" \
    && mv "${workdir}/${TARGETOS}-${arch}/helm" /tmp/fetch/helm \
    && chmod +x /tmp/fetch/helm \
    && rm -rf "${workdir}"

RUN arch="${TARGETARCH}" \
    && archive_arch="${arch}" \
    && if [ "${arch}" = "amd64" ]; then archive_arch="amd64"; fi \
    && if [ "${arch}" = "arm64" ]; then archive_arch="aarch64"; fi \
    && curl -fsSL -o gke-auth.tar.gz \
         "https://dl.google.com/dl/cloudsdk/release/downloads/for_packagers/linux/google-cloud-cli-gke-gcloud-auth-plugin_${GKE_AUTH_PLUGIN_VERSION}.orig_${archive_arch}.tar.gz" \
    && tar -xzf gke-auth.tar.gz \
    && mv google-cloud-sdk/bin/gke-gcloud-auth-plugin /tmp/fetch/gke-gcloud-auth-plugin \
    && chmod +x /tmp/fetch/gke-gcloud-auth-plugin \
    && rm -rf google-cloud-sdk gke-auth.tar.gz

RUN arch="${TARGETARCH}" \
    && archive_arch="${arch}" \
    && if [ "${arch}" = "amd64" ]; then archive_arch="amd64"; fi \
    && if [ "${arch}" = "arm64" ]; then archive_arch="aarch64"; fi \
    && curl -fsSL -o gcloud-sdk.tar.gz \
         "https://dl.google.com/dl/cloudsdk/release/downloads/for_packagers/linux/google-cloud-cli_${GCLOUD_VERSION}.orig_${archive_arch}.tar.gz" \
    && rm -rf google-cloud-sdk \
    && tar -xzf gcloud-sdk.tar.gz \
    && rm -f gcloud-sdk.tar.gz

RUN arch="${TARGETARCH}"; \
    if [ "${TARGETARCH}" = "amd64" ]; then arch="amd64"; fi; \
    if [ "${TARGETARCH}" = "arm64" ]; then arch="arm64"; fi; \
    curl -fsSL -o etcd.tar.gz \
      "https://github.com/etcd-io/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-${TARGETOS}-${arch}.tar.gz"; \
    tar -xzf etcd.tar.gz; \
    mv "etcd-v${ETCD_VERSION}-${TARGETOS}-${arch}/etcdctl" /tmp/fetch/etcdctl; \
    chmod +x /tmp/fetch/etcdctl; \
    rm -rf "etcd-v${ETCD_VERSION}-${TARGETOS}-${arch}" etcd.tar.gz

# Fetch krew installer in the fetch stage; installation happens in the runtime stage.
RUN tmpdir="$(mktemp -d)" \
    && cd "${tmpdir}" \
    && krew_arch="${TARGETARCH}" \
    && if [ "${krew_arch}" = "x86_64" ]; then krew_arch="amd64"; fi \
    && if [ "${krew_arch}" = "aarch64" ]; then krew_arch="arm64"; fi \
    && krew="krew-${TARGETOS}_${krew_arch}" \
    && if [ "${KREW_VERSION}" = "latest" ]; then \
         krew_url="https://github.com/kubernetes-sigs/krew/releases/latest/download/${krew}.tar.gz"; \
       else \
         krew_url="https://github.com/kubernetes-sigs/krew/releases/download/${KREW_VERSION}/${krew}.tar.gz"; \
       fi \
    && curl -fsSL -o "${krew}.tar.gz" "${krew_url}" \
    && tar -xzf "${krew}.tar.gz" \
    && mv "./${krew}" /tmp/fetch/krew-installer \
    && chmod +x /tmp/fetch/krew-installer \
    && rm -rf "${tmpdir}"

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
ARG GKE_AUTH_PLUGIN_VERSION
ARG GCLOUD_VERSION
ARG ETCD_VERSION
ARG KREW_VERSION
ARG LINEAGE_VERSION
ARG UNIVERSAL_WORKBENCH_TAG

COPY --from=fetch /tmp/fetch/k9s.deb /tmp/k9s.deb
COPY --from=fetch /tmp/fetch/talosctl /usr/local/bin/talosctl
COPY --from=fetch /tmp/fetch/kubectl /usr/local/bin/kubectl
COPY --from=fetch /tmp/fetch/helm /usr/local/bin/helm
COPY --from=fetch /tmp/fetch/gke-gcloud-auth-plugin /usr/local/bin/gke-gcloud-auth-plugin
COPY --from=fetch /tmp/fetch/etcdctl /usr/local/bin/etcdctl
COPY --from=fetch /tmp/fetch/google-cloud-sdk /opt/google-cloud-cli
COPY --from=fetch /tmp/fetch/krew-installer /tmp/krew-installer

RUN ln -sf /opt/google-cloud-cli/bin/gcloud /usr/local/bin/gcloud \
 && ln -sf /opt/google-cloud-cli/bin/gcloud-crc32c /usr/local/bin/gcloud-crc32c \
 && ln -sf /opt/google-cloud-cli/bin/gsutil /usr/local/bin/gsutil \
 && ln -sf /opt/google-cloud-cli/bin/bq /usr/local/bin/bq \
 && ln -sf /opt/google-cloud-cli/bin/docker-credential-gcloud /usr/local/bin/docker-credential-gcloud \
 && ln -sf /opt/google-cloud-cli/bin/git-credential-gcloud.sh /usr/local/bin/git-credential-gcloud.sh

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

RUN chown ubuntu:ubuntu /tmp/krew-installer

USER ubuntu
ENV HOME=/home/ubuntu
ENV KREW_ROOT=/home/ubuntu/.krew
ENV PATH="${KREW_ROOT}/bin:${PATH}"

RUN /tmp/krew-installer install krew \
    && lineage_arch="${TARGETARCH}" \
    && if [ "${TARGETARCH}" = "amd64" ]; then lineage_arch="amd64"; fi \
    && if [ "${TARGETARCH}" = "arm64" ]; then lineage_arch="arm64"; fi \
    && lineage_archive="kube-lineage_${TARGETOS}_${lineage_arch}.tar.gz" \
    && lineage_url="https://github.com/tohjustin/kube-lineage/releases/download/v${LINEAGE_VERSION}/${lineage_archive}" \
    && curl -fsSL -o "/tmp/${lineage_archive}" "${lineage_url}" \
    && lineage_sha="$(sha256sum "/tmp/${lineage_archive}" | awk '{print $1}')" \
    && cat > /tmp/lineage.yaml <<EOF \
apiVersion: krew.googlecontainertools.github.com/v1alpha2
kind: Plugin
metadata:
  name: lineage
spec:
  version: v${LINEAGE_VERSION}
  homepage: https://github.com/tohjustin/kube-lineage
  shortDescription: Display all dependent resources or resource dependencies
  platforms:
  - selector:
      matchLabels:
        os: ${TARGETOS}
        arch: ${lineage_arch}
    uri: ${lineage_url}
    sha256: ${lineage_sha}
    bin: kube-lineage
EOF
    && kubectl krew install --manifest=/tmp/lineage.yaml --archive="/tmp/${lineage_archive}" \
    && rm -f /tmp/krew-installer

LABEL org.opencontainers.image.title="Debug SRE Workbench" \
      org.opencontainers.image.description="Universal workbench derivative with Kubernetes debugging tools (kubectl, Helm, Docker CLI, K9s, Talosctl, etcdctl, krew, kube-lineage, Poetry, uv)" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/debug-sre-workbench-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_TAG}" \
      com.spigell.workbench.kubectl.version="${KUBECTL_VERSION}" \
      com.spigell.workbench.helm.version="${HELM_VERSION}" \
      com.spigell.workbench.k9s.version="${K9S_VERSION}" \
      com.spigell.workbench.talosctl.version="${TALOSCTL_VERSION}" \
      com.spigell.workbench.gke-gcloud-auth-plugin.version="${GKE_AUTH_PLUGIN_VERSION}" \
      com.spigell.workbench.gcloud.version="${GCLOUD_VERSION}" \
      com.spigell.workbench.krew.version="${KREW_VERSION}" \
      com.spigell.workbench.kube-lineage.version="${LINEAGE_VERSION}" \
      com.spigell.workbench.etcdctl.version="${ETCD_VERSION}"

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["kubectl version --client=true --output=yaml && helm version --short && docker --version && k9s version --short && talosctl version --short && etcdctl version || true"]
