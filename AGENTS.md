# Repository Guidelines

## Skills index
- `image-creator` (`.agents/skills/image-creator/SKILL.md`): Add or extend image directories, publish workflows, dispatch wiring, and shared reusable workflow usage.
- `mcp-tooling-maintainer` (`.agents/skills/mcp-tooling-maintainer/SKILL.md`): Maintain shell MCP tooling, dedicated MCP server images, and related MCP-facing documentation/configuration.
- `agent-workbench-updater` (`.agents/skills/agent-workbench-updater/SKILL.md`): Maintain agent-facing CLI workbench images, their defaults, and downstream publish wiring.
- `workbench-stack-updater` (`.agents/skills/workbench-stack-updater/SKILL.md`): Maintain the shared base/tooling image stack and helper images outside the agent-CLI and MCP-specific domains.

## Agent and workbench inventory
- `universal-workbench-docker/`: shared Ubuntu-based workbench with language runtimes, `setup-git-workbench`, `zmx`, and the shell MCP toolchain used by most downstream images.
- `openai-codex-docker/` plus `openai-codex-docker/codex-binary/`: Codex workbench and its split binary artifact image; `openai-codex-docker/config/config.toml` provides shipped Codex defaults.
- `google-gemini-docker/google/` and `google-gemini-docker/spigell/`: Gemini CLI workbench variants; both ship `etc/gemini-cli/system-defaults.json`.
- `google-jules-docker/`: Google Jules CLI workbench derived from the universal workbench.
- `claude-code-docker/`: Claude Code workbench with `bubblewrap`, `socat`, and `@anthropic-ai/sandbox-runtime`.
- `qwen-code-docker/`: Qwen Code CLI workbench derived from the universal workbench.
- `github-runner-docker/`: GitHub Actions runner layer that builds agent-specific runner images for Codex and Gemini workbenches.
- `debug-sre-workbench-docker/`: operational workbench with Docker, PostgreSQL clients, Kubernetes/Talos/ArgoCD tooling, HolmesGPT runtime, and related CLI utilities.
- `pulumi-workbench-docker/`: Pulumi CLI workbench layered on Debug SRE and bundling `@pulumi/mcp-server`.
- `pulumi-talos-cluster-workbench-docker/`: Pulumi Talos cluster workbench layered on the Pulumi workbench.
- `terragrunt-docker/`: Terragrunt and `tenv` workbench derived from the universal workbench.
- `sshd-docker/`: LinuxServer OpenSSH image extended with `zmx` and selected SRE tooling.
- `anki-desktop-docker/`: CI-oriented Anki Desktop image with bundled AnkiConnect configuration.
- `zmx-binary/`: scratch image that packages the `zmx` binary consumed by other builds.

## MCP and tool inventory
- `universal-workbench-docker/` plus `shared/start-shell-mcp.sh`: shared base image with `mcp-proxy`, `mcp-shell`, and the `start-shell-mcp` wrapper for exposing a constrained shell over HTTP.
- `github-mcp-server-docker/`: dedicated GitHub MCP server image exposed through `mcp-proxy`.
- `ansible-mcp-server-docker/`: dedicated Ansible MCP server image built from `vscode-ansible` and exposed through `mcp-proxy`.
- `notebooklm-mcp-docker/`: NotebookLM MCP CLI/server image.
- `pulumi-workbench-docker/`: workbench image that installs `@pulumi/mcp-server` alongside Pulumi tooling.
- `openai-codex-docker/config/config.toml`: Codex workbench defaults; this repo does not ship a repo-local Codex MCP server config beyond the example in `universal-workbench-docker/README.md`.
- `google-gemini-docker/*/etc/gemini-cli/system-defaults.json`: Gemini CLI defaults such as vim mode, checkpointing, and sandbox behavior.
- `github-runner-docker/entrypoint.sh` and `github-runner-docker/fetch-runner-token.sh`: self-hosted runner bootstrap scripts for repo, org, or enterprise registration-token flows.
- `anki-desktop-docker/ankiconnect-config.json`: AnkiConnect HTTP listener configuration on port `8765`.
- `shared/setup-git-workbench.sh`: shared Git identity/bootstrap helper copied into workbench images.

## Build and publish flow
- The **universal workbench** (`universal-workbench-docker/`) is the single base; all downstream images layer on top of it.
- The broader stack fans out as `zmx-binary` → `universal-workbench` → agent/tooling workbenches, with `debug-sre-workbench` → `pulumi-workbench` → `pulumi-talos-cluster-workbench` as a second downstream chain and `github-runner-docker/` consuming published agent workbench tags.
- **Event-driven architecture**: Publish workflows propagate via `repository_dispatch` events.
    - `universal-workbench-publish` triggers `universal-workbench-updated`.
    - Downstream workflows (e.g., `google-gemini-publish`, `openai-codex-publish`) listen for this event, resolve the new base tag, build their images, and then dispatch their own updates (e.g., `gemini-workbench-updated`, `openai-codex-workbench-updated`).
    - GitHub Runner workflows (`github-runner-publish-gemini`, `github-runner-publish-codex`) listen for these specific workbench updates to build the final runner images.
- `debug-sre-workbench-publish` dispatches `debug-sre-workbench-updated`, which drives `pulumi-workbench-publish`; `zmx-binary-publish` dispatches `zmx-binary-updated`, which drives both `universal-workbench-publish` and `sshd-publish`.
- Some publish workflows are intentionally standalone and omit `repository_dispatch` when the image has no upstream dependency chain or downstream consumers, such as `github-mcp-server-publish` and `anki-docker-publish`.
- Keep downstream dispatch jobs named `trigger-downstreams`.
- Include the `shared/` build context when the Dockerfile copies repo helper scripts from `shared/` or the workflow already wires `build-contexts: shared=./shared`. Build from the repository root when using that context.

## Versioning and tooling
- Dynamic tag resolution: workflows with upstream image dependencies use `resolve-ghcr-tag`, preferring (1) dispatch payload, (2) manual `workflow_dispatch` input, (3) latest GHCR tag.
- No static manifests (versions JSON); versioning is handled dynamically via dispatch.
- Most publish jobs use `spigell/my-shared-workflows/.github/workflows/docker-build-release.yaml@main`; keep workflow `version`, Dockerfile args/defaults, and emitted dispatch payloads aligned when changing image versions.
