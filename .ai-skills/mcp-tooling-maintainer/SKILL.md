---
name: mcp-tooling-maintainer
description: Maintain shell MCP tooling, dedicated MCP server images, and related MCP-facing docs/configuration in the my-images repo.
---

# MCP Tooling Maintainer

Use this skill when editing MCP-related images, wrappers, workflows, or docs in this repository.

## Covered components
- `universal-workbench-docker/` and `shared/start-shell-mcp.sh`: shell MCP server exposure through `mcp-proxy` plus `mcp-shell`.
- `github-mcp-server-docker/`: GitHub MCP server behind `mcp-proxy`.
- `ansible-mcp-server-docker/`: Ansible MCP server build from `vscode-ansible`, exposed over HTTP through `mcp-proxy`.
- `notebooklm-mcp-docker/`: NotebookLM MCP CLI/server image.
- `pulumi-workbench-docker/`: workbench image that installs `@pulumi/mcp-server`.
- MCP-facing config and docs such as `universal-workbench-docker/README.md` and client defaults that point agents at these tools.

## Runtime conventions
- HTTP-exposed MCP services in this repo normally listen through `mcp-proxy` on port `8080`.
- The shell MCP entrypoint is `/usr/local/bin/start-shell-mcp`; it passes through proxy env vars and can generate a fallback `mcp-shell` security config when `MCP_SHELL_SEC_CONFIG_FILE` is unset.
- `github-mcp-server-docker/` and `ansible-mcp-server-docker/` use `mcp-proxy` as the entrypoint and launch their server implementations over stdio behind it.
- `notebooklm-mcp-docker/` runs `notebooklm-mcp` directly and still tracks the universal workbench base tag through workflow resolution.
- `pulumi-workbench-docker/` bundles MCP tooling inside a broader workbench image rather than exposing a dedicated HTTP server by default.

## Workflow patterns
- Universal-workbench-based MCP images usually resolve `UNIVERSAL_WORKBENCH_TAG` via `.github/actions/resolve-ghcr-tag`.
- Standalone server images without upstream image dependencies can publish from `push` plus `workflow_dispatch` only, as `github-mcp-server-publish.yaml` does.
- Only add `build-contexts: shared=./shared` when the Dockerfile actually consumes repo helper scripts from `shared/`.
- When an MCP tool version changes, update the Dockerfile ARG/default, matching workflow `version`, and any emitted labels or README examples in the same change.

## Editing checklist
1. Update the nearest README or config example when runtime flags, env vars, ports, or security behavior change.
2. Keep AGENTS and the root image inventory aligned when adding or removing MCP-focused images.
3. Preserve `trigger-downstreams` only for workflows that actually emit follow-on `repository_dispatch` events.
