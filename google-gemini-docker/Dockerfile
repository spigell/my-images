# syntax=docker/dockerfile:1.7

ARG GEMINI_BASIC_TAG=change-me
FROM ghcr.io/spigell/google-gemini-basic:${GEMINI_BASIC_TAG}
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

WORKDIR /project

# Editor tooling
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    vim \
  && rm -rf /var/lib/apt/lists/*

# Golang
ARG GOLANG_VERSION=1.25.1
RUN set -eux; \
  arch="${TARGETARCH:-amd64}"; \
  curl -fsSLo /tmp/go.tgz "https://golang.org/dl/go${GOLANG_VERSION}.linux-${arch}.tar.gz"; \
  tar -C /usr/local -xzf /tmp/go.tgz; \
  rm /tmp/go.tgz; \
  /usr/local/go/bin/go version

# Provided by --build-context shared=path/to/repo-root/shared
COPY --from=shared --chmod=0755 /setup-git-workbench.sh /usr/local/bin/setup-git-workbench
