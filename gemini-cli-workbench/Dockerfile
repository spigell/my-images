# syntax=docker/dockerfile:1.7

ARG GEMINI_CLI_TAG=latest
FROM ghcr.io/spigell/gemini-cli:${GEMINI_CLI_TAG}

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ARG DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        bash-completion \
        ca-certificates \
        curl \
        git \
        jq \
        less \
        openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER node
WORKDIR /workspace

ENTRYPOINT ["bash", "-lc"]
CMD ["gemini --help"]
