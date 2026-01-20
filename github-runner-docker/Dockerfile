# syntax=docker/dockerfile:1.4

ARG BASE_IMAGE_NAME=change_me
ARG BASE_IMAGE_TAG=change_me
FROM ghcr.io/spigell/${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}
ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG

ENV DEBIAN_FRONTEND=noninteractive \
    RUNNER_USER=runner \
    RUNNER_HOME=/home/runner \
    ACTIONS_RUNNER_DIR=/actions-runner

USER root
ENV HOME=/root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        git \
        iproute2 \
        libcurl4 \
        libgssapi-krb5-2 \
        libicu74 \
        libkrb5-3 \
        liblttng-ust1 \
        libssl3t64 \
        libstdc++6 \
        unzip \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY fetch-runner-token.sh /usr/local/bin/fetch-runner-token.sh

RUN groupadd --gid 1001 "${RUNNER_USER}" \
    && useradd --home "${RUNNER_HOME}" --create-home --uid 1001 --gid 1001 --shell /bin/bash "${RUNNER_USER}" \
    && mkdir -p "${ACTIONS_RUNNER_DIR}" \
    && chown "${RUNNER_USER}:${RUNNER_USER}" "${ACTIONS_RUNNER_DIR}"

WORKDIR ${ACTIONS_RUNNER_DIR}

ARG RUNNER_VERSION=2.331.0
RUN curl -fsSL "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" -o runner.tar.gz \
    && tar --extract --file runner.tar.gz \
    && rm runner.tar.gz \
    && ./bin/installdependencies.sh \
    && chown -R "${RUNNER_USER}:${RUNNER_USER}" "${ACTIONS_RUNNER_DIR}"

RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/fetch-runner-token.sh \
    && chown "${RUNNER_USER}:${RUNNER_USER}" /usr/local/bin/entrypoint.sh /usr/local/bin/fetch-runner-token.sh

LABEL org.opencontainers.image.title="GitHub Actions Runner" \
      org.opencontainers.image.description="GitHub Actions runner layered on the ${BASE_IMAGE_NAME} workbench image" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/github-runner-docker" \
      com.spigell.workbench.base-image="${BASE_IMAGE_NAME}" \
      com.spigell.workbench.base-image-tag="${BASE_IMAGE_TAG}" \
      com.spigell.github-runner.version="${RUNNER_VERSION}"

USER ${RUNNER_USER}
ENV HOME=${RUNNER_HOME}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
