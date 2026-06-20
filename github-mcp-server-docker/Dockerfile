ARG ALPINE_IMAGE_TAG=3.24 # renovate: datasource=docker depName=alpine
ARG MCP_PROXY_IMAGE_TAG=v0.12.0 # renovate: datasource=docker depName=ghcr.io/sparfenyuk/mcp-proxy
ARG GITHUB_MCP_SERVER_VERSION=v1.4.0 # renovate: datasource=github-releases depName=github/github-mcp-server

FROM alpine:${ALPINE_IMAGE_TAG} AS downloader

# Set environment variables for the server version and architecture
ENV ARCH=x86_64
ENV DIST=Linux
ARG GITHUB_MCP_SERVER_VERSION

# Download and extract the github-mcp-server binary
RUN apk add --no-cache curl \
    && FILENAME="github-mcp-server_${DIST}_${ARCH}.tar.gz" \
    && URL="https://github.com/github/github-mcp-server/releases/download/${GITHUB_MCP_SERVER_VERSION}/${FILENAME}" \
    && curl -fsSL "${URL}" -o /tmp/github-mcp-server.tar.gz \
    && tar -xzf /tmp/github-mcp-server.tar.gz -C /usr/local/bin \
    && chmod +x /usr/local/bin/github-mcp-server

FROM ghcr.io/sparfenyuk/mcp-proxy:${MCP_PROXY_IMAGE_TAG}

# Create a non-root user
RUN addgroup -S app && adduser -S -G app app

# Copy the server binary from the downloader stage
COPY --from=downloader /usr/local/bin/github-mcp-server /usr/local/bin/github-mcp-server

# Switch to the non-root user
USER app

# Set the entrypoint to run the proxy with the server
ENTRYPOINT ["mcp-proxy"]
CMD ["--host=0.0.0.0", "--port=8080", "--allow-origin=*", "--pass-environment", "--", "/usr/local/bin/github-mcp-server", "stdio"]
