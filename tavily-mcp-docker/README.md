# Tavily MCP Server Image

A Dockerized Tavily MCP server built on top of the `universal-workbench` image.

Since `tavily-mcp` natively only supports `stdio` transport, this image wraps it with `mcp-proxy` to expose the server over HTTP.

## Running

```bash
docker run -d \
  -p 8080:8080 \
  -e TAVILY_API_KEY="your-api-key" \
  ghcr.io/spigell/tavily-mcp:latest
```
