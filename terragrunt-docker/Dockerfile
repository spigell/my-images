# syntax=docker/dockerfile:1.18

ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG TERRAGRUNT_VERSION=1.0.0
ARG TENV_VERSION=v4.10.1
ARG TARGETOS=linux
ARG TARGETARCH=amd64

FROM debian:bookworm-slim AS fetch
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ARG TERRAGRUNT_VERSION
ARG TENV_VERSION
ARG TARGETOS
ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/fetch

RUN curl -fsSL -o terragrunt \
      "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_${TARGETOS}_${TARGETARCH}" \
    && chmod +x terragrunt

RUN arch="${TARGETARCH:-amd64}"; \
    case "${arch}" in \
      amd64) tenv_arch="x86_64" ;; \
      arm64) tenv_arch="arm64" ;; \
      *) echo "Unsupported tenv architecture: ${arch}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o tenv.tar.gz \
      "https://github.com/tofuutils/tenv/releases/download/${TENV_VERSION}/tenv_${TENV_VERSION}_Linux_${tenv_arch}.tar.gz"; \
    tar -xzf tenv.tar.gz tenv; \
    chmod +x tenv; \
    rm -f tenv.tar.gz

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG TERRAGRUNT_VERSION
ARG TENV_VERSION
ARG UNIVERSAL_WORKBENCH_TAG

COPY --from=fetch /tmp/fetch/terragrunt /usr/local/bin/terragrunt
COPY --from=fetch /tmp/fetch/tenv /usr/local/bin/tenv

USER ubuntu
ENV HOME=/home/ubuntu

LABEL org.opencontainers.image.title="Terragrunt Workbench" \
      org.opencontainers.image.description="Universal workbench derivative with Terragrunt CLI" \
      org.opencontainers.image.version="${TERRAGRUNT_VERSION}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/terragrunt-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_TAG}" \
      com.spigell.workbench.terragrunt.version="${TERRAGRUNT_VERSION}" \
      com.spigell.workbench.tenv.version="${TENV_VERSION}"

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["terragrunt --version"]
