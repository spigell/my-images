# Repository Guidelines

## Base image rules and docs

- The universal base already includes the Ubuntu `ubuntu` user; do not add another `useradd ubuntu` step downstream.
- `uv specify-cli` installs GitHub’s `spec-kit` in the universal image, so downstream workbenches already have it.

## Git remote usage

- Push and pull via the `http-spigell-bot` remote (`https://github.com/spigell/my-images.git`); `origin` (SSH) is read-only here. Call git explicitly with that remote (for example `git pull http-spigell-bot main`).
- Name downstream dispatch jobs `trigger-downstreams` (renamed from `update-manifest`) so workflows stay consistent.
