# Repository Guidelines

## Build and publish flow

- The **universal workbench** (`universal-workbench-docker/`) is the single base; all downstream images layer on top of it.
- **Event-driven architecture**: Publish workflows propagate via `repository_dispatch` events.
    - `universal-workbench-publish` triggers `universal-workbench-updated`.
    - Downstream workflows (e.g., `google-gemini-publish`, `openai-codex-publish`) listen for this event, resolve the new base tag, build their images, and then dispatch their own updates (e.g., `gemini-workbench-updated`, `openai-codex-workbench-updated`).
    - GitHub Runner workflows (`github-runner-publish-gemini`, `github-runner-publish-codex`) listen for these specific workbench updates to build the final runner images.
- Keep downstream dispatch jobs named `trigger-downstreams`.
- Always include the `shared/` build context when building locally or in CI so helper scripts are available.

## Base image rules and docs

- The universal base already includes the Ubuntu `ubuntu` user; do not add another `useradd ubuntu` step downstream.
- `uv specify-cli` installs GitHub’s `spec-kit` in the universal image, so downstream workbenches already have it.

## Git remote usage

- Push and pull via the `http-spigell-bot` remote (`https://github.com/spigell/my-images.git`); `origin` (SSH) is read-only here. Call git explicitly with that remote (for example `git pull http-spigell-bot main`).
- Name downstream dispatch jobs `trigger-downstreams` (renamed from `update-manifest`) so workflows stay consistent.
