# syntax=docker/dockerfile:1.18

ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG CLAUDE_CODE_VERSION=2.1.25
ARG SPLITRAIL_VERSION=3.2.2

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG CLAUDE_CODE_VERSION
ARG SPLITRAIL_VERSION
ARG UNIVERSAL_WORKBENCH_TAG

WORKDIR /project

RUN yarn config set prefix /usr/local \
 && yarn global add @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
 && npm cache clean --force || true \
 && yarn cache clean || true

RUN ARCHIVE="splitrail-v${SPLITRAIL_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
 && ARCHDIR="splitrail-v${SPLITRAIL_VERSION}-x86_64-unknown-linux-gnu" \
 && curl -fsSL "https://github.com/Piebald-AI/splitrail/releases/download/v${SPLITRAIL_VERSION}/${ARCHIVE}" -o "/tmp/${ARCHIVE}" \
 && tar -xvf "/tmp/${ARCHIVE}" -C /tmp \
 && install -m 0755 "/tmp/${ARCHDIR}/splitrail" /usr/local/bin/splitrail \
 && rm -rf "/tmp/${ARCHIVE}" "/tmp/${ARCHDIR}"

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
