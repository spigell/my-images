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
