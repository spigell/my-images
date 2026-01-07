#!/usr/bin/env bash
set -euo pipefail

# Wrapper to expose the shell MCP server over HTTP via mcp-proxy.

DEFAULT_ALLOWED_COMMANDS="ls,cat,pwd,grep,wc,touch,find"

if [[ -n "${ALLOWED_COMMANDS:-}" && -z "${ALLOW_COMMANDS:-}" ]]; then
  ALLOW_COMMANDS="${ALLOWED_COMMANDS}"
fi

if [[ -z "${ALLOW_COMMANDS:-}" && -z "${ALLOWED_COMMANDS:-}" ]]; then
  ALLOW_COMMANDS="${DEFAULT_ALLOWED_COMMANDS}"
fi

export ALLOW_COMMANDS
export ALLOWED_COMMANDS="${ALLOWED_COMMANDS:-${ALLOW_COMMANDS}}"

HOST="${MCP_PROXY_HOST:-0.0.0.0}"
PORT="${MCP_PROXY_PORT:-8080}"
ALLOW_ORIGIN="${MCP_PROXY_ALLOW_ORIGIN:-*}"
MCP_PROXY_BIN="${MCP_PROXY_BIN:-/usr/local/bin/mcp-proxy}"

server_cmd=("${MCP_SHELL_SERVER_CMD:-/usr/local/bin/mcp-shell-server}")
if [[ $# -gt 0 ]]; then
  server_cmd=("$@")
fi

exec "${MCP_PROXY_BIN}" \
  --host="${HOST}" \
  --port="${PORT}" \
  --allow-origin="${ALLOW_ORIGIN}" \
  --pass-environment \
  -- \
  "${server_cmd[@]}"
