# Repository Guidelines

- When updating the Codex version, ensure that every reference in `openai-codex/` (Dockerfiles, README, docker-compose) and the
  `.github/workflows/openai-codex-publish.yaml` workflow are kept in sync.
- Document any version bumps or related workflow updates in the PR summary.
- Keep `setup-git-workbench.sh` in sync across all workbench Dockerfiles that copy it into the image and update the usage docs when the script changes.

| Area | Go usage details | Python usage details | Node.js usage details |
| --- | --- | --- | --- |
| `google-gemini-docker/` | Installs the Go toolchain for the Gemini workbench image. | Preinstalls Python 3.12 with Pyenv and configures Poetry and uv in the Gemini base image. | Provides fnm-managed Node.js along with Corepack, pnpm, yarn, and the Gemini CLI. |
| `openai-codex/` | Installs the Go toolchain for the Codex workbench image. | Installs Python 3.12 with Pyenv and sets up Poetry, uv, and common Python tooling. | Installs Node.js via fnm and enables Corepack-managed package managers. |
| `pulumi-workbench-docker/` | Uses the Golang image to compile Delve for the Pulumi workbench. | – | – |
