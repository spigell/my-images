# Repository Guidelines

- When updating the Codex version, ensure that every reference in `openai-codex/` (Dockerfiles, README, docker-compose) and the
  `.github/workflows/openai-codex-publish.yaml` workflow are kept in sync.
- Document any version bumps or related workflow updates in the PR summary.

| Area | Go usage details |
| --- | --- |
| `google-gemini-docker/` | Installs the Go toolchain for the Gemini workbench image. |
| `openai-codex/` | Installs the Go toolchain for the Codex workbench image. |
| `pulumi-workbench-docker/` | Uses the Golang image to compile Delve for the Pulumi workbench. |
