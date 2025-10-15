# my-images

## Available images

- **gemini-cli**: Minimal devcontainer-based image with the Google Gemini CLI preinstalled.
- **gemini-cli-workbench**: Extends `gemini-cli` with common terminal tooling for interactive workflows.

## Git setup helper

Every workbench image includes the `setup-git-workbench` helper under `/usr/local/bin`. Run it once inside a container to
configure your preferred Git identity and editor:

```bash
setup-git-workbench --name "Ada Lovelace" --email ada@example.com --editor "code --wait"
```

Omit any flags to be prompted interactively for missing values.

The canonical script source lives at `shared/setup-git-workbench.sh` and is copied into each workbench image during the build.

### Building images locally

When building a workbench image with `docker buildx`, pass the repository's `shared/` directory as an additional build context
so the Dockerfile can copy the shared helper script:

```bash
docker buildx build \
  --build-context setup-git-helper=./shared \
  -f google-gemini-docker/Dockerfile \
  google-gemini-docker
```

Use the same `--build-context setup-git-helper=./shared` flag for the other workbench Dockerfiles.
