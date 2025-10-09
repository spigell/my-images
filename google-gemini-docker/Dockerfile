# syntax=docker/dockerfile:1.7

ARG GEMINI_BASIC_TAG=change-me
FROM ghcr.io/spigell/google-gemini-basic:${GEMINI_BASIC_TAG}

WORKDIR /project

# Golang
ENV GOLANG_VERSION=1.24.5
ENV GOLANG_AMD64_SHA256=10ad9e86233e74c0f6590fe5426895de6bf388964210eac34a6d83f38918ecdc
ENV GOLANG_ARM64_SHA256=0df02e6aeb3d3c06c95ff201d575907c736d6c62cfa4b6934c11203f1d600ffa

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

