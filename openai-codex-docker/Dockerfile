# syntax=docker/dockerfile:1.4

ARG CODEX_BINARY_REF=rust-v0.46.0

FROM ghcr.io/spigell/codex-binary:${CODEX_BINARY_REF} AS codex
FROM ubuntu:24.04
LABEL codex.binary.ref="${CODEX_BINARY_REF}"
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

ARG PYTHON_VERSION=3.12
ARG NODE_VERSION=24
ARG GOLANG_VERSION=1.25.1

ENV LANG="C.UTF-8"
ENV HOME=/root

# Packages are taken from universal codex image
ENV GOPATH=/go
ENV PATH="${GOPATH}/bin:/usr/local/go/bin:${PATH}"
ENV DEBIAN_FRONTEND=noninteractive
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
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
        zlib1g-dev=1:1.3.*; \
    rm -rf /var/lib/apt/lists/*; \
    arch="${TARGETARCH:-amd64}"; \
    curl -fsSLo /tmp/go.tgz "https://golang.org/dl/go${GOLANG_VERSION}.linux-${arch}.tar.gz"; \
    tar -C /usr/local -xzf /tmp/go.tgz; \
    rm /tmp/go.tgz; \
    /usr/local/go/bin/go version


### PYTHON ###

ENV PYENV_ROOT=/usr/local/share/pyenv
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
ENV UV_NO_PROGRESS=1
RUN set -eux; \
    git clone --depth=1 https://github.com/pyenv/pyenv.git "$PYENV_ROOT"; \
    pyenv install "${PYTHON_VERSION}"; \
    pyenv global "${PYTHON_VERSION}"; \
    pyenv rehash; \
    curl -sSL https://install.python-poetry.org | POETRY_HOME=/usr/local/share/pypoetry python3 -; \
    ln -s /usr/local/share/pypoetry/bin/poetry /usr/local/bin/; \
    curl -LsSf https://astral.sh/uv/install.sh | XDG_BIN_HOME=/usr/local/share/uv bash -s -- --no-modify-path; \
    ln -sf /usr/local/share/uv/uv /usr/local/bin/uv; \
    ln -sf /usr/local/share/uv/uvx /usr/local/bin/uvx; \
    python3 -m pip install --no-cache-dir --upgrade pip; \
    pip install --no-cache-dir ruff black mypy pyright isort pytest; \
    rm -rf /root/.cache/pip

### NODEJS

ENV FNM_COREPACK_ENABLED="true"
ENV FNM_VERSION_FILE_STRATEGY="recursive"
ENV FNM_DIR=/usr/local/share/fnm
ENV PATH="/usr/local/share/fnm/aliases/default/bin:${PATH}"
RUN set -eux; \
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$FNM_DIR" --skip-shell; \
    ln -sf "$FNM_DIR/fnm" /usr/local/bin/fnm; \
    fnm install "${NODE_VERSION}"; \
    fnm alias "${NODE_VERSION}" default; \
    npm install -g corepack yarn; \
    corepack enable; \
    npm cache clean --force || true

### CODEX

ENV CODEX_UNSAFE_ALLOW_NO_SANDBOX=1
ENV CODEX_HOME=/workspace/codex
WORKDIR $CODEX_HOME

# Create directory (for clarity) and copy binary
RUN mkdir -p $CODEX_HOME
COPY --from=codex /usr/local/bin/codex /usr/local/bin/codex

COPY setup-git-workbench.sh /usr/local/bin/setup-git-workbench
RUN chmod +x /usr/local/bin/setup-git-workbench

ENTRYPOINT ["codex"]
