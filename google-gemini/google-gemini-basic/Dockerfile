# syntax=docker/dockerfile:1.7

ARG VARIANT=22-bookworm
FROM mcr.microsoft.com/devcontainers/typescript-node:${VARIANT}

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ARG USERNAME=node
ARG GEMINI_CLI_PACKAGE="@google/gemini-cli"
ARG GEMINI_CLI_VERSION=""

ENV NPM_CONFIG_FUND=false \
    NPM_CONFIG_AUDIT=false \
    NPM_CONFIG_UPDATE_NOTIFIER=false

RUN --mount=type=cache,target=/home/${USERNAME}/.npm /bin/bash -euxo pipefail <<SCRIPT
package="${GEMINI_CLI_PACKAGE}${GEMINI_CLI_VERSION:+@${GEMINI_CLI_VERSION}}"
su "${USERNAME}" -lc "umask 0002 && npm install --global --omit=dev --loglevel=error \"\${package}\""
su "${USERNAME}" -lc "npm cache clean --force --loglevel=error >/dev/null 2>&1 || true"
rm -rf /home/${USERNAME}/.npm/_cacache /home/${USERNAME}/.npm/_logs || true
SCRIPT

USER ${USERNAME}

ENTRYPOINT []
CMD ["bash"]
