---
name: workbench-stack-updater
description: Maintain the shared base/tooling image stack and helper images outside the agent-CLI and MCP-specific domains in the my-images repo.
---

# Workbench Stack Updater

## Purpose
Use this skill when updating the shared base images, operational workbench layers, or helper images that underpin the rest of this repository.

## Instructions

### Covered components
- `zmx-binary/`
- `universal-workbench-docker/`
- `debug-sre-workbench-docker/`
- `pulumi-workbench-docker/`
- `pulumi-talos-cluster-workbench-docker/`
- `terragrunt-docker/`
- `sshd-docker/`
- `anki-desktop-docker/`
- shared helpers such as `shared/setup-git-workbench.sh`

### Dependency chain
- `zmx-binary` is published independently and dispatches `zmx-binary-updated`.
- `universal-workbench` consumes `zmx-binary` and dispatches `universal-workbench-updated`.
- `debug-sre-workbench` consumes `universal-workbench` and dispatches `debug-sre-workbench-updated`.
- `pulumi-workbench` consumes `debug-sre-workbench`, and `pulumi-talos-cluster-workbench` consumes `pulumi-workbench`.
- `terragrunt-docker/` consumes `universal-workbench`.
- `sshd-docker/` consumes both `zmx-binary` and `debug-sre-workbench`.
- `anki-desktop-docker/` is standalone and does not participate in the repository-dispatch chain.

### Editing conventions
- When bumping pinned tool versions, keep Dockerfile ARG defaults, workflow `version` values, emitted dispatch payload keys, and README examples aligned.
- Only add `build-contexts: shared=./shared` when the Dockerfile actually copies repo helpers from `shared/`.
- Preserve `trigger-downstreams` as the dispatch job name for workflows that notify dependent builds.
- Keep helper-script behavior documented where users are expected to invoke it directly, especially for `shared/setup-git-workbench.sh`.

### Editing checklist
1. Update `AGENTS.md` when an image is added, removed, or materially changes its place in the dependency chain.
2. Keep standalone images explicitly documented as standalone so future tasks do not add unnecessary dispatch wiring.
3. Re-check upstream/downstream trigger coverage whenever a base image tag or payload key changes.
