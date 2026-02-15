# syntax=docker/dockerfile:1.18

ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG CLAUDE_CODE_VERSION=2.1.42
ARG SANDBOX_RUNTIME_VERSION=0.0.37

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG CLAUDE_CODE_VERSION
ARG UNIVERSAL_WORKBENCH_TAG
ARG SANDBOX_RUNTIME_VERSION

WORKDIR /project

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    bubblewrap=0.9.0-1ubuntu0.1 \
    socat=1.8.0.0-4build3 \
 && rm -rf /var/lib/apt/lists/*

RUN yarn config set prefix /usr/local \
 && yarn global add \
    @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
    @anthropic-ai/sandbox-runtime@${SANDBOX_RUNTIME_VERSION} \
 && (yarn cache clean || true)

USER ubuntu
ENV HOME=/home/ubuntu

LABEL org.opencontainers.image.title="Claude Code Workbench" \
      org.opencontainers.image.description="Claude Code CLI workbench built on the universal base image" \
      org.opencontainers.image.version="${CLAUDE_CODE_VERSION}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/claude-code-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_TAG}" \
      com.spigell.workbench.claude-code.version="${CLAUDE_CODE_VERSION}" \
      com.spigell.workbench.sandbox-runtime.version="${SANDBOX_RUNTIME_VERSION}"

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["claude --help || true"]
