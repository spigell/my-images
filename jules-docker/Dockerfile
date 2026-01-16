# syntax=docker/dockerfile:1

ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG JULES_VERSION=0.1.42

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG JULES_VERSION
ARG UNIVERSAL_WORKBENCH_TAG

WORKDIR /project

RUN yarn config set prefix /usr/local \
 && yarn global add @google/jules@${JULES_VERSION} \
 && npm cache clean --force || true \
 && yarn cache clean || true

USER ubuntu
ENV HOME=/home/ubuntu

LABEL org.opencontainers.image.title="Jules Workbench" \
      org.opencontainers.image.description="Jules Workbench built on the universal base image" \
      org.opencontainers.image.version="${JULES_VERSION}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/jules-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_TAG}" \
      com.spigell.workbench.jules.version="${JULES_VERSION}"

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["jules --help || true"]
