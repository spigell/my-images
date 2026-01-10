---
name: my-images-maintenance
description: Update tool versions in the my-images container builds (e.g., Codex tags, runner/tool bumps) and capture MCP/skill setup steps needed for those updates.
---

# My Images Maintenance

Use this skill when updating tools or base versions inside the images (e.g., Codex binaries, runner versions) and when wiring MCP/skill setup needed for those updates. Do not use it for unrelated feature work.

## Repo basics
- Run git commands against the `http-spigell-bot` remote (HTTPS; `origin` is read-only).
- Each top-level image directory acts like its own module; edit only what the change requires.
- Builds depend on the universal workbench base and `shared/` context; keep downstream dispatch jobs named `trigger-downstreams`.

## Build and publish flow (images)
- Universal workbench (`universal-workbench-docker/`) is the base; downstream images layer on top.
- Publish flows are event-driven via `repository_dispatch`:
  - `universal-workbench-publish` → `universal-workbench-updated`.
  - Downstreams (e.g., `google-gemini-publish`, `openai-codex-publish`) listen, resolve the new base tag, build, then dispatch their own updates (e.g., `gemini-workbench-updated`, `openai-codex-workbench-updated`).
  - GitHub Runner workflows (`github-runner-publish-gemini`, `github-runner-publish-codex`) listen for the specific workbench update to build runner images.
- Always include the `shared/` build context when building locally or in CI so helper scripts are available.

## Versioning and tooling
- Dynamic tag resolution: workflows use `resolve-ghcr-tag`, preferring (1) dispatch payload, (2) manual `workflow_dispatch` input, (3) latest GHCR tag.
- No static manifests (versions JSON); versioning is handled dynamically via dispatch.
- When changing a tool/base version in a Dockerfile, mirror the change in the publish workflow inputs (build args or `version:`) so CI builds the new tag.
- For GitHub runner updates, fetch the latest runner tag from the GitHub API (`curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name`).
- For any GitHub-hosted release, prefer the API over manual checks (`curl -s https://api.github.com/repos/<owner>/<repo>/releases/latest | jq -r .tag_name`).
- Document version bumps or workflow updates in PR summaries.

## Codex version bumps (rust-vX.Y.Z)
- Search for the prior tag with `rg "rust-v"` inside `openai-codex-docker`.
- Update defaults:
  - `openai-codex-docker/codex-binary/Dockerfile`: `CODEX_VERSION`.
  - `openai-codex-docker/Dockerfile`: `CODEX_BINARY_REF`.
  - `openai-codex-docker/docker-compose.yaml`: `CODEX_VERSION` and `CODEX_BINARY_REF` build args.
  - `openai-codex-docker/README.md`: example commands/tags and any sample digests.
- Re-run `rg "rust-v"` to ensure no stale versions remain; keep the tag format `rust-v0.80.0` and include digests when known.
- Note any version bump and related workflow impact in the PR summary.

## Other image/tool updates
- Favor dynamic tag resolution in workflows; avoid static manifest files.
- When changing a base/tool version in a Dockerfile, mirror the new value in publish workflow inputs so CI builds the updated tag.
- For GitHub runner updates, pull the latest runner tag from the GitHub API (curl + jq) instead of guessing.
- Always include the `shared/` build context when building locally or in CI to keep helper scripts available.

## MCP servers (Codex client)
- Define servers in `~/.codex/config.toml` under `[mcp_servers.<name>]`:
  - Example shell server (runs the bundled MCP):  
    `command = "npx"`  
    `args = ["-y", "@openai/codex-shell-tool-mcp"]`
  - Example GitHub server (if available):  
    `command = "github-mcp"`  
    `args = ["--config", "/path/to/config.toml"]`
- Keep commands explicit; include any required env vars or token files in args/config, not inline secrets.
- Restart Codex after adding or changing MCP entries so the client reloads servers.

## Skill installation and management
- Skills live in `$CODEX_HOME/skills` (defaults to `~/.codex/skills`); restart Codex after installing.
- List curated skills: `scripts/list-curated-skills.py [--format json]` (uses network; request escalation if sandboxed).
- Install from curated list: `scripts/install-skill-from-github.py --repo openai/skills --path skills/.curated/<skill-name> [--dest <dir>]`.
- Install from another repo/path: `scripts/install-skill-from-github.py --repo <owner>/<repo> --path <path> [--ref <ref>] [--dest <dir>]`.
- Avoid overwriting existing skill directories; pass `--name` to override install names when needed.
