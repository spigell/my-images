# syntax=docker/dockerfile:1.18

ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG QWEN_CODE_VERSION=0.11.1
ARG SPLITRAIL_VERSION=3.2.2

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER ubuntu
ENV HOME=/home/ubuntu
ENV PATH="/home/ubuntu/.local/bin:${PATH}"

ARG QWEN_CODE_VERSION
ARG SPLITRAIL_VERSION
ARG UNIVERSAL_WORKBENCH_TAG

WORKDIR /project

RUN mkdir -p /home/ubuntu/.local/bin \
 && yarn config set prefix /home/ubuntu/.local \
 && yarn global add @qwen-code/qwen-code@${QWEN_CODE_VERSION} \
 && npm cache clean --force || true \
 && yarn cache clean || true

RUN ARCHIVE="splitrail-v${SPLITRAIL_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
 && ARCHDIR="splitrail-v${SPLITRAIL_VERSION}-x86_64-unknown-linux-gnu" \
 && curl -fsSL "https://github.com/Piebald-AI/splitrail/releases/download/v${SPLITRAIL_VERSION}/${ARCHIVE}" -o "/tmp/${ARCHIVE}" \
 && tar -xvf "/tmp/${ARCHIVE}" -C /tmp \
 && install -m 0755 "/tmp/${ARCHDIR}/splitrail" /home/ubuntu/.local/bin/splitrail \
 && rm -rf "/tmp/${ARCHIVE}" "/tmp/${ARCHDIR}"

LABEL org.opencontainers.image.title="Qwen Code Workbench" \
      org.opencontainers.image.description="Qwen Code CLI workbench built on the universal base image" \
      org.opencontainers.image.version="${QWEN_CODE_VERSION}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/qwen-code-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_TAG}" \
      com.spigell.workbench.qwen-code.version="${QWEN_CODE_VERSION}"

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["qwen --help || qwen-code --help || true"]
