# Repository Guidelines

## Skills index
- `image-creator` (`.agents/skills/image-creator/SKILL.md`): Add or extend image directories, publish workflows, dispatch wiring, and shared reusable workflow usage.
- `mcp-tooling-maintainer` (`.agents/skills/mcp-tooling-maintainer/SKILL.md`): Maintain shell MCP tooling, dedicated MCP server images, and related MCP-facing documentation/configuration.

## MCP and tool inventory
- `universal-workbench-docker/` plus `shared/start-shell-mcp.sh`: shared base image with `mcp-proxy`, `mcp-shell`, and the `start-shell-mcp` wrapper for exposing a constrained shell over HTTP.
- `github-mcp-server-docker/`: dedicated GitHub MCP server image exposed through `mcp-proxy`.
- `ansible-mcp-server-docker/`: dedicated Ansible MCP server image built from `vscode-ansible` and exposed through `mcp-proxy`.
- `notebooklm-mcp-docker/`: NotebookLM MCP CLI/server image.
- `pulumi-workbench-docker/`: workbench image that installs `@pulumi/mcp-server` alongside Pulumi tooling.
- `openai-codex-docker/config/config.toml`: Codex workbench defaults; this repo does not ship a repo-local Codex MCP server config beyond the example in `universal-workbench-docker/README.md`.
- `google-gemini-docker/*/etc/gemini-cli/system-defaults.json`: Gemini CLI defaults such as vim mode, checkpointing, and sandbox behavior.
- `anki-desktop-docker/ankiconnect-config.json`: AnkiConnect HTTP listener configuration on port `8765`.
- `shared/setup-git-workbench.sh`: shared Git identity/bootstrap helper copied into workbench images.

## Build and publish flow
- The **universal workbench** (`universal-workbench-docker/`) is the single base; all downstream images layer on top of it.
- **Event-driven architecture**: Publish workflows propagate via `repository_dispatch` events.
    - `universal-workbench-publish` triggers `universal-workbench-updated`.
    - Downstream workflows (e.g., `google-gemini-publish`, `openai-codex-publish`) listen for this event, resolve the new base tag, build their images, and then dispatch their own updates (e.g., `gemini-workbench-updated`, `openai-codex-workbench-updated`).
    - GitHub Runner workflows (`github-runner-publish-gemini`, `github-runner-publish-codex`) listen for these specific workbench updates to build the final runner images.
- Some publish workflows are intentionally standalone and omit `repository_dispatch` when the image has no upstream dependency chain or downstream consumers, such as `github-mcp-server-publish` and `anki-docker-publish`.
- Keep downstream dispatch jobs named `trigger-downstreams`.
- Include the `shared/` build context when the Dockerfile copies repo helper scripts from `shared/` or the workflow already wires `build-contexts: shared=./shared`. Build from the repository root when using that context.

## Versioning and tooling
- Dynamic tag resolution: workflows with upstream image dependencies use `resolve-ghcr-tag`, preferring (1) dispatch payload, (2) manual `workflow_dispatch` input, (3) latest GHCR tag.
- No static manifests (versions JSON); versioning is handled dynamically via dispatch.
- Most publish jobs use `spigell/my-shared-workflows/.github/workflows/docker-build-release.yaml@main`; keep workflow `version`, Dockerfile args/defaults, and emitted dispatch payloads aligned when changing image versions.
