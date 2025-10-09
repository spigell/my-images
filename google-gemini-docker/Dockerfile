# syntax=docker/dockerfile:1.7

ARG GEMINI_BASIC_TAG=change-me
FROM ghcr.io/spigell/google-gemini-basic:${GEMINI_BASIC_TAG}

WORKDIR /project

# Golang
ENV GOLANG_VERSION=1.25.1
ENV GOLANG_AMD64_SHA256=7716a0d940a0f6ae8e1f3b3f4f36299dc53e31b16840dbd171254312c41ca12e
ENV GOLANG_ARM64_SHA256=65a3e34fb2126f55b34e1edfc709121660e1be2dee6bdf405fc399a63a95a87d

RUN set -eux; \
  arch="${TARGETARCH:-amd64}"; \
  case "$arch" in \
    arm64) go_sha256="$GOLANG_ARM64_SHA256";; \
    amd64) go_sha256="$GOLANG_AMD64_SHA256";; \
    *) echo "unsupported TARGETARCH: $arch" >&2; exit 1;; \
  esac; \
  curl -fsSLo /tmp/go.tgz "https://golang.org/dl/go${GOLANG_VERSION}.linux-${arch}.tar.gz"; \
  echo "${go_sha256} /tmp/go.tgz" | sha256sum -c -; \
  tar -C /usr/local -xzf /tmp/go.tgz; \
  rm /tmp/go.tgz; \
  /usr/local/go/bin/go version

