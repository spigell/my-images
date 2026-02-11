# syntax=docker/dockerfile:1.18

ARG OPENSSH_SERVER_TAG=version-10.2_p1-r0
ARG ZMX_BINARY_REF=sha-dev
ARG ZMX_BINARY_IMAGE=ghcr.io/spigell/zmx-binary

FROM ${ZMX_BINARY_IMAGE}:${ZMX_BINARY_REF} AS zmx-binary
FROM linuxserver/openssh-server:${OPENSSH_SERVER_TAG}

USER root

COPY --from=zmx-binary /zmx /usr/local/bin/zmx

# Ensure the `ubuntu` user can log in via SSH and can write its ~/.ssh directory.
# linuxserver/openssh-server images are typically Alpine-based, so use adduser/addgroup.
RUN addgroup -S ubuntu 2>/dev/null || true \
 && adduser -S -D -H -h /home/ubuntu -s /bin/ash -G ubuntu ubuntu 2>/dev/null || true \
 && mkdir -p /home/ubuntu/.ssh \
 && chown -R ubuntu:ubuntu /home/ubuntu \
 && chmod 0700 /home/ubuntu /home/ubuntu/.ssh

ARG OPENSSH_SERVER_TAG
ARG ZMX_BINARY_REF

LABEL org.opencontainers.image.title="SSHD Workbench" \
      org.opencontainers.image.description="LinuxServer OpenSSH server image extended with the zmx binary" \
      org.opencontainers.image.version="${OPENSSH_SERVER_TAG}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/sshd-docker" \
      com.spigell.workbench.base-image="linuxserver/openssh-server" \
      com.spigell.workbench.base-image-tag="${OPENSSH_SERVER_TAG}" \
      com.spigell.workbench.zmx.version="${ZMX_BINARY_REF}"
