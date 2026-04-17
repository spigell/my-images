# syntax=docker/dockerfile:1.18

ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG GEMINI_CLI_VERSION=0.38.1
ARG GEMINI_CLI_GIT_URL=
ARG GEMINI_CLI_GIT_REF=

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG GEMINI_CLI_VERSION
ARG GEMINI_CLI_GIT_URL
ARG GEMINI_CLI_GIT_REF
ARG UNIVERSAL_WORKBENCH_TAG

WORKDIR /project

RUN yarn config set prefix /usr/local \
 && if [[ -n "${GEMINI_CLI_GIT_URL}" ]]; then \
      WORKDIR_TMP="$(mktemp -d)" \
      && git clone --depth 1 --branch "${GEMINI_CLI_GIT_REF}" "${GEMINI_CLI_GIT_URL}" "${WORKDIR_TMP}/gemini-cli" \
      && pushd "${WORKDIR_TMP}/gemini-cli" \
      && npm ci \
      && npm run bundle \
      && install -d -m 0755 /opt/gemini-cli \
      && cp -a bundle /opt/gemini-cli/ \
      && printf '#!/usr/bin/env bash\nexec node /opt/gemini-cli/bundle/gemini.js "$@"\n' > /usr/local/bin/gemini \
      && chmod 0755 /usr/local/bin/gemini \
      && popd \
      && rm -rf "${WORKDIR_TMP}"; \
    else \
      yarn global add @google/gemini-cli@${GEMINI_CLI_VERSION}; \
    fi \
 && command -v gemini >/dev/null \
 && gemini --version >/dev/null \
 && (npm cache clean --force || true) \
 && (yarn cache clean || true)

RUN install -d -m 0755 /etc/gemini-cli /etc/profile.d
COPY etc/gemini-cli/system-defaults.json /etc/gemini-cli/system-defaults.json
COPY etc/profile.d/gemini-workbench-aliases.sh /etc/profile.d/gemini-workbench-aliases.sh
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
