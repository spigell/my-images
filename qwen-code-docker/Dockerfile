# syntax=docker/dockerfile:1.25

ARG UNIVERSAL_WORKBENCH_IMAGE_TAG=sha-dev
ARG QWEN_CODE_VERSION=0.18.0 # renovate: datasource=npm depName=@qwen-code/qwen-code

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_IMAGE_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG QWEN_CODE_VERSION
ARG UNIVERSAL_WORKBENCH_IMAGE_TAG

WORKDIR /project

RUN yarn config set prefix /usr/local \
 && yarn global add @qwen-code/qwen-code@${QWEN_CODE_VERSION} \
 && npm cache clean --force || true \
 && yarn cache clean || true

USER ubuntu
ENV HOME=/home/ubuntu

LABEL org.opencontainers.image.title="Qwen Code Workbench" \
      org.opencontainers.image.description="Qwen Code CLI workbench built on the universal base image" \
      org.opencontainers.image.version="${QWEN_CODE_VERSION}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/qwen-code-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_IMAGE_TAG}" \
      com.spigell.workbench.qwen-code.version="${QWEN_CODE_VERSION}"

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["qwen --help || qwen-code --help || true"]
