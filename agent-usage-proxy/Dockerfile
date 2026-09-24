# syntax=docker/dockerfile:1.27

ARG MY_NODEJS_LIBS_TAG=v0.5.0 # renovate: datasource=github-tags depName=spigell/my-nodejs-libs
ARG NODE_IMAGE_TAG=24.20.0-bookworm-slim # renovate: datasource=docker depName=node

# The library source at the pinned tag. BuildKit fetches it itself; the
# repository is public, so no credentials are needed.
FROM scratch AS libs
ARG MY_NODEJS_LIBS_TAG
ADD https://github.com/spigell/my-nodejs-libs.git#${MY_NODEJS_LIBS_TAG} /

# Node matches the major the agent workbenches run (universal-workbench's
# NODE_VERSION), because the pruned node_modules is copied into those images
# and executed there.
FROM node:${NODE_IMAGE_TAG} AS build
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Pinned so the cache mount lands where yarn actually looks.
ENV YARN_CACHE_FOLDER=/yarn-cache
ENV CI=true

WORKDIR /src
COPY --from=libs / ./

# The production prune runs after the build because the compiler is a dev
# dependency. `package.json` travels with the output: it carries
# `"type": "module"`, without which Node cannot load `dist/`. The last check
# proves the module graph loads: with no USAGE_AGENT the bin parses its
# configuration and exits 2.
RUN --mount=type=cache,target=/yarn-cache,sharing=locked \
    yarn install --frozen-lockfile --non-interactive; \
    yarn build; \
    test -f dist/bin/agent-usage-proxy.js; \
    rm -rf node_modules; \
    yarn install --frozen-lockfile --non-interactive --production=true; \
    install -d /out/opt/agent-usage-proxy /out/usr/local/bin; \
    cp -a package.json dist node_modules /out/opt/agent-usage-proxy/; \
    printf '#!/bin/sh\nexec node /opt/agent-usage-proxy/dist/bin/agent-usage-proxy.js "$@"\n' \
      > /out/usr/local/bin/agent-usage-proxy; \
    chmod 0755 /out/usr/local/bin/agent-usage-proxy; \
    (USAGE_AGENT= node /out/opt/agent-usage-proxy/dist/bin/agent-usage-proxy.js || [ $? -eq 2 ])

# Not runnable on its own: it carries no Node. Agent workbench images copy both
# paths in and run the wrapper on their own Node.
FROM scratch

ARG MY_NODEJS_LIBS_TAG
LABEL org.opencontainers.image.title="Agent usage proxy" \
      org.opencontainers.image.description="agent-usage-proxy from my-nodejs-libs, built for copying into agent workbench images" \
      org.opencontainers.image.version="${MY_NODEJS_LIBS_TAG}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images" \
      org.opencontainers.image.url="https://github.com/spigell/my-images" \
      org.opencontainers.image.documentation="https://github.com/spigell/my-images/blob/main/agent-usage-proxy/README.md"

COPY --from=build /out/ /
