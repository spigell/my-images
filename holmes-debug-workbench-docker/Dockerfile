# syntax=docker/dockerfile:1.18

ARG DEBUG_SRE_TAG=sha-dev
ARG HOLMES_SOURCE_IMAGE=robustadev/holmes:latest
ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG KUBE_LINEAGE_VERSION=2.2.4
ARG KUBE_LINEAGE_ARM_URL=https://github.com/robusta-dev/kube-lineage/releases/download/v${KUBE_LINEAGE_VERSION}/kube-lineage-macos-latest-v${KUBE_LINEAGE_VERSION}
ARG KUBE_LINEAGE_AMD_URL=https://github.com/robusta-dev/kube-lineage/releases/download/v${KUBE_LINEAGE_VERSION}/kube-lineage-ubuntu-latest-v${KUBE_LINEAGE_VERSION}
ARG ARGOCD_VERSION=3.2.0
ARG ARGOCD_ARM_URL=https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-arm64
ARG ARGOCD_AMD_URL=https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64
ARG HELM_VERSION=4.0.0

FROM ${HOLMES_SOURCE_IMAGE} AS holmes-src

FROM ghcr.io/spigell/debug-sre-workbench:${DEBUG_SRE_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG TARGETOS
ARG TARGETARCH
ARG KUBE_LINEAGE_VERSION
ARG KUBE_LINEAGE_ARM_URL
ARG KUBE_LINEAGE_AMD_URL
ARG ARGOCD_VERSION
ARG ARGOCD_ARM_URL
ARG ARGOCD_AMD_URL
ARG HELM_VERSION
ARG HOLMES_SOURCE_IMAGE

ENV APP_HOME=/app
ENV VIRTUAL_ENV=/opt/holmes-venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH="${PYTHONPATH:-}:.:${APP_HOME}/holmes"

# Runtime dependencies and CVE patches
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        jq \
        git \
        apt-transport-https \
        gnupg2 \
        software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Microsoft ODBC for Azure SQL (required by azure/sql toolset)
RUN . /etc/os-release \
    && curl -fsSL -o /tmp/packages-microsoft-prod.deb "https://packages.microsoft.com/config/ubuntu/${VERSION_ID}/packages-microsoft-prod.deb" \
    && dpkg -i /tmp/packages-microsoft-prod.deb \
    && rm /tmp/packages-microsoft-prod.deb \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && apt-get install -y --no-install-recommends libgssapi-krb5-2 \
    && rm -rf /var/lib/apt/lists/*

# Install kube-lineage
RUN install -d -m 0755 /usr/local/bin \
    && if [ "${TARGETARCH}" = "arm64" ]; then \
         curl -fsSL -o /usr/local/bin/kube-lineage "${KUBE_LINEAGE_ARM_URL}"; \
       elif [ "${TARGETARCH}" = "amd64" ]; then \
         curl -fsSL -o /usr/local/bin/kube-lineage "${KUBE_LINEAGE_AMD_URL}"; \
       else \
         echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1; \
       fi \
    && chmod +x /usr/local/bin/kube-lineage \
    && kube-lineage --version

# Install ArgoCD CLI
RUN if [ "${TARGETARCH}" = "arm64" ]; then \
      curl -fsSL -o /usr/local/bin/argocd "${ARGOCD_ARM_URL}"; \
    elif [ "${TARGETARCH}" = "amd64" ]; then \
      curl -fsSL -o /usr/local/bin/argocd "${ARGOCD_AMD_URL}"; \
    else \
      echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1; \
    fi \
    && chmod +x /usr/local/bin/argocd \
    && argocd version --client

# Install Helm (overwrite base version to ensure Helm 4)
RUN workdir="$(mktemp -d)" \
    && helm_arch="${TARGETARCH}" \
    && if [ "${TARGETARCH}" = "amd64" ]; then helm_arch="amd64"; fi \
    && if [ "${TARGETARCH}" = "arm64" ]; then helm_arch="arm64"; fi \
    && curl -fsSL -o "${workdir}/helm.tar.gz" \
        "https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${helm_arch}.tar.gz" \
    && tar -xzf "${workdir}/helm.tar.gz" -C "${workdir}" \
    && mv "${workdir}/${TARGETOS}-${helm_arch}/helm" /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf "${workdir}" \
    && helm version

# Python environment setup
RUN python3 -m venv "${VIRTUAL_ENV}" \
    && "${VIRTUAL_ENV}/bin/pip" install --upgrade pip

COPY --from=holmes-src /app/pyproject.toml /tmp/holmes-src/pyproject.toml
COPY --from=holmes-src /app/poetry.lock /tmp/holmes-src/poetry.lock

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

LABEL org.opencontainers.image.title="Holmes Debug SRE Workbench" \
      org.opencontainers.image.description="HolmesGPT runtime built on the debug SRE workbench with kubectl, Helm, ArgoCD, kube-lineage, and Azure SQL tooling" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/holmes-debug-workbench-docker" \
      com.spigell.workbench.base-image="debug-sre-workbench" \
      com.spigell.workbench.base-image-tag="${DEBUG_SRE_TAG}" \
      com.spigell.holmes.workbench.source-image="${HOLMES_SOURCE_IMAGE}" \
      com.spigell.holmes.workbench.kube-lineage.version="${KUBE_LINEAGE_VERSION}" \
      com.spigell.holmes.workbench.argocd.version="${ARGOCD_VERSION}" \
      com.spigell.workbench.helm.version="${HELM_VERSION}"

ENTRYPOINT ["python","holmes_cli.py"]
