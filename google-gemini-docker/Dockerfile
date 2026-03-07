# syntax=docker/dockerfile:1.18

ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG GEMINI_CLI_PACKAGE_SPEC=@google/gemini-cli@0.32.1
ARG GEMINI_CLI_VERSION_LABEL=0.32.1-pr20572-patched
ARG SPLITRAIL_VERSION=3.2.2

FROM golang:1.25.5-alpine AS builder
# COPY gemini-telemetry/go.mod gemini-telemetry/go.sum ./
COPY gemini-telemetry/go.mod ./
RUN go mod download
COPY gemini-telemetry ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags="-w -s" -o /gemini-telemetry .

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG GEMINI_CLI_PACKAGE_SPEC
ARG GEMINI_CLI_VERSION_LABEL
ARG SPLITRAIL_VERSION
ARG UNIVERSAL_WORKBENCH_TAG

WORKDIR /project

RUN yarn config set prefix /usr/local \
 && yarn global add "${GEMINI_CLI_PACKAGE_SPEC}" \
 && GEMINI_COMPOSER_JS="$(yarn global dir)/node_modules/@google/gemini-cli/dist/ui/components/Composer.js" \
 && grep -q "loadingPhrases === 'off'" "${GEMINI_COMPOSER_JS}" \
 && perl -0pi -e "s/ \\|\\| settings\\.merged\\.ui\\.loadingPhrases === 'off'//g" "${GEMINI_COMPOSER_JS}" \
 && (npm cache clean --force || true) \
 && (yarn cache clean || true)

RUN ARCHIVE="splitrail-v${SPLITRAIL_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
 && ARCHDIR="splitrail-v${SPLITRAIL_VERSION}-x86_64-unknown-linux-gnu" \
 && curl -fsSL "https://github.com/Piebald-AI/splitrail/releases/download/v${SPLITRAIL_VERSION}/${ARCHIVE}" -o "/tmp/${ARCHIVE}" \
 && tar -xvf "/tmp/${ARCHIVE}" -C /tmp \
 && install -m 0755 "/tmp/${ARCHDIR}/splitrail" /usr/local/bin/splitrail \
 && rm -rf "/tmp/${ARCHIVE}" "/tmp/${ARCHDIR}"

RUN install -d -m 0755 /etc/gemini-cli /etc/profile.d
COPY etc/gemini-cli/system-defaults.json /etc/gemini-cli/system-defaults.json
COPY etc/profile.d/gemini-workbench-aliases.sh /etc/profile.d/gemini-workbench-aliases.sh
COPY --from=builder /gemini-telemetry /usr/local/bin/gemini-telemetry

USER ubuntu
ENV HOME=/home/ubuntu

LABEL org.opencontainers.image.title="Google Gemini Workbench" \
      org.opencontainers.image.description="Google Gemini CLI workbench built on the universal base image" \
      org.opencontainers.image.version="${GEMINI_CLI_VERSION_LABEL}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/google-gemini-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_TAG}" \
      com.spigell.workbench.gemini-cli.version="${GEMINI_CLI_VERSION_LABEL}"

ENTRYPOINT ["/bin/bash","-lc"]
CMD ["gemini --help || true"]
