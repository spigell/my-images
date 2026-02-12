# syntax=docker/dockerfile:1.18

ARG ZMX_BINARY_REF=0.1.0
ARG ZMX_BINARY_IMAGE=ghcr.io/spigell/zmx-binary
ARG MCP_PROXY_VERSION=v0.10.0
ARG MCP_SHELL_SERVER_VERSION=fd7863bf397494e15d3184fcb2e2d09e34f37920

FROM ${ZMX_BINARY_IMAGE}:${ZMX_BINARY_REF} AS zmx-binary

FROM ubuntu:24.04 AS universal-base
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ARG UNIVERSAL_WORKBENCH_VERSION=1.0.5
ARG PYTHON_VERSION=3.13.7
ARG NODE_VERSION=22.21.1
ARG GOLANG_VERSION=1.25.5
ARG GOLANGCI_LINT_VERSION=2.7.1
ARG DELVE_VERSION=1.25.2
ARG TARGETARCH=amd64
ARG YARN_VERSION=1.22.22
ARG SPECIFY_VERSION=v0.0.90
ARG ZMX_BINARY_REF
ARG MCP_PROXY_VERSION
ARG MCP_SHELL_SERVER_VERSION

ENV LANG="C.UTF-8"
ENV UBUNTU_HOME=/home/ubuntu
ENV UBUNTU_GOPATH=/home/ubuntu/go
ENV PATH="/usr/local/go/bin:${PATH}"
ENV HOME=/root
ENV DEBIAN_FRONTEND=noninteractive

# Install apt dependencies shared by Codex and Gemini plus requested GNU utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
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
        dpkg \
        software-properties-common=0.99.* \
        sqlite3=3.45.* \
        swig3.0=3.0.* \
        tk-dev=8.6.* \
        tzdata=2025b-* \
        unixodbc-dev=2.3.* \
        unzip=6.0-* \
        uuid-dev=2.39.* \
        vim=2:9.* \
        wget=1.21.* \
        xz-utils=5.6.* \
        zip=3.0-* \
        zlib1g=1:1.3.* \
        zlib1g-dev=1:1.3.* \
        python3 \
        python3-pip \
        file \
        less \
        tmux=3.4-* \
        tree \
    && rm -rf /var/lib/apt/lists/*

# Install .NET SDKs for LTS (8) and current (9) channels
RUN curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 8.0 --install-dir /usr/local/share/dotnet \
 && curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 9.0 --install-dir /usr/local/share/dotnet

ENV DOTNET_ROOT=/usr/local/share/dotnet
ENV PATH="/usr/local/share/dotnet:${PATH}"
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
# Allow newer dotnet versions to build projects targeting older frameworks (v3.1)
ENV DOTNET_ROLL_FORWARD=Major

# Install golangci-lint
RUN arch="${TARGETARCH:-amd64}"; \
    curl -fsSL -o /tmp/golangci-lint.deb "https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION}-linux-${arch}.deb"; \
    dpkg -i /tmp/golangci-lint.deb || apt-get -y -f install; \
    rm /tmp/golangci-lint.deb; \
    rm -rf /var/lib/apt/lists/*

# Common runtime utilities required by downstream workbenches
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
      bash-completion tar iproute2 \
    && rm -rf /var/lib/apt/lists/*

# QoL defaults shared by all workbenches
RUN echo 'source /usr/share/bash-completion/bash_completion || true' >> /etc/bash.bashrc

# Pull common dotfiles for the ubuntu user
RUN git clone --depth=1 https://github.com/spigell/dotfiles /tmp/dotfiles \
 && install -d "${UBUNTU_HOME}/.vim/configs" \
 && cp /tmp/dotfiles/bash/bashrc "${UBUNTU_HOME}/.bashrc" \
 && cp /tmp/dotfiles/bash/bash_profile "${UBUNTU_HOME}/.bash_profile" \
 && cp /tmp/dotfiles/git/gitconfig "${UBUNTU_HOME}/.gitconfig" \
 && cp /tmp/dotfiles/vim/vimrc "${UBUNTU_HOME}/.vimrc" \
 && cp /tmp/dotfiles/vim/pluginsrc "${UBUNTU_HOME}/.vim/configs/pluginsrc" \
 && printf '\n" Theme\nBundle '"'"'morhetz/gruvbox'"'"'\n' >> "${UBUNTU_HOME}/.vim/configs/pluginsrc" \
 && sed -i 's/\\<colorscheme\\s\\+desert\\>/colorscheme gruvbox/g' "${UBUNTU_HOME}/.vimrc" \
 && cat >> "${UBUNTU_HOME}/.vimrc" <<'EOF'\n\n\" Ensure the colorscheme is applied after plugins are on 'runtimepath'.\naugroup WorkbenchTheme\n  autocmd!\n  autocmd VimEnter * silent! colorscheme gruvbox\naugroup END\nEOF\n \
 && install -d -m 0755 "${UBUNTU_HOME}/.vim/bundle" \
 && git clone --depth=1 https://github.com/VundleVim/Vundle.vim "${UBUNTU_HOME}/.vim/bundle/Vundle.vim" \
 && ln -s "${UBUNTU_HOME}/.vim/bundle/Vundle.vim" "${UBUNTU_HOME}/.vim/bundle/vundle" \
 && HOME="${UBUNTU_HOME}" su -s /bin/bash ubuntu -c "vim -Nu ~/.vimrc -n -i NONE -es +'silent! BundleInstall' +'qa!'" \
 && chown -R ubuntu:ubuntu "${UBUNTU_HOME}/.bashrc" "${UBUNTU_HOME}/.bash_profile" "${UBUNTU_HOME}/.gitconfig" "${UBUNTU_HOME}/.vimrc" "${UBUNTU_HOME}/.vim" \
 && rm -rf /tmp/dotfiles

# Install Go toolchain
RUN arch="${TARGETARCH:-amd64}"; \
    curl -fsSLo /tmp/go.tgz "https://golang.org/dl/go${GOLANG_VERSION}.linux-${arch}.tar.gz"; \
    tar -C /usr/local -xzf /tmp/go.tgz; \
    rm /tmp/go.tgz; \
    /usr/local/go/bin/go version

# Install delve
RUN install -d -m 0755 "${UBUNTU_GOPATH}" "${UBUNTU_GOPATH}/pkg" "${UBUNTU_GOPATH}/pkg/mod" "${UBUNTU_HOME}/.cache/go-build"
RUN --mount=type=cache,target=/home/ubuntu/.cache/go-build \
    --mount=type=cache,target=/home/ubuntu/go/pkg/mod \
    GOBIN=/usr/local/bin /usr/local/go/bin/go install github.com/go-delve/delve/cmd/dlv@v${DELVE_VERSION}
RUN chown -R ubuntu:ubuntu "${UBUNTU_GOPATH}" "${UBUNTU_HOME}/.cache"

# Python via pyenv + tooling
ENV PYENV_ROOT=/usr/local/share/pyenv
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
ENV UV_NO_PROGRESS=1
RUN git clone --depth=1 https://github.com/pyenv/pyenv.git "$PYENV_ROOT"; \
    pyenv install "${PYTHON_VERSION}"; \
    pyenv global "${PYTHON_VERSION}"; \
    pyenv rehash; \
    curl -sSL https://install.python-poetry.org | POETRY_HOME=/usr/local/share/pypoetry python3 -; \
    ln -s /usr/local/share/pypoetry/bin/poetry /usr/local/bin/; \
    poetry self add poetry-plugin-export; \
    curl -LsSf https://astral.sh/uv/install.sh | XDG_BIN_HOME=/usr/local/share/uv bash -s -- --no-modify-path; \
    ln -sf /usr/local/share/uv/uv /usr/local/bin/uv; \
    ln -sf /usr/local/share/uv/uvx /usr/local/bin/uvx; \
    UV_PYTHON_INSTALL_DIR=/usr/local/share/uv-python XDG_DATA_HOME=/usr/local/share/uv-data XDG_BIN_HOME=/usr/local/bin uv tool install specify-cli --from "git+https://github.com/github/spec-kit.git@${SPECIFY_VERSION}"; \
    UV_PYTHON_INSTALL_DIR=/usr/local/share/uv-python XDG_DATA_HOME=/usr/local/share/uv-data XDG_BIN_HOME=/usr/local/bin uv tool install "git+https://github.com/tumf/mcp-shell-server.git@${MCP_SHELL_SERVER_VERSION}"; \
    UV_PYTHON_INSTALL_DIR=/usr/local/share/uv-python XDG_DATA_HOME=/usr/local/share/uv-data XDG_BIN_HOME=/usr/local/bin uv tool install "git+https://github.com/sparfenyuk/mcp-proxy.git@${MCP_PROXY_VERSION}"; \
    python3 -m pip install --no-cache-dir --upgrade pip; \
    rm -rf "${HOME}/.cache/pip"

# Node.js via fnm with Yarn
ENV FNM_COREPACK_ENABLED="true"
ENV FNM_VERSION_FILE_STRATEGY="recursive"
ENV FNM_DIR=/usr/local/share/fnm
ENV PATH="/usr/local/share/fnm/aliases/default/bin:${PATH}"
RUN curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$FNM_DIR" --skip-shell; \
    ln -sf "$FNM_DIR/fnm" /usr/local/bin/fnm; \
    fnm install "${NODE_VERSION}"; \
    fnm alias "${NODE_VERSION}" default; \
    npm install -g corepack; \
    corepack enable; \
    corepack prepare "yarn@${YARN_VERSION}" --activate; \
    npm cache clean --force || true

# Provided by --build-context shared=path/to/repo-root/shared
COPY --from=shared --chmod=0755 /setup-git-workbench.sh /usr/local/bin/setup-git-workbench
COPY --from=shared --chmod=0755 /start-shell-mcp.sh /usr/local/bin/start-shell-mcp

COPY --from=zmx-binary /zmx /usr/local/bin/zmx

RUN install -d -m 0755 "${UBUNTU_HOME}" && chown -R ubuntu:ubuntu "${UBUNTU_HOME}"

USER ubuntu
ENV HOME="${UBUNTU_HOME}"
ENV GOPATH="${UBUNTU_GOPATH}"
ENV PATH="${GOPATH}/bin:/usr/local/go/bin:${PATH}"

LABEL org.opencontainers.image.title="Universal Workbench" \
      org.opencontainers.image.description="Common Ubuntu 24.04 workbench runtime with Go, Python, Node.js, delve, yarn, and shared tooling for Codex and Gemini" \
      org.opencontainers.image.version="${UNIVERSAL_WORKBENCH_VERSION}" \
      org.opencontainers.image.authors="spigell (spigelly@gmail.com)" \
      org.opencontainers.image.vendor="individual" \
      org.opencontainers.image.source="https://github.com/spigell/my-images" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.python.version="${PYTHON_VERSION}" \
      com.spigell.workbench.python.manager="pyenv" \
      com.spigell.workbench.node.version="${NODE_VERSION}" \
      com.spigell.workbench.node.manager="fnm" \
      com.spigell.workbench.go.version="${GOLANG_VERSION}" \
      com.spigell.workbench.go.delve-version="${DELVE_VERSION}" \
      com.spigell.workbench.specify.version="${SPECIFY_VERSION}" \
      com.spigell.workbench.golangci-lint.version="${GOLANGCI_LINT_VERSION}" \
      com.spigell.workbench.zmx.version="${ZMX_BINARY_REF}" \
      com.spigell.workbench.package-manager="apt"

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["python --version && node --version && go version && dlv version && yarn --version || true"]
