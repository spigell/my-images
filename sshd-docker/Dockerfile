# syntax=docker/dockerfile:1.24

ARG OPENSSH_SERVER_IMAGE_TAG=version-10.2_p1-r0 # renovate: datasource=docker depName=linuxserver/openssh-server versioning=regex:^version-(?<major>\d+)\.(?<minor>\d+)_p(?<patch>\d+)-r(?<build>\d+)$
ARG ZMX_BINARY_IMAGE_TAG=sha-dev
ARG ZMX_BINARY_IMAGE=ghcr.io/spigell/zmx-binary
ARG SRE_TOOLSET_IMAGE=ghcr.io/spigell/debug-sre-workbench
ARG SRE_TOOLSET_IMAGE_TAG=latest

FROM ${SRE_TOOLSET_IMAGE}:${SRE_TOOLSET_IMAGE_TAG} AS sre-toolset
FROM ${ZMX_BINARY_IMAGE}:${ZMX_BINARY_IMAGE_TAG} AS zmx-binary
FROM linuxserver/openssh-server:${OPENSSH_SERVER_IMAGE_TAG}

USER root

COPY --from=zmx-binary /zmx /usr/local/bin/zmx
COPY --from=sre-toolset /usr/local/bin/kubectl /usr/local/bin/kubectl

ARG OPENSSH_SERVER_IMAGE_TAG
ARG ZMX_BINARY_IMAGE_TAG

LABEL org.opencontainers.image.title="SSHD Workbench" \
      org.opencontainers.image.description="LinuxServer OpenSSH server image extended with the zmx binary" \
      org.opencontainers.image.version="${OPENSSH_SERVER_IMAGE_TAG}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/sshd-docker" \
      com.spigell.workbench.base-image="linuxserver/openssh-server" \
      com.spigell.workbench.base-image-tag="${OPENSSH_SERVER_IMAGE_TAG}" \
      com.spigell.workbench.zmx.version="${ZMX_BINARY_IMAGE_TAG}" \
      com.spigell.workbench.sre-toolset.image="${SRE_TOOLSET_IMAGE}" \
      com.spigell.workbench.sre-toolset.tag="${SRE_TOOLSET_IMAGE_TAG}"
