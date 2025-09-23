# Codex Container Images

This directory provides two Dockerfiles:

- `codex-binary/Dockerfile` builds a minimal image that only contains the Codex binary. A compatibility symlink named `Dockerfile.codex-binary` is kept at the repository root for existing tooling.
- `Dockerfile` consumes the binary image and installs additional tooling for interactive Codex work.

## Building the Codex binary image

```bash
docker build \
  -f codex-binary/Dockerfile \
  --build-arg CODEX_VERSION=rust-v0.39.0 \
  -t ghcr.io/example/codex-binary:rust-v0.39.0 \
  .
```

Push the resulting image to your registry of choice so other Dockerfiles can reference it as a build stage.

## Building the main Codex image

Build the primary image by referencing the binary image.  The `CODEX_BINARY_IMAGE` argument lets you point at any registry/repository, while `CODEX_BINARY_REF` accepts either a tag or the combined `tag@sha256:digest` syntax.

```bash
docker build \
  -f Dockerfile \
  --build-arg CODEX_VERSION=rust-v0.39.0 \
  --build-arg CODEX_BINARY_IMAGE=ghcr.io/example/codex-binary \
  --build-arg CODEX_BINARY_REF=rust-v0.39.0@sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef \
  -t ghcr.io/example/codex:rust-v0.39.0 \
  .
```

The combined tag and digest reference ensures your build uses the exact binary you published.

## Docker Compose

The included `docker-compose.yaml` builds the primary Codex image.  Ensure the `CODEX_BINARY_IMAGE` and `CODEX_BINARY_REF` build arguments point to the binary image you built or published.
