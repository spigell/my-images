# Repository Guidelines

- Maintain the **universal workbench** (`universal-workbench-docker/`) as the single source for shared runtimes and tooling.
- All version manifests live under the repository-level `versions/` directory (one file per image, each exactly `{"tag": "<image-tag>"}`); do not introduce other fields because the composite action and workflows rely on this shared schema.
- Version manifests are bumped automatically by CI; do not edit files under `versions/` manually.
- When upgrading any tooling version in a Dockerfile, update the corresponding publish workflow inputs so CI builds the new tag.
- Gemini CLI upgrades follow the npm release stream; run `npm view @google/gemini-cli version` (or query https://api.github.com/repos/googleapis/google-cloud-node/releases/latest if upstream starts publishing via GitHub releases) to determine the latest tag before updating Dockerfiles and workflows.
- GitHub runner upgrades track official releases; fetch the newest tag from https://github.com/actions/runner/releases (for example via `curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name`) before making changes.
- For any GitHub-hosted release, prefer querying the API (`curl -s https://api.github.com/repos/<owner>/<repo>/releases/latest | jq -r .tag_name`) so agents can script updates consistently and avoid relying on manual web checks.
- The universal base already includes the Ubuntu `ubuntu` user. Do **not** add another `useradd ubuntu` step in downstream Dockerfiles.
- Update `versions/universal-workbench.json` whenever the universal image changes so dependent workflows pull the
  fresh tag.
- Document any version bumps or related workflow updates in the PR summary.
- When building images locally or in CI, continue providing the `shared/` build context so Dockerfiles can access the helper script.
- Push and pull via the `http-spigell-bot` remote (https://github.com/spigell/my-images.git); the default `origin` SSH remote is read-only in this workspace. Run commands explicitly against that remote (for example, `git pull http-spigell-bot main`).

## Workbench Overview

| Image directory | Base image | Extends with |
| --- | --- | --- |
| `universal-workbench-docker/` | Ubuntu 24.04 | Go, Python, Node.js runtimes plus shared tooling |
| `openai-codex-docker/` | Universal workbench | Codex binary and related tooling |
| `google-gemini-docker/` | Universal workbench | Gemini CLI stack and fnm aliases |
| `debug-sre-workbench-docker/` | Universal workbench | Docker CLI, kubectl, Helm, kube-lineage, Talosctl, K9s, ArgoCD, etcdctl, Poetry, uv |
| `pulumi-workbench-docker/` | Debug SRE workbench | Pulumi CLI, pulumictl, kubectl, `@pulumi/mcp-server` |
| `pulumi-talos-cluster-workbench-docker/` | Pulumi workbench | Talosctl, K9s, and Talos tooling |
| `github-runner-docker/` | Google Gemini workbench | GitHub Actions runner dependencies; built via its own dedicated workflow |
| `holmes-gpt-docker/` | Debug SRE workbench | HolmesGPT Python runtime plus kube-lineage, ArgoCD, Helm, Azure SQL tooling |
