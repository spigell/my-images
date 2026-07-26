# Ansible MCP Server

This image builds the Ansible MCP server from the pinned `vscode-ansible`
source and exposes it over HTTP through `mcp-proxy`.

The image applies a local patch that adds `workingDirectory` to the
`ansible_navigator` tool. The value selects the Ansible project used to:

- resolve relative playbook paths;
- discover project-local virtual environments;
- set the `cwd` of the `ansible-navigator` process.

`workingDirectory` must resolve inside `WORKSPACE_ROOT`. Set
`WORKSPACE_ROOT` to the common read-only or writable workspace boundary, then
provide the specific Ansible project directory on every execution call. Do not
set a global `ANSIBLE_CONFIG` when the server is expected to run projects with
different `ansible.cfg` files.
