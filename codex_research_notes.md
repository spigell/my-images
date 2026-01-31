# Research Notes: Codex 0.93 MCP Approval Policy

## Summary
The goal was to identify the new approval mechanism for MCP (Model Context Protocol) calls in Codex 0.93.

## Findings
1.  **New Experimental Features**:
    -   Codex 0.93 introduces `mcp` and `mcp-server` commands.
    -   These commands are marked as `[experimental]` in the help output.

2.  **Approval Policy**:
    -   The existing `approval_policy` configuration key in `config.toml` (or via `--ask-for-approval` CLI flag) appears to be the primary mechanism for controlling execution approvals.
    -   Possible values are `untrusted`, `on-failure`, `on-request`, and `never`.
    -   There is no separate `mcp_approval_policy` or similar specific flag found in the CLI help or binary strings.

3.  **Binary Analysis**:
    -   Strings such as `ExecApproval`, `ExecPolicyAmendment`, `McpToolCall`, and `RequestListMcpTools` were found in the binary.
    -   The `exec_policy` feature flag is enabled by default (`true`).
    -   `skill_mcp_dependency_install` is also enabled by default.

## Conclusion
It is highly likely that MCP calls are governed by the general `approval_policy` or the `exec_policy` feature. No specific new configuration key was found. The current configuration `approval_policy = "on-failure"` in `openai-codex-docker/config/config.toml` remains valid and likely applies to MCP tool execution as well.
