# GitHub Runners

This directory contains the Dockerfile and scripts for building the self-hosted GitHub Actions Runner images.

There are two dedicated runner workflows in this repository:
- `Build and Publish GitHub Runner image (Codex AI agent)`
- `Build and Publish GitHub Runner image (Gemini AI Agent)`

## Why two workflows?
Even though both runner workflows build from the same underlying `github-runner-docker/` context and share the same actions/runner binary version, they are triggered by different upstream events and layer on top of different workbench base images:
- **Codex Runner**: Layers on `codex-workbench` and is published with tags matching the runner version (e.g., `2.335.0`).
- **Gemini Runner**: Layers on `google-gemini-workbench` and `spigell-gemini-workbench` and is published with tags matching the resolved workbench version to ensure tag parity.

## Versioning and Propagation
Renovate tracks `actions/runner` across the shared Dockerfile and both workflows:
1. `github-runner-docker/Dockerfile`
2. `.github/workflows/github-runner-publish-codex.yaml` (defined in top-level `env.runner_version`)
3. `.github/workflows/github-runner-publish-gemini.yaml` (defined in top-level `env.runner_version`)

An update to `actions/runner` produces a single grouped Pull Request that bumps the version in all three files concurrently, ensuring automerge works correctly and runners stay in sync.
