### How to Trigger Downstream Workflows

You can use a `workflow_run` trigger. This allows one workflow to trigger others *after* it completes successfully. This creates a "fan-out" system where a single build of the base image can trigger all dependent image builds.

Here is the refined plan:

**1. Upstream Workflow (`runtime-workbench-publish.yaml`)**

This workflow builds the base image. It is triggered only by changes to its own files. When it finishes, it implicitly becomes the trigger for other workflows. You should ensure it pushes a stable tag, like `latest`, that others can refer to.

**2. Downstream Workflow (e.g., `openai-codex-publish.yaml`)**

You'll modify your downstream workflows to have two triggers:
1.  The existing `push` trigger for when their own files change.
2.  A new `workflow_run` trigger that starts the workflow when the `runtime-workbench` build is completed.

You also need to add `if` conditions to your jobs to ensure they only run when necessary.

Here is how you would modify `.github/workflows/openai-codex-publish.yaml`:

```yaml
name: Build and Publish Codex images

on:
  # Existing trigger for when its own files change
  push:
    paths:
      - 'openai-codex-docker/**'
      - 'github-runner-docker/**'
      - '.github/workflows/openai-codex-publish.yaml'
  
  # New trigger for when the base image workflow completes
  workflow_run:
    workflows: ["Build and Publish Runtime Workbench"] # <-- This must match the `name` of the upstream workflow
    types:
      - completed

permissions:
  contents: read
  packages: write

jobs:
  # This job should only run when this workflow is triggered by a push,
  # not by the completion of the base image build.
  build-codex-binary:
    if: github.event_name == 'push'
    uses: spigell/my-shared-workflows/.github/workflows/docker-build-release.yaml@main
    secrets: inherit
    with:
      image-name: codex-binary
      context: ./openai-codex-docker/codex-binary
      version: v0.50.0
      build-args: |
        CODEX_VERSION=rust-v0.50.0

  # This job will now run on a push OR after the base image is built.
  build-codex:
    # The 'if' condition ensures this job only runs if the trigger was a successful workflow_run, or a push.
    if: github.event.workflow_run.conclusion == 'success' || github.event_name == 'push'
    # It only 'needs' the binary build if the trigger was a push.
    needs: ${{ github.event_name == 'push' && '[build-codex-binary]' || '' }}
    uses: spigell/my-shared-workflows/.github/workflows/docker-build-release.yaml@main
    secrets: inherit
    with:
      image-name: codex-workbench
      context: ./openai-codex-docker
      version: ${{ needs.build-codex-binary.outputs.version }}
      build-args: |
        # Always use the 'latest' tag for the runtime base.
        RUNTIME_WORKBENCH_TAG=latest
        # Use the binary from the 'needs' context on a push, otherwise use the latest from the registry.
        CODEX_BINARY_REF=${{ needs.build-codex-binary.outputs.sha-tag || 'latest' }}
      build-contexts: |
        shared=./shared

  # ... the rest of your workflow (e.g., build-github-runner)
```

### Summary of this Approach:

*   **No Redundant Builds:** The `runtime-workbench` is built only once by its own dedicated workflow.
*   **Automatic Rebuilds:** When `runtime-workbench` finishes, the `workflow_run` trigger automatically starts the `build-codex` job (and any other workflows you configure this way).
*   **Independent Rebuilds:** When you push a change to `openai-codex-docker`, only the `openai-codex-publish` workflow runs. It will skip rebuilding the base and will use the `latest` version from the container registry.
*   **Conditional Logic:** The `if` and `needs` conditions ensure that jobs like `build-codex-binary` only run when needed (on a `push`) and not when the workflow is just rebuilding on top of a new base.

You would apply this same pattern to `google-gemini-publish.yaml` and any other workflows that depend on the `runtime-workbench`.
