# Use a specific version of alpine for reproducibility
FROM alpine:3.20 AS downloader

# Set environment variables for the server version and architecture
ENV GITHUB_MCP_SERVER_VERSION=v0.26.3
ENV ARCH=x86_64
ENV DIST=Linux

# Download and extract the github-mcp-server binary
RUN apk add --no-cache curl \
    && FILENAME="github-mcp-server_${DIST}_${ARCH}.tar.gz" \
    && URL="https://github.com/github/github-mcp-server/releases/download/${GITHUB_MCP_SERVER_VERSION}/${FILENAME}" \
    && curl -fsSL "${URL}" -o /tmp/github-mcp-server.tar.gz \
    && tar -xzf /tmp/github-mcp-server.tar.gz -C /usr/local/bin \
    && chmod +x /usr/local/bin/github-mcp-server

# Use the proxy image as the base for the final image
FROM ghcr.io/sparfenyuk/mcp-proxy:v0.9.0

# Create a non-root user
RUN addgroup -S app && adduser -S -G app app

# Copy the server binary from the downloader stage
COPY --from=downloader /usr/local/bin/github-mcp-server /usr/local/bin/github-mcp-server

# Switch to the non-root user
USER app

# Set the entrypoint to run the proxy with the server
ENTRYPOINT ["mcp-proxy"]
CMD ["--host=0.0.0.0", "--port=8080", "--allow-origin=*", "--pass-environment", "--", "/usr/local/bin/github-mcp-server", "stdio"]
