# syntax=docker/dockerfile:1.7

FROM debian:12-slim
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

ARG NVM_VERSION=v0.40.2
ARG NODE_VERSION=24

USER root
ARG DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        bash-completion \
        ca-certificates \
        curl \
        git \
        unzip \
        less \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


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
    corepack install -g pnpm yarn@1

# Nodejs
# ENV NVM_DIR=/usr/local/nvm
# ENV YARN_GLOBAL_FOLDER=/usr/local/share/yarn

# RUN git -c advice.detachedHead=0 clone --branch "$NVM_VERSION" --depth 1 https://github.com/nvm-sh/nvm.git "$NVM_DIR" \
#    && install -d -m 0755 "$YARN_GLOBAL_FOLDER" \
#    && echo 'source $NVM_DIR/nvm.sh' >> /etc/profile \
#    && . "$NVM_DIR/nvm.sh" \
#    && nvm install "$NODE_VERSION" \
#    && nvm alias default "$NODE_VERSION" \
#    && nvm use default \
#    && npm install -g yarn \
#    && yarn global add gemini-cli \
#    && YARN_GLOBAL_BIN="$(yarn global bin)" \
#    && for bin in node yarn; do \
#         ln -sf "$(command -v "$bin")" "/usr/local/bin/$bin"; \
#       done \
#    && chmod -R a+rX "$NVM_DIR" "$YARN_GLOBAL_FOLDER" \
#    && yarn cache clean || true \
#    && rm -rf ~/.cache/yarn \
#    && nvm cache clear \
#    && npm cache clean --force || true

ENTRYPOINT []
CMD ["bash"]

