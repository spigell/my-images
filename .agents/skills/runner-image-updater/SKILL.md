---
name: runner-image-updater
description: Maintain github-runner images, registration scripts, and agent-specific runner publish workflows in the my-images repo.
---

# Runner Image Updater

## Purpose
Use this skill when updating `github-runner-docker/`, its bootstrap scripts, or the workflows that publish self-hosted runner images derived from agent workbenches.

## Instructions

### Covered components
- `github-runner-docker/Dockerfile`
- `github-runner-docker/entrypoint.sh`
- `github-runner-docker/fetch-runner-token.sh`
- `.github/workflows/github-runner-publish-codex.yaml`
- `.github/workflows/github-runner-publish-gemini.yaml`

### Runtime conventions
- The runner image is parameterized by `BASE_IMAGE_NAME` and `BASE_IMAGE_TAG`; keep it generic so the same Dockerfile can build the Codex and Gemini runner variants.
- `entrypoint.sh` requires `GITHUB_URL` and `GITHUB_PAT`, supports `repo`, `org`, and `enterprise` registration scopes, and defaults to ephemeral replacement runners with updates disabled.
- `fetch-runner-token.sh` derives the API endpoint from `GITHUB_HOST` and `RUNNER_SCOPE`; preserve that branching logic when touching registration behavior.
- `shared/` is part of the build context for runner images because the shared workflow already builds from the repository root and some sibling images depend on repo helper scripts.

### Workflow conventions
- The Codex runner listens for `openai-codex-workbench-updated` and resolves `codex-workbench` tags through `resolve-ghcr-tag`.
- The Gemini runner listens for `gemini-workbench-updated` and builds both the published Google Gemini and forked Spigell Gemini runner variants from one workflow.
- Keep `RUNNER_VERSION` in the workflow build args aligned with the value in `github-runner-docker/Dockerfile`.
- When adjusting consumed base-image names or payload keys, update both the dispatch sender and the runner workflow inputs/resolution logic in the same change.

### Editing checklist
1. Verify environment-variable names and scope parsing still match `entrypoint.sh` and `fetch-runner-token.sh`.
2. Keep workflow names and image names stable unless the task explicitly requires a published image rename.
3. Update `AGENTS.md` when runner variants, triggers, or supported scopes change.
