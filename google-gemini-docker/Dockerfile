# syntax=docker/dockerfile:1.18

ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG GEMINI_CLI_VERSION=0.38.1
ARG SPLITRAIL_VERSION=3.2.2

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG GEMINI_CLI_VERSION
ARG SPLITRAIL_VERSION
ARG UNIVERSAL_WORKBENCH_TAG

WORKDIR /project

COPY scripts/apply-gemini-routing-patch.sh /usr/local/bin/apply-gemini-routing-patch.sh

RUN yarn config set prefix /usr/local \
 && yarn global add @google/gemini-cli@${GEMINI_CLI_VERSION} \
 && chmod +x /usr/local/bin/apply-gemini-routing-patch.sh \
 && /usr/local/bin/apply-gemini-routing-patch.sh \
 && npm cache clean --force || true \
 && yarn cache clean || true

RUN ARCHIVE="splitrail-v${SPLITRAIL_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
 && ARCHDIR="splitrail-v${SPLITRAIL_VERSION}-x86_64-unknown-linux-gnu" \
 && curl -fsSL "https://github.com/Piebald-AI/splitrail/releases/download/v${SPLITRAIL_VERSION}/${ARCHIVE}" -o "/tmp/${ARCHIVE}" \
 && tar -xvf "/tmp/${ARCHIVE}" -C /tmp \
 && install -m 0755 "/tmp/${ARCHDIR}/splitrail" /usr/local/bin/splitrail \
 && rm -rf "/tmp/${ARCHIVE}" "/tmp/${ARCHDIR}"

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
