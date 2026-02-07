# syntax=docker/dockerfile:1.18

# Build the Ansible MCP server from source (vscode-ansible) and expose it over HTTP via mcp-proxy,
# reusing the universal workbench base so pyenv/python tooling matches the rest of the images.

FROM node:22-alpine AS builder
ARG VSCODE_ANSIBLE_REF=main
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

ARG UNIVERSAL_WORKBENCH_TAG=latest
FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
ARG UNIVERSAL_WORKBENCH_TAG
WORKDIR /opt/ansible-mcp-server

# Copy runtime artifacts
COPY --from=builder /src/node_modules ./node_modules
COPY --from=builder /src/packages/ansible-mcp-server/package.json ./package.json
COPY --from=builder /src/packages/ansible-mcp-server/out ./out
COPY --from=builder /src/packages/ansible-mcp-server/src/resources ./src/resources

# Non-root execution
USER ubuntu

# Expose the MCP server through the proxy on HTTP (default port 8080).
ENTRYPOINT ["mcp-proxy"]
CMD ["--host=0.0.0.0", "--port=8080", "--allow-origin=*", "--pass-environment", "--", "node", "out/server/src/cli.js", "--stdio"]
