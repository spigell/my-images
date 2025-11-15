# my-images

## Workbench Architecture

All workbench images now build from a shared **Universal Workbench** base (`universal-workbench-docker/`). The base provides:

- Ubuntu 24.04 with the stock `ubuntu` user (no extra creation required).
- Go toolchain with delve and golangci-lint.
- Python via pyenv with Poetry, uv, and common lint/test tooling.
- Node.js managed by fnm with Yarn/Corepack enabled.
- Shared terminal utilities (`vim`, `file`, `less`, `tree`, `ripgrep`, etc.).

Downstream workbenches (Codex, Gemini, Pulumi, Talos) only add their unique tooling on top. Version coordination happens through
small JSON manifests collected under `versions/` (for example `versions/universal-workbench.json`, `versions/google-gemini.json`,
`versions/openai-codex.json`). Each file is exactly `{"tag": "<image-tag>"}` so the shared composite action can read tags
consistently, and the publish workflows watch those manifests for changes.

## Available images

- **universal-workbench** (`universal-workbench-docker/`): Common base layer shared across all workbenches.
- **openai-codex-workbench** (`openai-codex-docker/`): Codex tooling plus the Codex runtime binary.
- **google-gemini-workbench** (`google-gemini-docker/`): Gemini CLI environment on top of the universal base.
- **google-gemini-github-runner** (`github-runner-docker/`): GitHub Actions runner image layered on the Gemini workbench; published through its own dedicated workflow so it can track runner-specific updates independently.
- **pulumi-workbench** (`pulumi-workbench-docker/`): Pulumi CLI stack with pulumictl, kubectl, and `@pulumi/mcp-server`.
- **pulumi-talos-cluster-workbench** (`pulumi-talos-cluster-workbench-docker/`): Pulumi workbench extended with Talosctl and K9s.
- **anki-desktop-workbench** (`anki-desktop-docker/`): Workbench for the Anki desktop tooling.

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

If you update the base image, bump the `tag` in `versions/universal-workbench.json` so dependent
workflows pick up the new tag automatically.
