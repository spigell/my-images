# syntax=docker/dockerfile:1.27

ARG RUST_IMAGE_TAG=1.98-bookworm # renovate: datasource=docker depName=rust
ARG UNIVERSAL_WORKBENCH_IMAGE_TAG=sha-dev
ARG MCP_GOOGLE_SERVICE_GIT_REF=main
ARG MCP_GOOGLE_SERVICE_GIT_SHA=c822a220e13b927ae84bc37241f5229eba11341d # renovate: datasource=github-digest depName=zchee/mcp-google-service packageName=zchee/mcp-google-service

FROM rust:${RUST_IMAGE_TAG} AS builder
ARG MCP_GOOGLE_SERVICE_GIT_SHA
WORKDIR /src
RUN git clone --filter=blob:none --no-checkout https://github.com/zchee/mcp-google-service.git . \
 && git fetch --depth 1 origin "${MCP_GOOGLE_SERVICE_GIT_SHA}" \
 && git checkout --detach "${MCP_GOOGLE_SERVICE_GIT_SHA}" \
 && cargo build --locked --release

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_IMAGE_TAG}
ARG MCP_GOOGLE_SERVICE_GIT_SHA
COPY --from=builder /src/target/release/mcp-google-service /usr/local/bin/mcp-google-service
USER ubuntu
ENV HOME=/home/ubuntu \
    MCP_PROXY_HOST=0.0.0.0 \
    MCP_PROXY_PORT=8080 \
    MCP_PROXY_ALLOW_ORIGIN=*
EXPOSE 8080
LABEL org.opencontainers.image.title="Google MCP Service" \
      org.opencontainers.image.description="Unmodified zchee/mcp-google-service exposed over HTTP" \
      org.opencontainers.image.source="https://github.com/zchee/mcp-google-service" \
      org.opencontainers.image.revision="${MCP_GOOGLE_SERVICE_GIT_SHA}"
ENTRYPOINT ["mcp-proxy"]
CMD ["--host=0.0.0.0", "--port=8080", "--allow-origin=*", "--", "mcp-google-service"]
