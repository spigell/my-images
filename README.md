# my-images

> This repository is maintained for personal use. Contributions are welcome, but no official support is provided.

## Available images

| Image directory | Base image | Extends with | Browse |
| --- | --- | --- | --- |
| `universal-workbench-docker/` | Ubuntu 24.04 | Go, Python, Node.js runtimes plus shared tooling | [explore.ggcr.dev](https://explore.ggcr.dev/?repo=ghcr.io/spigell/universal-workbench) |
| `openai-codex-docker/codex-binary/` | Scratch | Slim Codex binary artifact image | [explore.ggcr.dev](https://explore.ggcr.dev/?repo=ghcr.io/spigell/codex-binary) |
| `openai-codex-docker/` | Universal workbench | Codex CLI/binary and related tooling | [explore.ggcr.dev](https://explore.ggcr.dev/?repo=ghcr.io/spigell/codex-workbench) |
| `google-gemini-docker/` | Universal workbench | Gemini CLI stack and fnm aliases | [explore.ggcr.dev](https://explore.ggcr.dev/?repo=ghcr.io/spigell/google-gemini-workbench) |
| `github-runner-docker/` | Google Gemini workbench | GitHub Actions runner dependencies; built via a dedicated workflow | [explore.ggcr.dev](https://explore.ggcr.dev/?repo=ghcr.io/spigell/google-gemini-github-runner) |
| `github-runner-docker/` | Codex workbench | GitHub Actions runner dependencies for Codex | [explore.ggcr.dev](https://explore.ggcr.dev/?repo=ghcr.io/spigell/codex-github-runner) |
| `pulumi-workbench-docker/` | Debug SRE workbench | Pulumi CLI, pulumictl, kubectl, `@pulumi/mcp-server` | [explore.ggcr.dev](https://explore.ggcr.dev/?repo=ghcr.io/spigell/pulumi-workbench) |
| `pulumi-talos-cluster-workbench-docker/` | Pulumi workbench | Talosctl, K9s, and Talos tooling | [explore.ggcr.dev](https://explore.ggcr.dev/?repo=ghcr.io/spigell/pulumi-talos-cluster-workbench) |
| `debug-sre-workbench-docker/` | Universal workbench | Docker CLI, kubectl, Helm, kube-lineage, Talosctl, K9s, ArgoCD, etcdctl, Poetry, uv | [explore.ggcr.dev](https://explore.ggcr.dev/?repo=ghcr.io/spigell/debug-sre-workbench) |
| `holmes-gpt-docker/` | Debug SRE workbench | HolmesGPT runtime plus ArgoCD, Helm 4, Azure SQL tooling | [explore.ggcr.dev](https://explore.ggcr.dev/?repo=ghcr.io/spigell/holmes-gpt) |
| `anki-desktop-docker/` | Universal workbench | Anki desktop tooling and defaults | [explore.ggcr.dev](https://explore.ggcr.dev/?repo=ghcr.io/spigell/anki-desktop-docker) |
| `zmx-binary/` | - | zmx binary image used by workbench builds | [explore.ggcr.dev](https://explore.ggcr.dev/?repo=ghcr.io/spigell/zmx-binary) |
| `github-mcp-server-docker/` | Universal workbench | GitHub MCP server | [explore.ggcr.dev](https://explore.ggcr.dev/?repo=ghcr.io/spigell/github-mcp-server) |
| `ansible-mcp-server-docker/` | MCP proxy base | Ansible MCP server exposed over HTTP | [explore.ggcr.dev](https://explore.ggcr.dev/?repo=ghcr.io/spigell/ansible-mcp-server) |

## Git setup helper

Every workbench image includes the `setup-git-workbench` helper under `/usr/local/bin` and preinstalls `vim`. Run the helper
once inside a container to configure your preferred Git identity and editor:

```bash
setup-git-workbench --name "Ada Lovelace" --email ada@example.com
```

Omit any flags to be prompted interactively for missing values. The script defaults to `vim` when no editor is supplied,
matching the editor bundled with each image.

The canonical script source lives at `shared/setup-git-workbench.sh` and is copied into each workbench image during the build.
