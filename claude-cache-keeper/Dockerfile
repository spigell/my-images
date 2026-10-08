# syntax=docker/dockerfile:1.27

ARG MY_NODEJS_LIBS_TAG=v0.8.0 # renovate: datasource=github-tags depName=spigell/my-nodejs-libs
ARG NODE_IMAGE_TAG=24.20.0-bookworm-slim # renovate: datasource=docker depName=node
ARG BUSYBOX_IMAGE_TAG=1.37.0 # renovate: datasource=docker depName=busybox

# The library source at the pinned tag. BuildKit fetches it itself; the
# repository is public, so no credentials are needed.
FROM scratch AS libs
ARG MY_NODEJS_LIBS_TAG
ADD https://github.com/spigell/my-nodejs-libs.git#${MY_NODEJS_LIBS_TAG} /

FROM node:${NODE_IMAGE_TAG} AS build
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Pinned so the cache mount lands where yarn actually looks.
ENV YARN_CACHE_FOLDER=/yarn-cache
ENV CI=true

WORKDIR /src
COPY --from=libs / ./

# The keeper uses only Node built-ins, so the two compiled modules and
# `package.json` (for `"type": "module"`) are all it needs; no node_modules.
# The last check proves the module graph loads.
RUN --mount=type=cache,target=/yarn-cache,sharing=locked \
    yarn install --frozen-lockfile --non-interactive; \
    yarn build; \
    install -d /out/opt/claude-cache-keeper/dist/bin /out/opt/claude-cache-keeper/dist/agents; \
    cp package.json /out/opt/claude-cache-keeper/; \
    cp dist/bin/claude-cache-keeper.js /out/opt/claude-cache-keeper/dist/bin/; \
    cp dist/agents/claude-cache-keeper.js /out/opt/claude-cache-keeper/dist/agents/; \
    node /out/opt/claude-cache-keeper/dist/bin/claude-cache-keeper.js --help | grep -q '^Usage: claude-cache-keeper'

# Busybox only supplies `cp` for the init container that copies the keeper into
# the pod. The keeper itself runs in the Claude workbench container on that
# image's Node and zmx, so it always talks to the zmx the sessions run under.
FROM busybox:${BUSYBOX_IMAGE_TAG}

ARG MY_NODEJS_LIBS_TAG
LABEL org.opencontainers.image.title="Claude cache keeper" \
      org.opencontainers.image.description="claude-cache-keeper from my-nodejs-libs, copied into Claude workbench pods by an init container" \
      org.opencontainers.image.version="${MY_NODEJS_LIBS_TAG}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images" \
      org.opencontainers.image.url="https://github.com/spigell/my-images" \
      org.opencontainers.image.documentation="https://github.com/spigell/my-images/blob/main/claude-cache-keeper/README.md"

COPY --from=build /out/ /
