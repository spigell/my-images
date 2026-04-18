# syntax=docker/dockerfile:1.18

ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG GEMINI_CLI_VERSION=0.38.1

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG GEMINI_CLI_VERSION
ARG UNIVERSAL_WORKBENCH_TAG

WORKDIR /project

RUN yarn config set prefix /usr/local \
 && yarn global add @google/gemini-cli@${GEMINI_CLI_VERSION} \
 && command -v gemini >/dev/null \
 && gemini --version >/dev/null \
 && (npm cache clean --force || true) \
 && (yarn cache clean || true)

RUN install -d -m 0755 /etc/gemini-cli
COPY etc/gemini-cli/system-defaults.json /etc/gemini-cli/system-defaults.json
USER ubuntu
ENV HOME=/home/ubuntu

LABEL org.opencontainers.image.title="Google Gemini Workbench" \
      org.opencontainers.image.description="Google Gemini CLI workbench built on the universal base image" \
      org.opencontainers.image.version="${GEMINI_CLI_VERSION}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/google-gemini-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_TAG}" \
      com.spigell.workbench.gemini-cli.version="${GEMINI_CLI_VERSION}"

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["gemini --help || true"]
