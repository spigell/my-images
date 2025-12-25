# Repository Guidelines

## Build and publish flow

- The **universal workbench** (`universal-workbench-docker/`) is the single base; all downstream images layer on top of it.
- **Event-driven architecture**: Publish workflows propagate via `repository_dispatch` events.
    - `universal-workbench-publish` triggers `universal-workbench-updated`.
    - Downstream workflows (e.g., `google-gemini-publish`, `openai-codex-publish`) listen for this event, resolve the new base tag, build their images, and then dispatch their own updates (e.g., `gemini-workbench-updated`, `openai-codex-workbench-updated`).
    - GitHub Runner workflows (`github-runner-publish-gemini`, `github-runner-publish-codex`) listen for these specific workbench updates to build the final runner images.
- Keep downstream dispatch jobs named `trigger-downstreams`.
- Always include the `shared/` build context when building locally or in CI so helper scripts are available.

## Versioning and tooling

- **Dynamic Tag Resolution**: Workflows use the `resolve-ghcr-tag` action to determine which base image tag to use. It prioritizes:
    1. The tag from the `repository_dispatch` payload (automatic updates).
    2. The manual `workflow_dispatch` input.
    3. The latest tag from GHCR (fallback).
- **No static manifests**: We no longer use `versions/` JSON files. Versioning is handled dynamically via the dispatch chain.
- When changing a tool or base version in a Dockerfile, update the matching publish workflow inputs (build args or `version:`) so CI builds the new tag.
- For GitHub runner updates, fetch the latest runner tag from the GitHub API (for example `curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name`).
- For any GitHub-hosted release, prefer the API over manual checks (for example `curl -s https://api.github.com/repos/<owner>/<repo>/releases/latest | jq -r .tag_name`).

## Base image rules and docs

- The universal base already includes the Ubuntu `ubuntu` user; do not add another `useradd ubuntu` step downstream.
- `uv specify-cli` installs GitHub’s `spec-kit` in the universal image, so downstream workbenches already have it.
- Document version bumps or workflow updates in PR summaries.

## Git remote usage

- Push and pull via the `http-spigell-bot` remote (`https://github.com/spigell/my-images.git`); `origin` (SSH) is read-only here. Call git explicitly with that remote (for example `git pull http-spigell-bot main`).
- Name downstream dispatch jobs `trigger-downstreams` (renamed from `update-manifest`) so workflows stay consistent.

## Workbench Overview

| Image directory | Base image | Extends with |
| --- | --- | --- |
| `universal-workbench-docker/` | Ubuntu 24.04 | Go, Python, Node.js runtimes plus shared tooling |
| `openai-codex-docker/` | Universal workbench (already the primary base for the Codex workbench) | Codex binary and related tooling |
| `google-gemini-docker/` | Universal workbench | Gemini CLI stack and fnm aliases |
| `debug-sre-workbench-docker/` | Universal workbench | Docker CLI, kubectl, Helm, kube-lineage, Talosctl, K9s, ArgoCD, etcdctl, Poetry, uv |
| `pulumi-workbench-docker/` | Debug SRE workbench | Pulumi CLI, pulumictl, kubectl, `@pulumi/mcp-server` |
| `pulumi-talos-cluster-workbench-docker/` | Pulumi workbench | Talosctl, K9s, and Talos tooling |
| `github-runner-docker/` | Google Gemini workbench | GitHub Actions runner dependencies; built via its own dedicated workflow |
| `holmes-gpt-docker/` | Debug SRE workbench | HolmesGPT Python runtime plus kube-lineage, ArgoCD, Helm, Azure SQL tooling |
