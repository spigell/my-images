---
name: agent-workbench-updater
description: Maintain agent-facing CLI workbench images, their shipped defaults, and downstream publish wiring in the my-images repo.
---

# Agent Workbench Updater

## Purpose
Use this skill when updating the repository's agent-oriented CLI workbench images, their runtime defaults, or their publish/dispatch workflows.

## Instructions

### Covered components
- `openai-codex-docker/` and `openai-codex-docker/codex-binary/`: Codex workbench plus the split binary artifact image and `/etc/codex/config.toml`.
- `google-gemini-docker/google/` and `google-gemini-docker/spigell/`: published and forked Gemini CLI workbench variants plus `etc/gemini-cli/system-defaults.json`.
- `google-jules-docker/`: Jules CLI workbench.
- `claude-code-docker/`: Claude Code workbench, including `bubblewrap`, `socat`, and sandbox runtime dependencies.
- `qwen-code-docker/`: Qwen Code CLI workbench.

### Build and workflow conventions
- These images typically resolve `UNIVERSAL_WORKBENCH_TAG` through `.github/actions/resolve-ghcr-tag`, preferring repository-dispatch payloads, then manual workflow inputs, then the latest GHCR tag.
- `openai-codex-publish.yaml` builds `codex-binary` first and then builds the main Codex workbench from the exact `tag@digest` output.
- `google-gemini-publish.yaml` builds both the `google/` and `spigell/` variants and emits a single `gemini-workbench-updated` event containing both tags.
- `claude-code-publish.yaml`, `google-jules-publish.yaml`, and `qwen-code-publish.yaml` each emit a workbench-specific `repository_dispatch` event after publish.
- Keep workflow `version` values, Dockerfile ARG defaults, OCI labels, and README/config examples aligned in the same change when bumping a CLI or runtime.

### Runtime and config conventions
- Codex ships a repo-managed `/etc/codex/config.toml`; keep it aligned with the usage guidance in `universal-workbench-docker/README.md`.
- Gemini defaults live in `google-gemini-docker/*/etc/gemini-cli/system-defaults.json`; preserve intentional defaults such as vim mode, checkpointing, and sandbox behavior unless the task explicitly changes them.
- Claude Code depends on `bubblewrap`, `socat`, and `@anthropic-ai/sandbox-runtime`; treat those as part of the supported runtime surface when changing versions.
- Most workbench images use `/bin/bash -lc` entrypoints and validate the installed CLI with `--help` or `--version` during build; keep that pattern unless the upstream tool requires a different contract.

### Editing checklist
1. Update the nearest README or config example when a shipped default, entrypoint, or required environment variable changes.
2. Preserve downstream dispatch job names as `trigger-downstreams`.
3. Keep the root `AGENTS.md` inventory aligned when a new agent workbench variant is added or removed.
