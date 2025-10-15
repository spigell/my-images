# syntax=docker/dockerfile:1.7

FROM debian:12-slim
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

ARG GEMINI_CLI_VERSION=0.8.1
ARG NODE_VERSION=24
ARG PYTHON_VERSION=3.12

ARG DEBIAN_FRONTEND=noninteractive
RUN \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      bash-completion \
      build-essential \
      ca-certificates \
      curl \
      procps \
      git \
      unzip \
      less \
      libbz2-dev \
      libffi-dev \
      liblzma-dev \
      libncurses5-dev \
      libreadline-dev \
      libsqlite3-dev \
      libssl-dev \
      libxml2-dev \
      libxmlsec1-dev \
      lsb-release \
      software-properties-common \
      zlib1g-dev \
      xz-utils; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

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

### NODEJS ###

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

### GEMINI-CLI ###
RUN set -eux; \
    yarn global add @google/gemini-cli@${GEMINI_CLI_VERSION}

COPY etc/gemini-cli/system-defaults.json /etc/gemini-cli/system-defaults.json
COPY etc/profile.d/gemini-workbench-aliases.sh /etc/profile.d/gemini-workbench-aliases.sh

ENTRYPOINT []
CMD ["bash"]
