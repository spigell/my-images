---
name: image-creator
description: Create new container images in the my-images repo and wire them into the shared publish/dispatch workflows and reusable remote workflows.
---

# Image Creator

Use this skill when adding a brand-new image directory or wiring a new publish workflow. It focuses on build flows, remote reusable workflows, and dispatch wiring.

## Build/publish model (context)
- Universal workbench (`universal-workbench-docker/`) is the base; downstream images layer on top.
- Event-driven via `repository_dispatch`:
  - `universal-workbench-publish` → `universal-workbench-updated`.
  - Downstreams (e.g., `google-gemini-publish`, `openai-codex-publish`) listen, rebuild, then emit their own updates (e.g., `gemini-workbench-updated`, `openai-codex-workbench-updated`).
  - Runner workflows (e.g., `github-runner-publish-gemini`, `github-runner-publish-codex`) listen for those downstream update events.
- Some images publish with only `push` + `workflow_dispatch` because they have no upstream image dependency chain or downstream consumers.
- Keep downstream dispatch jobs named `trigger-downstreams`.
- Include the `shared/` build context when the Dockerfile copies repo helper scripts from `shared/` or the workflow already uses `build-contexts: shared=./shared`.

## Remote reusable workflow (shared)
- Most builds call `spigell/my-shared-workflows/.github/workflows/docker-build-release.yaml@main`.
- Required `secrets`: `gh-token: ${{ secrets.IMAGES_PUBLISH_TOKEN }}` (push to GHCR).
- Key inputs:
  - `image-name`: registry/image name suffix (e.g., `codex-binary`).
  - `context`: path to the image directory.
  - `version`: tag to push (often `vX.Y.Z` or the upstream version).
  - `build-args`: newline list of `KEY=VALUE`.
- Outputs: `version`, `sha-tag`, `digest` (commonly reused by dependent builds and dispatch payloads).

## Creating a new image
1. **Scaffold directory**: Create `<image-name>-docker/` (or similar). Add a `Dockerfile`, supporting files, and `README.md`. Base off an existing sibling if similar. Only copy from `shared/` when the image needs repo helper scripts such as `setup-git-workbench` or `start-shell-mcp`.
2. **Update root README**: Add the image to the table with base and description.
3. **Add publish workflow** in `.github/workflows/<image>-publish.yaml`:
   - Triggers: always include `push` on the image path + workflow file and `workflow_dispatch`. Add `repository_dispatch` only when the image depends on another published image event.
   - If it depends on an upstream GHCR image such as `universal-workbench` or `debug-sre-workbench`, add a resolve job using `.github/actions/resolve-ghcr-tag` (payload > manual input > latest GHCR).
   - Add a build job that `uses: spigell/my-shared-workflows/.github/workflows/docker-build-release.yaml@main` with `image-name`, `context`, `version`, and `build-args` (include upstream tags/digests as needed).
   - Add `build-contexts: shared=./shared` only when the Dockerfile consumes files from `shared/`.
   - If another image depends on this one, add `trigger-downstreams` using `peter-evans/repository-dispatch@v3` to emit an update event (keep the job name `trigger-downstreams`).
4. **Secrets**: The workflow expects `IMAGES_PUBLISH_TOKEN` for GHCR pushes and any dispatch jobs.
5. **Dispatch wiring**: Choose an event name that downstream workflows will watch (pattern: `<image>-updated`) only when this image has downstream consumers. If this image depends on another, add a `repository_dispatch` trigger to listen to that upstream event.
6. **Versioning**: Prefer dynamic tag resolution and avoid static manifest JSON. When bumping tools in the new image, also update the workflow `version`, relevant build args, and any matching Dockerfile ARG/default.

## Git remote and approvals
- Keep PR summaries noting new workflows, dispatch events, and any version bump rationale.
