# my-images

## Available images

- **gemini-cli**: Minimal devcontainer-based image with the Google Gemini CLI preinstalled.
- **gemini-cli-workbench**: Extends `gemini-cli` with common terminal tooling for interactive workflows.

## Git setup helper

Every workbench image includes the `setup-git-workbench` helper under `/usr/local/bin`. Run it once inside a container to
configure your preferred Git identity and editor:

```bash
setup-git-workbench --name "Ada Lovelace" --email ada@example.com --editor "code --wait"
```

Omit any flags to be prompted interactively for missing values.
