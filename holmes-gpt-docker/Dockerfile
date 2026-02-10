# syntax=docker/dockerfile:1.18

ARG DEBUG_SRE_TAG=sha-dev
ARG HOLMES_SOURCE_IMAGE=robustadev/holmes:0.19.1
ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG HOLMES_REF=0.19.1
ARG ARGOCD_VERSION=3.2.1
ARG ARGOCD_ARM_URL=https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-arm64
ARG ARGOCD_AMD_URL=https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64
ARG HELM_VERSION=3.19.2

FROM ${HOLMES_SOURCE_IMAGE} AS holmes-src

FROM debian:bookworm-slim AS fetch-manifest
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
ARG HOLMES_REF
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL -o /tmp/pyproject.toml "https://raw.githubusercontent.com/HolmesGPT/holmesgpt/${HOLMES_REF}/pyproject.toml"
RUN curl -fsSL -o /tmp/poetry.lock "https://raw.githubusercontent.com/HolmesGPT/holmesgpt/${HOLMES_REF}/poetry.lock"

FROM debian:bookworm-slim AS fetch-tools
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
ARG TARGETOS
ARG TARGETARCH
ARG ARGOCD_VERSION
ARG ARGOCD_ARM_URL
ARG ARGOCD_AMD_URL
ARG HELM_VERSION

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates tar xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN if [ "${TARGETARCH}" = "arm64" ]; then \
      curl -fsSL -o /tmp/argocd "${ARGOCD_ARM_URL}"; \
    elif [ "${TARGETARCH}" = "amd64" ]; then \
      curl -fsSL -o /tmp/argocd "${ARGOCD_AMD_URL}"; \
    else \
      echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1; \
    fi \
    && chmod +x /tmp/argocd

RUN workdir="$(mktemp -d)" \
    && helm_arch="${TARGETARCH}" \
    && if [ "${TARGETARCH}" = "amd64" ]; then helm_arch="amd64"; fi \
    && if [ "${TARGETARCH}" = "arm64" ]; then helm_arch="arm64"; fi \
    && curl -fsSL -o "${workdir}/helm.tar.gz" \
        "https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${helm_arch}.tar.gz" \
    && tar -xzf "${workdir}/helm.tar.gz" -C "${workdir}" \
    && mv "${workdir}/${TARGETOS}-${helm_arch}/helm" /tmp/helm \
    && chmod +x /tmp/helm \
    && rm -rf "${workdir}"

FROM ghcr.io/spigell/debug-sre-workbench:${DEBUG_SRE_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG TARGETOS
ARG TARGETARCH
ARG ARGOCD_VERSION
ARG ARGOCD_ARM_URL
ARG ARGOCD_AMD_URL
ARG HELM_VERSION
ARG HOLMES_SOURCE_IMAGE

ENV APP_HOME=/app
ENV VIRTUAL_ENV=/opt/holmes-venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=".:${APP_HOME}/holmes"

# Microsoft ODBC for Azure SQL (required by azure/sql toolset)
RUN . /etc/os-release \
    && curl -fsSL -o /tmp/packages-microsoft-prod.deb "https://packages.microsoft.com/config/ubuntu/${VERSION_ID}/packages-microsoft-prod.deb" \
    && dpkg -i /tmp/packages-microsoft-prod.deb \
    && rm /tmp/packages-microsoft-prod.deb \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && apt-get install -y --no-install-recommends libgssapi-krb5-2 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=fetch-tools /tmp/argocd /usr/local/bin/argocd
COPY --from=fetch-tools /tmp/helm /usr/local/bin/helm

RUN argocd version --client \
    && helm version

# Python environment setup
RUN python3 -m venv "${VIRTUAL_ENV}" \
    && "${VIRTUAL_ENV}/bin/pip" install --upgrade pip

COPY --from=fetch-manifest /tmp/pyproject.toml /tmp/holmes-src/pyproject.toml
COPY --from=fetch-manifest /tmp/poetry.lock /tmp/holmes-src/poetry.lock

RUN cd /tmp/holmes-src \
    && poetry export -f requirements.txt --output requirements.txt --without-hashes \
    && "${VIRTUAL_ENV}/bin/pip" install -r requirements.txt \
    && rm -rf /tmp/holmes-src

WORKDIR ${APP_HOME}

# Copy application code (Python only) from upstream image
COPY --from=holmes-src /app/holmes ${APP_HOME}/holmes
COPY --from=holmes-src /app/server.py ${APP_HOME}/server.py
COPY --from=holmes-src /app/holmes_cli.py ${APP_HOME}/holmes_cli.py
COPY --from=holmes-src /app/experimental/ag-ui/server-agui.py ${APP_HOME}/experimental/ag-ui/server-agui.py

RUN install -d -m 0755 ${APP_HOME}/experimental/ag-ui \
    && chown -R ubuntu:ubuntu ${APP_HOME}

# Align git CVE fix
RUN git config --global core.symlinks false \
    && rm -rf /usr/local/lib/python3.11/site-packages/setuptools-65.5.1.dist-info || true \
    && rm -rf /usr/local/lib/python3.11/ensurepip/_bundled/setuptools-65.5.0-py3-none-any.whl || true

USER ubuntu
ENV HOME=/home/ubuntu

LABEL org.opencontainers.image.title="Holmes GPT Workbench" \
      org.opencontainers.image.description="HolmesGPT runtime built on the debug SRE workbench with kubectl, Helm, ArgoCD, and Azure SQL tooling" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/holmes-gpt-docker" \
      com.spigell.workbench.base-image="debug-sre-workbench" \
      com.spigell.workbench.base-image-tag="${DEBUG_SRE_TAG}" \
      com.spigell.holmes.workbench.source-image="${HOLMES_SOURCE_IMAGE}" \
      com.spigell.holmes.workbench.argocd.version="${ARGOCD_VERSION}" \
      com.spigell.workbench.helm.version="${HELM_VERSION}"

ENTRYPOINT ["python","holmes_cli.py"]
