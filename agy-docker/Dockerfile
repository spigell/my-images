# syntax=docker/dockerfile:1.24

ARG UNIVERSAL_WORKBENCH_IMAGE_TAG=sha-dev
ARG AGY_VERSION=1.0.0
ARG AGY_LINUX_AMD64_URL=https://storage.googleapis.com/antigravity-cli/1.0.0-5288553236791296/linux-x64/cli_linux_x64.tar.gz

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_IMAGE_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG TARGETARCH
ARG AGY_VERSION
ARG AGY_LINUX_AMD64_URL
ARG UNIVERSAL_WORKBENCH_IMAGE_TAG

WORKDIR /project

RUN tmpdir="$(mktemp -d)" \
 && curl -fsSL "${AGY_LINUX_AMD64_URL}" -o "${tmpdir}/agy.tar.gz" \
 && tar -xzf "${tmpdir}/agy.tar.gz" -C "${tmpdir}" antigravity \
 && install -m 0755 "${tmpdir}/antigravity" /usr/local/bin/agy \
 && ln -sf /usr/local/bin/agy /usr/local/bin/antigravity \
 && rm -rf "${tmpdir}"

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
