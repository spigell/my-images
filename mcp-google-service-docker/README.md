# Google MCP Service image

This image builds the upstream [`zchee/mcp-google-service`](https://github.com/zchee/mcp-google-service)
repository unchanged at the Renovate-managed commit and exposes its stdio MCP
server through `mcp-proxy` on port 8080. Runtime deployment configuration owns
the service's `--project`, `--only`, `--expose`, and `--strict-startup` flags.

The image does not patch or vendor the upstream source.
