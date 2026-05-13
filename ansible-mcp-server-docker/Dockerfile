# syntax=docker/dockerfile:1.23

# Build the Ansible MCP server from source (vscode-ansible) and expose it over HTTP via mcp-proxy,
# reusing the universal workbench base so pyenv/python tooling matches the rest of the images.
ARG UNIVERSAL_WORKBENCH_IMAGE_TAG=sha-dev

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_IMAGE_TAG} AS builder
ARG VSCODE_ANSIBLE_GIT_REF=v26.5.0 # renovate: datasource=github-tags depName=ansible/vscode-ansible
WORKDIR /src

# universal base already includes Python, yarn/corepack, and build tooling

# Fetch the upstream repo at the requested ref
RUN git clone --depth=1 --branch "${VSCODE_ANSIBLE_GIT_REF}" https://github.com/ansible/vscode-ansible .

# Install dependencies and build only the MCP server workspace
RUN corepack prepare pnpm@latest --activate
RUN pnpm install --frozen-lockfile
RUN pnpm --filter @ansible/ansible-mcp-server run prepack

# Create a production-focused install to keep the runtime slim
RUN CI=true pnpm install --prod --frozen-lockfile

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_IMAGE_TAG}
WORKDIR /opt/ansible-mcp-server

# Copy runtime artifacts explicitly into /opt/ansible-mcp-server
COPY --from=builder /src/node_modules /opt/ansible-mcp-server/node_modules
COPY --from=builder /src/packages/ansible-mcp-server/package.json /opt/ansible-mcp-server/package.json
COPY --from=builder /src/packages/ansible-mcp-server/dist /opt/ansible-mcp-server/dist
COPY --from=builder /src/packages/ansible-mcp-server/lib /opt/ansible-mcp-server/lib
COPY --from=builder /src/packages/ansible-mcp-server/src/resources /opt/ansible-mcp-server/src/resources

# Expose the MCP server through the proxy on HTTP (default port 8080).
ENTRYPOINT ["mcp-proxy"]
CMD ["--host=0.0.0.0", "--port=8080", "--allow-origin=*", "--pass-environment", "--", "node", "/opt/ansible-mcp-server/dist/cli.cjs", "--stdio"]
