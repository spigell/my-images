# Repository Guidelines

- Maintain the **universal workbench** (`universal-workbench-docker/`) as the single source for shared runtimes and tooling.
- All version manifests live under the repository-level `versions/` directory (one file per image, each exactly `{"tag": "<image-tag>"}`); do not introduce other fields because the composite action and workflows rely on this shared schema.
- The universal base already includes the Ubuntu `ubuntu` user. Do **not** add another `useradd ubuntu` step in downstream Dockerfiles.
- Update `versions/universal-workbench.json` whenever the universal image changes so dependent workflows pull the
  fresh tag.
- Document any version bumps or related workflow updates in the PR summary.
- When building images locally or in CI, continue providing the `shared/` build context so Dockerfiles can access the helper script.
- Push branches to the `http-spigell-bot` remote (https://github.com/spigell/my-images.git) instead of `origin`—the SSH remote is read-only in this workspace.

## Workbench Overview

| Image directory | Base image | Extends with |
| --- | --- | --- |
| `universal-workbench-docker/` | Ubuntu 24.04 | Go, Python, Node.js runtimes plus shared tooling |
| `openai-codex-docker/` | Universal workbench | Codex binary and related tooling |
| `google-gemini-docker/` | Universal workbench | Gemini CLI stack and fnm aliases |
| `pulumi-workbench-docker/` | Universal workbench | Pulumi CLI, pulumictl, kubectl, `@pulumi/mcp-server` |
| `pulumi-talos-cluster-workbench-docker/` | Pulumi workbench | Talosctl, K9s, and Talos tooling |
| `github-runner-docker/` | Google Gemini workbench | GitHub Actions runner dependencies; built via its own dedicated workflow |
