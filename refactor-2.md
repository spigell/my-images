### Refactoring Plan: Create a Common Runtime Image

The core of this plan is to create a new base image called `runtime-workbench` that contains the common dependencies (Go, Python, Node.js, apt packages), and then have your `codex-workbench` and `google-gemini-workbench` images build from it.

**1. Create the `runtime-workbench` Image**

*   Create a new directory: `runtime-workbench-docker`.
*   Inside this directory, create a `Dockerfile`. This file will be responsible for setting up the shared environment. It will be based on `ubuntu:24.04` and will consolidate the common installation steps from `openai-codex-docker/Dockerfile`.

    **`runtime-workbench-docker/Dockerfile`:**
    ```dockerfile
    # syntax=docker/dockerfile:1.4
    FROM ubuntu:24.04
    SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

    ARG PYTHON_VERSION=3.12
    ARG NODE_VERSION=24
    ARG GOLANG_VERSION=1.25.1
    ENV LANG="C.UTF-8"
    ENV HOME=/root
    ENV GOPATH=/go
    ENV PATH="${GOPATH}/bin:/usr/local/go/bin:${PATH}"
    ENV DEBIAN_FRONTEND=noninteractive

    # Install all common apt packages from openai-codex-docker/Dockerfile
    RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential curl git ... && \
        rm -rf /var/lib/apt/lists/*

    # Install Golang
    RUN # ... (Copy Golang installation logic here) ...

    # Install Python (using pyenv)
    RUN # ... (Copy pyenv and Python installation logic here) ...

    # Install Node.js (using fnm)
    RUN # ... (Copy fnm and Node.js installation logic here) ...

    # Copy the shared git setup script
    # This will require a build context in the workflow
    COPY --from=shared --chmod=0755 /setup-git-workbench.sh /usr/local/bin/setup-git-workbench
    ```

**2. Create a Workflow for the New Base Image**

*   Create a new workflow file: `.github/workflows/runtime-workbench-publish.yaml`.
*   This workflow will build and publish the `runtime-workbench` image. It will be triggered by changes to its directory or by a `workflow_call`.

    **`.github/workflows/runtime-workbench-publish.yaml`:**
    ```yaml
    name: Build and Publish Runtime Workbench

    on:
      push:
        paths:
          - 'runtime-workbench-docker/**'
          - '.github/workflows/runtime-workbench-publish.yaml'
      workflow_call:

    jobs:
      build-runtime-workbench:
        uses: spigell/my-shared-workflows/.github/workflows/docker-build-release.yaml@main
        secrets: inherit
        with:
          image-name: runtime-workbench
          context: ./runtime-workbench-docker
          version: 1.0.0 # Or your preferred versioning scheme
          build-contexts: |
            shared=./shared
    ```

**3. Refactor the `openai-codex-workbench` Image**

*   Update the `openai-codex-docker/Dockerfile` to use the new `runtime-workbench` as its base. This will dramatically simplify the file.

    **`openai-codex-docker/Dockerfile` (Refactored):**
    ```dockerfile
    # syntax=docker/dockerfile:1.4
    ARG RUNTIME_WORKBENCH_TAG=change-me
    ARG CODEX_BINARY_REF=change-me

    FROM ghcr.io/spigell/codex-binary:${CODEX_BINARY_REF} AS codex
    FROM ghcr.io/spigell/runtime-workbench:${RUNTIME_WORKBENCH_TAG}

    LABEL codex.binary.ref="${CODEX_BINARY_REF}"

    COPY --from=codex /usr/local/bin/codex /usr/local/bin/codex

    ENV CODEX_UNSAFE_ALLOW_NO_SANDBOX=1
    ENTRYPOINT ["codex"]
    ```
*   Modify `.github/workflows/openai-codex-publish.yaml` to orchestrate the new build order.

    **`.github/workflows/openai-codex-publish.yaml` (Changes):**
    ```yaml
    jobs:
      # New job to ensure the base image is built
      build-base:
        uses: ./.github/workflows/runtime-workbench-publish.yaml
        secrets: inherit

      build-codex-binary:
        # ... (no changes here) ...

      build-codex:
        needs: [build-base, build-codex-binary] # Add build-base dependency
        uses: spigell/my-shared-workflows/.github/workflows/docker-build-release.yaml@main
        with:
          # ...
          build-args: |
            RUNTIME_WORKBENCH_TAG=${{ needs.build-base.outputs.sha-tag }}
            CODEX_BINARY_REF=${{ needs.build-codex-binary.outputs.sha-tag }}@${{ needs.build-codex-binary.outputs.digest }}
          # ...
    ```

**4. Refactor the `google-gemini-workbench` Image**

*   Similarly, update the `google-gemini-docker/Dockerfile` to use the `runtime-workbench` and copy the CLI from the `google-gemini-basic` image.

    **`google-gemini-docker/Dockerfile` (Refactored):**
    ```dockerfile
    # syntax=docker/dockerfile:1.7
    ARG RUNTIME_WORKBENCH_TAG=change-me
    ARG GEMINI_BASIC_TAG=change-me

    FROM ghcr.io/spigell/google-gemini-basic:${GEMINI_BASIC_TAG} AS gemini
    FROM ghcr.io/spigell/runtime-workbench:${RUNTIME_WORKBENCH_TAG}

    # Copy the gemini CLI from the basic image
    COPY --from=gemini /usr/local/bin/gemini /usr/local/bin/gemini

    WORKDIR /project
    ```
*   Modify `.github/workflows/google-gemini-publish.yaml` accordingly.

This approach centralizes your runtime environment, making it easier to manage and update, while keeping your final workbench images separate and respecting the existing dependency flow.
