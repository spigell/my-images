# syntax=docker/dockerfile:1.27

ARG UNIVERSAL_WORKBENCH_IMAGE_TAG=sha-dev
ARG AGY_VERSION=1.2.9 # renovate: datasource=github-tags depName=google-antigravity/antigravity-cli
ARG AGENT_USAGE_PROXY_IMAGE=ghcr.io/spigell/agent-usage-proxy
ARG AGENT_USAGE_PROXY_IMAGE_TAG=sha-dev

FROM ${AGENT_USAGE_PROXY_IMAGE}:${AGENT_USAGE_PROXY_IMAGE_TAG} AS agent-usage-proxy

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_IMAGE_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG TARGETARCH
ARG AGY_VERSION
ARG UNIVERSAL_WORKBENCH_IMAGE_TAG

WORKDIR /project

RUN arch="${TARGETARCH:-amd64}"; \
    case "${arch}" in \
      amd64) archive_arch="x64" ;; \
      arm64) archive_arch="arm64" ;; \
      *) echo "Unsupported architecture: ${arch}" >&2; exit 1 ;; \
    esac; \
    tmpdir="$(mktemp -d)" \
     && curl -fsSL "https://github.com/google-antigravity/antigravity-cli/releases/download/${AGY_VERSION}/agy_cli_linux_${archive_arch}.tar.gz" -o "${tmpdir}/agy.tar.gz" \
     && tar -xzf "${tmpdir}/agy.tar.gz" -C "${tmpdir}" antigravity \
     && install -m 0755 "${tmpdir}/antigravity" /usr/local/bin/agy \
     && ln -sf /usr/local/bin/agy /usr/local/bin/antigravity \
     && rm -rf "${tmpdir}"

# Usage sidecar. With no USAGE_AGENT it exits 2, which proves it loads here.
# For agy it spawns the `agy` CLI above, so it only works in this image.
COPY --from=agent-usage-proxy /opt/agent-usage-proxy /opt/agent-usage-proxy
COPY --from=agent-usage-proxy /usr/local/bin/agent-usage-proxy /usr/local/bin/agent-usage-proxy
RUN (USAGE_AGENT= agent-usage-proxy || [ $? -eq 2 ])

USER ubuntu
ENV HOME=/home/ubuntu

LABEL org.opencontainers.image.title="Agy Workbench" \
      org.opencontainers.image.description="Antigravity CLI workbench built on the universal base image" \
      org.opencontainers.image.version="${AGY_VERSION}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/agy-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_IMAGE_TAG}" \
      com.spigell.workbench.agy.version="${AGY_VERSION}"

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["agy --help || true"]
