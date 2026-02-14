# Claude Code Container Images

This directory provides a Dockerfile for the Claude Code Workbench.

## Building the Claude Code image

```bash
docker build \
  -f Dockerfile \
  --build-arg CLAUDE_CODE_VERSION=2.1.42 \
  -t ghcr.io/example/claude-code:v2.1.42 \
  .
```

## Docker Compose

The included `docker-compose.yaml` builds the primary Claude Code image.
