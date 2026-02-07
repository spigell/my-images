# syntax=docker/dockerfile:1.18

# Build the Ansible MCP server from source (vscode-ansible) and expose it over HTTP via mcp-proxy.

ARG VSCODE_ANSIBLE_REF=main

FROM node:22-alpine AS builder
WORKDIR /src

# Tooling needed for node-gyp and git clone
RUN apk add --no-cache git python3 make g++ bash
RUN corepack enable

# Fetch the upstream repo at the requested ref
RUN git clone --depth=1 --branch "${VSCODE_ANSIBLE_REF}" https://github.com/ansible/vscode-ansible .

# Install dependencies and build only the MCP server workspace
RUN yarn install --immutable
RUN yarn workspace @ansible/ansible-mcp-server run compile

# Create a production-focused install to keep the runtime slim
RUN yarn workspaces focus @ansible/ansible-mcp-server --production

FROM ghcr.io/sparfenyuk/mcp-proxy:v0.9.0
WORKDIR /usr/local/ansible-mcp-server

USER root
RUN apk add --no-cache nodejs npm

# Copy runtime artifacts
COPY --from=builder /src/node_modules ./node_modules
COPY --from=builder /src/packages/ansible-mcp-server/package.json ./package.json
COPY --from=builder /src/packages/ansible-mcp-server/out ./out
COPY --from=builder /src/packages/ansible-mcp-server/src/resources ./src/resources

# Non-root execution
RUN addgroup -S app && adduser -S -G app app
USER app

# Expose the MCP server through the proxy on HTTP (default port 8080).
ENTRYPOINT ["mcp-proxy"]
CMD ["--host=0.0.0.0", "--port=8080", "--allow-origin=*", "--pass-environment", "--", "node", "out/server/src/cli.js", "--stdio"]
