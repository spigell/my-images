#!/usr/bin/env bash
set -euo pipefail

trim() {
  local var="$*"
  var="${var#"${var%%[![:space:]]*}"}"
  var="${var%"${var##*[![:space:]]}"}"
  printf '%s' "${var}"
}

# Wrapper to expose the shell MCP server over HTTP via mcp-proxy.
# `sonirico/mcp-shell` is configured via `MCP_SHELL_SEC_CONFIG_FILE`.
# If not provided, generate a sane default config with a minimal allowlist.

# Hardcoded defaults for generated fallback config.
MCP_SHELL_DEFAULT_ALLOWED_EXECUTABLES=(
  ls
  cat
  pwd
  grep
  wc
  touch
  find
)
MCP_SHELL_DEFAULT_BLOCKED_PATTERNS=()
MCP_SHELL_DEFAULT_MAX_EXECUTION_TIME="30s"
MCP_SHELL_DEFAULT_WORKING_DIRECTORY="/project"
MCP_SHELL_DEFAULT_MAX_OUTPUT_SIZE="1048576"
MCP_SHELL_DEFAULT_AUDIT_LOG="true"

# Effective values (defaults overridden via env when fallback config is generated).
MCP_SHELL_ALLOWED_EXECUTABLES_CSV="${MCP_SHELL_ALLOWED_EXECUTABLES_CSV:-}"
MCP_SHELL_BLOCKED_PATTERNS_CSV="${MCP_SHELL_BLOCKED_PATTERNS_CSV:-}"
MCP_SHELL_MAX_EXECUTION_TIME="${MCP_SHELL_MAX_EXECUTION_TIME:-${MCP_SHELL_DEFAULT_MAX_EXECUTION_TIME}}"
MCP_SHELL_WORKING_DIRECTORY="${MCP_SHELL_WORKING_DIRECTORY:-${MCP_SHELL_DEFAULT_WORKING_DIRECTORY}}"
MCP_SHELL_MAX_OUTPUT_SIZE="${MCP_SHELL_MAX_OUTPUT_SIZE:-${MCP_SHELL_DEFAULT_MAX_OUTPUT_SIZE}}"
MCP_SHELL_AUDIT_LOG="${MCP_SHELL_AUDIT_LOG:-${MCP_SHELL_DEFAULT_AUDIT_LOG}}"

HOST="${MCP_PROXY_HOST:-0.0.0.0}"
PORT="${MCP_PROXY_PORT:-8080}"
ALLOW_ORIGIN="${MCP_PROXY_ALLOW_ORIGIN:-*}"
MCP_PROXY_BIN="${MCP_PROXY_BIN:-/usr/local/bin/mcp-proxy}"
MCP_SHELL_LOG_LEVEL="${MCP_SHELL_LOG_LEVEL:-info}"
MCP_SHELL_LOG_FORMAT="${MCP_SHELL_LOG_FORMAT:-json}"
MCP_SHELL_LOG_OUTPUT="${MCP_SHELL_LOG_OUTPUT:-stderr}"

export MCP_SHELL_LOG_LEVEL
export MCP_SHELL_LOG_FORMAT
export MCP_SHELL_LOG_OUTPUT

server_cmd=("${MCP_SHELL_SERVER_CMD:-/usr/local/bin/mcp-shell}")
if [[ $# -gt 0 ]]; then
  server_cmd=("$@")
fi

if [[ -z "${MCP_SHELL_SEC_CONFIG_FILE:-}" ]]; then
  sec_cfg="$(mktemp /tmp/mcp-shell-security.default.XXXXXX.yaml)"
  {
    echo "security:"
    echo "  enabled: true"
    echo "  allowed_executables:"
    if [[ -n "${MCP_SHELL_ALLOWED_EXECUTABLES_CSV}" ]]; then
      IFS=',' read -r -a _mcp_allowed_execs <<< "${MCP_SHELL_ALLOWED_EXECUTABLES_CSV}"
      for raw_exec in "${_mcp_allowed_execs[@]}"; do
        exec_name="$(trim "${raw_exec}")"
        [[ -n "${exec_name}" ]] || continue
        printf '    - "%s"\n' "${exec_name//\"/\\\"}"
      done
    else
      for exec_name in "${MCP_SHELL_DEFAULT_ALLOWED_EXECUTABLES[@]}"; do
        printf '    - "%s"\n' "${exec_name}"
      done
    fi
    if [[ -n "${MCP_SHELL_BLOCKED_PATTERNS_CSV}" ]]; then
      echo "  blocked_patterns:"
      IFS=',' read -r -a _mcp_blocked_patterns <<< "${MCP_SHELL_BLOCKED_PATTERNS_CSV}"
      for raw_pattern in "${_mcp_blocked_patterns[@]}"; do
        pattern="$(trim "${raw_pattern}")"
        [[ -n "${pattern}" ]] || continue
        printf "    - '%s'\n" "${pattern//\'/''}"
      done
    elif ((${#MCP_SHELL_DEFAULT_BLOCKED_PATTERNS[@]} > 0)); then
      echo "  blocked_patterns:"
      for pattern in "${MCP_SHELL_DEFAULT_BLOCKED_PATTERNS[@]}"; do
        printf "    - '%s'\n" "${pattern//\'/''}"
      done
    fi
    echo "  max_execution_time: ${MCP_SHELL_MAX_EXECUTION_TIME}"
    echo "  working_directory: ${MCP_SHELL_WORKING_DIRECTORY}"
    echo "  max_output_size: ${MCP_SHELL_MAX_OUTPUT_SIZE}"
    echo "  audit_log: ${MCP_SHELL_AUDIT_LOG}"
  } > "${sec_cfg}"
  export MCP_SHELL_SEC_CONFIG_FILE="${sec_cfg}"
fi

exec "${MCP_PROXY_BIN}" \
  --host="${HOST}" \
  --port="${PORT}" \
  --allow-origin="${ALLOW_ORIGIN}" \
  --pass-environment \
  -- \
  "${server_cmd[@]}"
