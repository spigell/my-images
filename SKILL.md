---
name: my-images-maintenance
description: Update Codex releases (e.g., rust-v0.xx.x) and other image versions in the my-images repo, configure MCP servers, and manage skills for this codebase.
---

# My Images Maintenance

Use this skill when updating Codex or other image versions, wiring MCP servers, or installing/managing skills for this repository.

## Repo basics
- Run git commands against the `http-spigell-bot` remote (HTTPS; `origin` is read-only).
- Each top-level image directory acts like its own module; edit only what the change requires.
- Builds depend on the universal workbench base and `shared/` context; keep downstream dispatch jobs named `trigger-downstreams`.

## Codex version bumps (rust-vX.Y.Z)
- Search for the prior tag with `rg "rust-v"` inside `openai-codex-docker`.
- Update defaults:
  - `openai-codex-docker/codex-binary/Dockerfile`: `CODEX_VERSION`.
  - `openai-codex-docker/Dockerfile`: `CODEX_BINARY_REF`.
  - `openai-codex-docker/docker-compose.yaml`: `CODEX_VERSION` and `CODEX_BINARY_REF` build args.
  - `openai-codex-docker/README.md`: example commands/tags and any sample digests.
- Re-run `rg "rust-v"` to ensure no stale versions remain; keep the tag format `rust-v0.80.0` and include digests when known.
- Note any version bump and related workflow impact in the PR summary.

## Other image/version updates
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
