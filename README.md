# my-images

## Workbench Architecture

All workbench images now build from a shared **Universal Workbench** base (`universal-workbench-docker/`). The base provides:

- Ubuntu 24.04 with the stock `ubuntu` user (no extra creation required).
- Go 1.25.1 plus delve and golangci-lint.
- Python 3.12 via pyenv with Poetry, uv, and common lint/test tooling.
- Node.js 24 managed by fnm with Yarn/Corepack enabled.
- Shared terminal utilities (`vim`, `file`, `less`, `tree`, `ripgrep`, etc.).

Downstream workbenches (Codex, Gemini, Pulumi, Talos) only add their unique tooling on top. Version coordination happens through
`universal-workbench-docker/base-version.json`, which stores the tag for the latest published universal image. Any workflow
that consumes the base watches that JSON file for changes.

## Available images

- **universal-workbench**: Common base image for every workbench.
- **openai-codex-workbench**: Extends the universal base with Codex tooling and the Codex binary.
- **google-gemini-workbench**: Extends the base with the Gemini CLI stack.
- **pulumi-workbench**: Adds Pulumi CLI, pulumictl, kubectl, and `@pulumi/mcp-server` on top of the base.
- **pulumi-talos-cluster-workbench**: Builds on the Pulumi workbench with additional Talos/K9s tooling.

## Git setup helper

Every workbench image includes the `setup-git-workbench` helper under `/usr/local/bin` and preinstalls `vim`. Run the helper
once inside a container to configure your preferred Git identity and editor:

```bash
setup-git-workbench --name "Ada Lovelace" --email ada@example.com
```

Omit any flags to be prompted interactively for missing values. The script defaults to `vim` when no editor is supplied,
matching the editor bundled with each image.

The canonical script source lives at `shared/setup-git-workbench.sh` and is copied into each workbench image during the build.

### Building images locally

When building a workbench image with `docker buildx`, pass the repository's `shared/` directory as an additional build context
so the Dockerfile can copy the shared helper script:

```bash
docker buildx build \
  --build-context shared=./shared \
  -f google-gemini-docker/Dockerfile \
  google-gemini-docker
```

Use the same `--build-context shared=./shared` flag for the other workbench Dockerfiles.

When building the universal base itself:

```bash
docker buildx build \
  --build-context shared=./shared \
  -f universal-workbench-docker/Dockerfile \
  universal-workbench-docker
```

If you update the base image, bump the `universal_workbench_tag` in `universal-workbench-docker/base-version.json` (typically to
the new short commit SHA, e.g., `abcdef0`) so dependent workflows pick up the new tag automatically.
