# syntax=docker/dockerfile:1.18

ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG CLAUDE_CODE_VERSION=2.1.42

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG CLAUDE_CODE_VERSION
ARG UNIVERSAL_WORKBENCH_TAG

WORKDIR /project

RUN yarn config set prefix /usr/local \
 && yarn global add @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
 && (npm cache clean --force || true) \
 && (yarn cache clean || true)

USER ubuntu
ENV HOME=/home/ubuntu

LABEL org.opencontainers.image.title="Claude Code Workbench" \
      org.opencontainers.image.description="Claude Code CLI workbench built on the universal base image" \
      org.opencontainers.image.version="${CLAUDE_CODE_VERSION}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/claude-code-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_TAG}" \
      com.spigell.workbench.claude-code.version="${CLAUDE_CODE_VERSION}"

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["claude --help || true"]
