# syntax=docker/dockerfile:1.4

ARG CODEX_BINARY_REF=rust-v0.40.0

FROM ghcr.io/spigell/codex-binary:${CODEX_BINARY_REF} AS codex
FROM ubuntu:24.04

ENV LANG="C.UTF-8"
ENV HOME=/root
ENV DEBIAN_FRONTEND=noninteractive

ARG CODEX_BINARY_REF

# Taken from universal image
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        binutils=2.42-* \
        sudo=1.9.* \
        build-essential=12.10* \
        bzr=2.7.* \
        curl=8.5.* \
        default-libmysqlclient-dev=1.1.* \
        dnsutils=1:9.18.* \
        gettext=0.21-* \
        git=1:2.43.* \
        git-lfs=3.4.* \
        gnupg=2.4.* \
        inotify-tools=3.22.* \
        iputils-ping=3:20240117-* \
        jq=1.7.* \
        libbz2-dev=1.0.* \
        libc6=2.39-* \
        libc6-dev=2.39-* \
        libcurl4-openssl-dev=8.5.* \
        libdb-dev=1:5.3.* \
        libedit2=3.1-* \
        libffi-dev=3.4.* \
        libgcc-13-dev=13.3.* \
        libgdbm-compat-dev=1.23-* \
        libgdbm-dev=1.23-* \
        libgdiplus=6.1+dfsg-* \
        libgssapi-krb5-2=1.20.* \
        liblzma-dev=5.6.* \
        libncurses-dev=6.4+20240113-* \
        libnss3-dev=2:3.98-* \
        libpq-dev \
        libpsl-dev=0.21.* \
        libpython3-dev=3.12.* \
        libreadline-dev=8.2-* \
        libsqlite3-dev=3.45.* \
        libssl-dev=3.0.* \
        libstdc++-13-dev=13.3.* \
        libunwind8=1.6.* \
        libuuid1=2.39.* \
        libxml2-dev=2.9.* \
        libz3-dev=4.8.* \
        make=4.3-* \
        moreutils=0.69-* \
        netcat-openbsd=1.226-* \
        openssh-client=1:9.6p1-* \
        pkg-config=1.8.* \
        protobuf-compiler=3.21.* \
        ripgrep=14.1.* \
        rsync=3.2.* \
        software-properties-common=0.99.* \
        sqlite3=3.45.* \
        swig3.0=3.0.* \
        tk-dev=8.6.* \
        tzdata=2025b-* \
        unixodbc-dev=2.3.* \
        unzip=6.0-* \
        uuid-dev=2.39.* \
        wget=1.21.* \
        xz-utils=5.6.* \
        zip=3.0-* \
        zlib1g=1:1.3.* \
        zlib1g-dev=1:1.3.* \
    && rm -rf /var/lib/apt/lists/*


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

ENV GOPATH=/go
ENV PATH="${GOPATH}/bin:/usr/local/go/bin:${PATH}"

### PYTHON ###

ARG PYENV_VERSION=v2.5.5
ARG PYTHON_VERSIONS="3.12.6"

ENV PYENV_ROOT=/root/.pyenv
ENV PATH="${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:${PATH}"

RUN git -c advice.detachedHead=0 clone --branch "$PYENV_VERSION" --depth 1 https://github.com/pyenv/pyenv.git "$PYENV_ROOT" \
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /etc/profile \
    && echo 'export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"' >> /etc/profile \
    && echo 'eval "$(pyenv init - bash)"' >> /etc/profile \
    && cd "$PYENV_ROOT" \
    && src/configure \
    && make -C src \
    && for version in $PYTHON_VERSIONS; do pyenv install "$version"; done \
    && pyenv global "${PYTHON_VERSIONS%% *}" \
    && rm -rf "$PYENV_ROOT/cache"

ENV PIPX_BIN_DIR=/root/.local/bin
ENV PATH="${PIPX_BIN_DIR}:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends pipx=1.4.* \
    && rm -rf /var/lib/apt/lists/* \
    && pipx install --pip-args="--no-cache-dir --no-compile" poetry==2.1.* uv==0.7.* \
    && for pyv in "${PYENV_ROOT}/versions/"*; do \
         "$pyv/bin/python" -m pip install --no-cache-dir --no-compile --upgrade pip && \
         "$pyv/bin/pip" install --no-cache-dir --no-compile ruff black mypy pyright isort pytest; \
       done \
    && rm -rf /root/.cache/pip ~/.cache/pip ~/.cache/pipx

ENV UV_NO_PROGRESS=1

### NODE & TYPESCRIPT ###

ARG NVM_VERSION=v0.40.2
ARG NODE_VERSION=22

ENV NVM_DIR=/root/.nvm

RUN git -c advice.detachedHead=0 clone --branch "$NVM_VERSION" --depth 1 https://github.com/nvm-sh/nvm.git "$NVM_DIR" \
    && echo 'source $NVM_DIR/nvm.sh' >> /etc/profile \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install "$NODE_VERSION" \
    && nvm alias default "$NODE_VERSION" \
    && nvm use default \
    && npm install -g yarn \
    && yarn global add prettier eslint typescript \
    && YARN_GLOBAL_BIN="$(yarn global bin)" \
    && for bin in node yarn; do \
         ln -sf "$(command -v "$bin")" "/usr/local/bin/$bin"; \
       done \
    && for tsbin in prettier eslint tsc tsserver; do \
         ln -sf "${YARN_GLOBAL_BIN}/$tsbin" "/usr/local/bin/$tsbin"; \
       done \
    && yarn cache clean || true \
    && rm -rf ~/.cache/yarn \
    && nvm cache clear \
    && npm cache clean --force || true

ENV CODEX_UNSAFE_ALLOW_NO_SANDBOX=1
LABEL codex.binary.ref="${CODEX_BINARY_REF}"

# Set up project directory
ENV CODEX_HOME=/workspace/codex
WORKDIR $CODEX_HOME

# Create directory (for clarity) and copy binary
RUN mkdir -p $CODEX_HOME
COPY --from=codex /usr/local/bin/codex /usr/local/bin/codex

ENTRYPOINT ["codex"]
