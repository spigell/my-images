# Repository Guidelines

- Maintain the **universal workbench** (`universal-workbench-docker/`) as the single source for shared runtimes and tooling
  (Go 1.25.1, delve, golangci-lint, Python 3.12 via pyenv, Node.js 24 via fnm, and common CLI utilities).
- The universal base already includes the Ubuntu `ubuntu` user. Do **not** add another `useradd ubuntu` step in downstream Dockerfiles.
- Update `universal-workbench-docker/base-version.json` (usually to the publishing short commit SHA, e.g., `abcdef0`) whenever the universal image changes so
  dependent workflows pull the fresh tag.
- Document any version bumps or related workflow updates in the PR summary.
- Keep `shared/setup-git-workbench.sh` in sync and copied into every workbench image that relies on it, and ensure vim is installed to match the script defaults.
- When building images locally or in CI, continue providing the `shared/` build context so Dockerfiles can access the helper script.

## Workbench Overview

| Image directory | Base image | Extends with |
| --- | --- | --- |
| `universal-workbench-docker/` | Ubuntu 24.04 | Go, Python, Node.js runtimes plus shared tooling |
| `openai-codex-docker/` | Universal workbench | Codex binary and Codex-specific tooling |
| `google-gemini-docker/` | Universal workbench | Gemini CLI stack and fnm aliases |
| `pulumi-workbench-docker/` | Universal workbench | Pulumi CLI, pulumictl, kubectl, `@pulumi/mcp-server` |
| `pulumi-talos-cluster-workbench-docker/` | Pulumi workbench | Talosctl, K9s, and Talos-related tooling |
