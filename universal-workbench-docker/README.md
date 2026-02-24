# Universal Workbench (MCP Shell Server)

This image is the shared base workbench used by downstream images in this repository. It also includes shell MCP tooling for exposing a constrained shell over HTTP:

- `mcp-proxy` (HTTP wrapper)
- `sonirico/mcp-shell` (Go MCP shell server)
- `start-shell-mcp` (repo wrapper script that wires envs + proxy)

## Build

Build the image from the repository root and include the `shared/` build context (required for helper scripts such as `start-shell-mcp`).

```bash
docker build \
  -f universal-workbench-docker/Dockerfile \
  --build-context shared=./shared \
  -t ghcr.io/example/universal-workbench:dev \
  .
```

## Run the MCP Shell Server

The recommended runtime is `start-shell-mcp`, which starts `mcp-proxy` and launches `mcp-shell` behind it.

```bash
docker run --rm -p 8080:8080 \
  -e MCP_SHELL_SEC_CONFIG_FILE=/etc/mcp-shell/security.yaml \
  -v "$PWD/mcp-shell-security.yaml:/etc/mcp-shell/security.yaml:ro" \
  ghcr.io/example/universal-workbench:dev \
  /usr/local/bin/start-shell-mcp
```

By default the wrapper listens on:

- host: `0.0.0.0`
- port: `8080`
- proxy allow-origin: `*`

## Security Configuration (`mcp-shell`)

`mcp-shell` security policy is configured with a YAML file referenced by `MCP_SHELL_SEC_CONFIG_FILE`.

### Minimal example

```yaml
security:
  enabled: true
  allowed_executables:
    - "pwd"
    - "ls"
  max_execution_time: 30s
  working_directory: /project
  max_output_size: 1048576
  audit_log: true
```

### Example with `blocked_patterns`

Use `blocked_patterns` to deny specific command forms even when the executable is allowed.

```yaml
security:
  enabled: true
  allowed_executables:
    - "git"
    - "ls"
  blocked_patterns:
    - 'git\s+push.*'
    - 'git\s+remote.*'
    - 'ls\s+.*-R.*'
  max_execution_time: 30s
  working_directory: /project
  max_output_size: 1048576
  audit_log: true
```

## Wrapper Environment Variables

### Proxy settings

- `MCP_PROXY_HOST` (default: `0.0.0.0`)
- `MCP_PROXY_PORT` (default: `8080`)
- `MCP_PROXY_ALLOW_ORIGIN` (default: `*`)
- `MCP_PROXY_BIN` (default: `/usr/local/bin/mcp-proxy`)

### Shell server binary

- `MCP_SHELL_SERVER_CMD` (default: `/usr/local/bin/mcp-shell`)

### Shell server logging

- `MCP_SHELL_LOG_LEVEL` (default: `info`) - `debug|info|warn|error|fatal`
- `MCP_SHELL_LOG_FORMAT` (default: `json`) - `json|console`
- `MCP_SHELL_LOG_OUTPUT` (default: `stderr`) - `stdout|stderr|file`

### Security config file (recommended)

- `MCP_SHELL_SEC_CONFIG_FILE` - path to the `mcp-shell` YAML security config

### Fallback generated security config (for quick tests)

If `MCP_SHELL_SEC_CONFIG_FILE` is not set, `start-shell-mcp` generates a fallback config. These envs control it:

- `MCP_SHELL_ALLOWED_EXECUTABLES_CSV` (comma-separated)
- `MCP_SHELL_BLOCKED_PATTERNS_CSV` (comma-separated regex patterns)
- `MCP_SHELL_MAX_EXECUTION_TIME`
- `MCP_SHELL_WORKING_DIRECTORY`
- `MCP_SHELL_MAX_OUTPUT_SIZE`
- `MCP_SHELL_AUDIT_LOG`

Example:

```bash
docker run --rm -p 8080:8080 \
  -e MCP_SHELL_ALLOWED_EXECUTABLES_CSV="git,ls,pwd" \
  -e MCP_SHELL_BLOCKED_PATTERNS_CSV="git\\s+push.*,git\\s+remote.*" \
  -e MCP_SHELL_WORKING_DIRECTORY="/project" \
  ghcr.io/example/universal-workbench:dev \
  /usr/local/bin/start-shell-mcp
```

## Notes and Behavior

- Secure mode blocks shell metacharacters such as `&&` and `||`.
- Allowlist checks apply to the executable (`allowed_executables`), not arbitrary command strings.
- `blocked_patterns` can be used to deny expensive or risky argument patterns.

## Codex Client Example (`.codex/config.toml`)

When connecting from Codex to an HTTP MCP endpoint exposed by `mcp-proxy`, a repo-local config may look like:

```toml
experimental_use_rmcp_client = true

[mcp_servers.universal_shell]
url = "http://localhost:8080/mcp"
enabled = true
startup_timeout_sec = 20
tool_timeout_sec = 120
```
