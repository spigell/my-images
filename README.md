# my-images

> This repository is maintained for personal use. Contributions are welcome, but no official support is provided.

## Workbench Architecture

All workbench images now build from a shared **Universal Workbench** base (`universal-workbench-docker/`). The base provides:

- Ubuntu 24.04 with the stock `ubuntu` user (no extra creation required).
- Go toolchain with delve and golangci-lint.
- Python via pyenv with Poetry and uv.
- Node.js managed by fnm with Yarn/Corepack enabled.
- The `uv specify-cli` wrapper installs GitHub’s `spec-kit` and is available on the `ubuntu` user PATH for API/CLI specification work.
- Shared terminal utilities (`vim`, `file`, `less`, `tree`, `ripgrep`, etc.).

Downstream workbenches (Codex, Gemini, Pulumi, Talos) only add their unique tooling on top. Version coordination happens through
small JSON manifests collected under `versions/` (for example `versions/universal-workbench.json`, `versions/google-gemini.json`,
`versions/openai-codex.json`). Each file is exactly `{"tag": "<image-tag>"}` so the shared composite action can read tags
consistently, and the publish workflows watch those manifests for changes.

## Available images

| Image directory | Base image | Extends with |
| --- | --- | --- |
| `universal-workbench-docker/` | Ubuntu 24.04 | Go, Python, Node.js runtimes plus shared tooling |
| `openai-codex-docker/` | Universal workbench | Codex CLI/binary and related tooling |
| `google-gemini-docker/` | Universal workbench | Gemini CLI stack and fnm aliases |
| `github-runner-docker/` | Google Gemini workbench | GitHub Actions runner dependencies; built via a dedicated workflow |
| `pulumi-workbench-docker/` | Debug SRE workbench | Pulumi CLI, pulumictl, kubectl, `@pulumi/mcp-server` |
| `pulumi-talos-cluster-workbench-docker/` | Pulumi workbench | Talosctl, K9s, and Talos tooling |
| `debug-sre-workbench-docker/` | Universal workbench | Docker CLI, kubectl, Helm, kube-lineage, Talosctl, K9s, ArgoCD, etcdctl, Poetry, uv |
| `holmes-gpt-docker/` | Debug SRE workbench | HolmesGPT runtime plus kube-lineage, ArgoCD, Helm 4, Azure SQL tooling |
| `anki-desktop-docker/` | Universal workbench | Anki desktop tooling and defaults |
| `zmx-binary/` | - | zmx binary image used by workbench builds |
| `github-mcp-server-docker/` | Universal workbench | GitHub MCP server |

## Browse images (explore.ggcr.dev)

- universal-workbench: https://explore.ggcr.dev/?image=ghcr.io/spigell/universal-workbench:latest
- google-gemini-workbench: https://explore.ggcr.dev/?image=ghcr.io/spigell/google-gemini-workbench:latest
- google-gemini-github-runner: https://explore.ggcr.dev/?image=ghcr.io/spigell/google-gemini-github-runner:latest
- openai-codex-workbench: https://explore.ggcr.dev/?image=ghcr.io/spigell/codex-workbench:latest
- codex-github-runner: https://explore.ggcr.dev/?image=ghcr.io/spigell/codex-github-runner:latest
- pulumi-workbench: https://explore.ggcr.dev/?image=ghcr.io/spigell/pulumi-workbench:latest
- pulumi-talos-cluster-workbench: https://explore.ggcr.dev/?image=ghcr.io/spigell/pulumi-talos-cluster-workbench:latest
- debug-sre-workbench: https://explore.ggcr.dev/?image=ghcr.io/spigell/debug-sre-workbench:latest
- holmes-gpt: https://explore.ggcr.dev/?image=ghcr.io/spigell/holmes-gpt:latest
- anki-desktop-docker: https://explore.ggcr.dev/?image=ghcr.io/spigell/anki-desktop-docker:latest
- zmx-binary: https://explore.ggcr.dev/?image=ghcr.io/spigell/zmx-binary:latest
- github-mcp-server: https://explore.ggcr.dev/?image=ghcr.io/spigell/github-mcp-server:latest

## Git setup helper

Every workbench image includes the `setup-git-workbench` helper under `/usr/local/bin` and preinstalls `vim`. Run the helper
once inside a container to configure your preferred Git identity and editor:

```bash
setup-git-workbench --name "Ada Lovelace" --email ada@example.com
```

Omit any flags to be prompted interactively for missing values. The script defaults to `vim` when no editor is supplied,
matching the editor bundled with each image.

The canonical script source lives at `shared/setup-git-workbench.sh` and is copied into each workbench image during the build.
