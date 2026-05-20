# syntax=docker/dockerfile:1.24

ARG UNIVERSAL_WORKBENCH_IMAGE_TAG=sha-dev
ARG AGY_VERSION=1.0.0
ARG AGY_LINUX_AMD64_URL=https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.0-5288553236791296/linux-x64/cli_linux_x64.tar.gz
ARG AGY_LINUX_AMD64_SHA512=5ccdcc01fb863c7e8e56473c6c95dba75fed4fd2a242200d80cfc4c7fab811b733f5a7fab25332130aad298e72627e1018e6911a5658f4f059ef6e019f211972
ARG AGY_LINUX_ARM64_URL=https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.0-5288553236791296/linux-arm/cli_linux_arm64.tar.gz
ARG AGY_LINUX_ARM64_SHA512=9797c7955d0e07fc57605f81fab16dfd2f390d43b2508af3ca697b1cfa498e37e43a3a9a55ad8b26eb1353d80bbec522d108eb75a0eb0eb00e979cb579d6e277

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_IMAGE_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG TARGETARCH
ARG AGY_VERSION
ARG AGY_LINUX_AMD64_URL
ARG AGY_LINUX_AMD64_SHA512
ARG AGY_LINUX_ARM64_URL
ARG AGY_LINUX_ARM64_SHA512
ARG UNIVERSAL_WORKBENCH_IMAGE_TAG

WORKDIR /project

RUN case "${TARGETARCH}" in \
      amd64) agy_url="${AGY_LINUX_AMD64_URL}"; agy_sha512="${AGY_LINUX_AMD64_SHA512}" ;; \
      arm64) agy_url="${AGY_LINUX_ARM64_URL}"; agy_sha512="${AGY_LINUX_ARM64_SHA512}" ;; \
      *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
 && tmpdir="$(mktemp -d)" \
 && curl -fsSL "${agy_url}" -o "${tmpdir}/agy.tar.gz" \
 && echo "${agy_sha512}  ${tmpdir}/agy.tar.gz" | sha512sum -c - \
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
