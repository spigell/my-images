# syntax=docker/dockerfile:1.18

# Build a thin image that serves the Ansible MCP server over HTTP via mcp-proxy.
FROM ghcr.io/sparfenyuk/mcp-proxy:v0.9.0 AS base

USER root

# Install Node.js runtime and the published Ansible MCP server package.
RUN apk add --no-cache nodejs npm \
    && npm install -g @ansible/ansible-mcp-server@0.1.0 \
    && npm cache clean --force

# Create non-root user to run the server.
RUN addgroup -S app && adduser -S -G app app
USER app

# Expose the MCP server through the proxy on HTTP (default port 8080).
ENTRYPOINT ["mcp-proxy"]
CMD ["--host=0.0.0.0", "--port=8080", "--allow-origin=*", "--pass-environment", "--", "ansible-mcp-server", "--stdio"]
