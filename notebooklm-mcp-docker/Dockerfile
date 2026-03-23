# syntax=docker/dockerfile:1.18

ARG UNIVERSAL_WORKBENCH_TAG=sha-dev
ARG NOTEBOOKLM_MCP_CLI_VERSION=0.5.4

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG UNIVERSAL_WORKBENCH_TAG
ARG NOTEBOOKLM_MCP_CLI_VERSION

WORKDIR /opt/notebooklm-mcp

RUN XDG_BIN_HOME=/usr/local/bin \
    UV_PYTHON_INSTALL_DIR=/usr/local/share/uv-python \
    XDG_DATA_HOME=/usr/local/share/uv-data \
    uv tool install "notebooklm-mcp-cli==${NOTEBOOKLM_MCP_CLI_VERSION}"

EXPOSE 8000

LABEL org.opencontainers.image.title="NotebookLM MCP Server" \
      org.opencontainers.image.description="NotebookLM MCP server image built on the universal workbench base image" \
      org.opencontainers.image.version="${NOTEBOOKLM_MCP_CLI_VERSION}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/notebooklm-mcp-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_TAG}" \
      com.spigell.workbench.notebooklm-mcp-cli.version="${NOTEBOOKLM_MCP_CLI_VERSION}"

ENTRYPOINT ["notebooklm-mcp"]
CMD ["--transport", "http", "--host", "0.0.0.0", "--port", "8000"]
