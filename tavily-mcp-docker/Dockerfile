# syntax=docker/dockerfile:1.24

ARG UNIVERSAL_WORKBENCH_IMAGE_TAG=sha-dev
ARG TAVILY_MCP_VERSION=0.2.20 # renovate: datasource=npm depName=tavily-mcp

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_IMAGE_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG UNIVERSAL_WORKBENCH_IMAGE_TAG
ARG TAVILY_MCP_VERSION

# Install tavily-mcp globally using npm
RUN npm install -g "tavily-mcp@${TAVILY_MCP_VERSION}"

# Expose HTTP port for mcp-proxy
EXPOSE 8080

LABEL org.opencontainers.image.title="Tavily MCP Server" \
      org.opencontainers.image.description="Tavily MCP server image built on the universal workbench base image" \
      org.opencontainers.image.version="${TAVILY_MCP_VERSION}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/tavily-mcp-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_IMAGE_TAG}" \
      com.spigell.workbench.tavily-mcp.version="${TAVILY_MCP_VERSION}"

# Switch back to the default workbench user
USER ubuntu
ENV HOME=/home/ubuntu

# Expose the MCP server through the proxy on HTTP (default port 8080)
ENTRYPOINT ["mcp-proxy"]
CMD ["--host=0.0.0.0", "--port=8080", "--allow-origin=*", "--pass-environment", "--", "tavily-mcp"]
