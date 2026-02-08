# syntax=docker/dockerfile:1.18

# Build the Ansible MCP server from source (vscode-ansible) and expose it over HTTP via mcp-proxy,
# reusing the universal workbench base so pyenv/python tooling matches the rest of the images.
ARG UNIVERSAL_WORKBENCH_TAG=sha-dev

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG} AS builder
ARG VSCODE_ANSIBLE_REF=v26.1.1
WORKDIR /src

# Ensure build tooling is available; universal base already has pyenv/python and yarn
USER root
RUN apt-get update && apt-get install -y --no-install-recommends git build-essential && rm -rf /var/lib/apt/lists/*
RUN corepack enable

# Fetch the upstream repo at the requested ref
RUN git clone --depth=1 --branch "${VSCODE_ANSIBLE_REF}" https://github.com/ansible/vscode-ansible .

# Install dependencies and build only the MCP server workspace
RUN yarn install --immutable
RUN yarn workspace @ansible/ansible-mcp-server run compile

# Create a production-focused install to keep the runtime slim
RUN yarn workspaces focus @ansible/ansible-mcp-server --production

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_TAG}
WORKDIR /opt/ansible-mcp-server

# Copy runtime artifacts explicitly into /opt/ansible-mcp-server
COPY --from=builder /src/node_modules /opt/ansible-mcp-server/node_modules
COPY --from=builder /src/packages/ansible-mcp-server/package.json /opt/ansible-mcp-server/package.json
COPY --from=builder /src/packages/ansible-mcp-server/out /opt/ansible-mcp-server/out
COPY --from=builder /src/packages/ansible-mcp-server/src/resources /opt/ansible-mcp-server/src/resources

# Expose the MCP server through the proxy on HTTP (default port 8080).
ENTRYPOINT ["mcp-proxy"]
CMD ["--host=0.0.0.0", "--port=8080", "--allow-origin=*", "--pass-environment", "--", "node", "/opt/ansible-mcp-server/out/server/src/cli.js", "--stdio"]
