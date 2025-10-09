# syntax=docker/dockerfile:1.7

FROM debian:12-slim
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

ARG GEMINI_CLI_VERSION=0.8.1
ARG NODE_VERSION=24

USER root
ARG DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
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
  xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Python
# Install Pyenv and preinstall supported Python versions
RUN git clone --depth=1 https://github.com/pyenv/pyenv.git /usr/local/share/pyenv
ENV PYENV_ROOT /usr/local/share/pyenv
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
RUN pyenv install 3.12 && pyenv global 3.12
# Poetry
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/usr/local/share/pypoetry python3 -
RUN ln -s /usr/local/share/pypoetry/bin/poetry /usr/local/bin/
# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | XDG_BIN_HOME=/usr/local/share/uv bash -s -- --no-modify-path
RUN ln -s /usr/local/share/uv/uv /usr/local/bin/ && ln -s /usr/local/share/uv/uvx /usr/local/bin/

# Install default nodejs versions and associated tools
RUN curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "/usr/local/share/fnm" --skip-shell && \
  ln -s /usr/local/share/fnm/fnm /usr/local/bin/fnm
ENV FNM_COREPACK_ENABLED="true"
ENV FNM_VERSION_FILE_STRATEGY="recursive"
ENV FNM_DIR=/usr/local/share/fnm
RUN fnm install ${NODE_VERSION} && \
  fnm alias ${NODE_VERSION} default
ENV PATH=/usr/local/share/fnm/aliases/default/bin:$PATH
RUN npm install -g corepack && \
    corepack install -g pnpm yarn@1 && \
    yarn global add @google/gemini-cli@${GEMINI_CLI_VERSION}

ENTRYPOINT []
CMD ["bash"]

