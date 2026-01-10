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
- Dynamic tag resolution: workflows use `resolve-ghcr-tag`, preferring (1) dispatch payload, (2) manual `workflow_dispatch` input, (3) latest GHCR tag.
- No static manifests (versions JSON); versioning is handled dynamically via dispatch.
