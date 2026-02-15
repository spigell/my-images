# Claude Code Container Images

This directory provides a Dockerfile for the Claude Code Workbench.
The image includes sandbox prerequisites for Claude Code:
- `bubblewrap` (`bwrap`)
- `socat`
- `@anthropic-ai/sandbox-runtime` (`srt`)

## Building the Claude Code image

```bash
docker build \
  -f Dockerfile \
  --build-arg CLAUDE_CODE_VERSION=2.1.42 \
  --build-arg SANDBOX_RUNTIME_VERSION=0.0.37 \
  --build-arg BUBBLEWRAP_VERSION=0.9.0-1ubuntu0.1 \
  --build-arg SOCAT_VERSION=1.8.0.0-4build3 \
  -t ghcr.io/example/claude-code:v2.1.42 \
  .
```

## Verify sandbox dependencies

```bash
bwrap --version
socat -V
srt --help
```

## Docker Compose

The included `docker-compose.yaml` builds the primary Claude Code image.
