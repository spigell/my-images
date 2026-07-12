# Pulumi Workbench

This image provides the Pulumi CLI, `pulumictl`, `kubectl`, and the Pulumi MCP server package.

## Fail-fast Node diagnostics

`/usr/local/bin/pulumi` is a wrapper around the real CLI at `/usr/local/pulumi/pulumi`. The wrapper adds the image-managed Node preload at `/usr/local/lib/pulumi-fail-fast.mjs` through `NODE_OPTIONS` before starting Pulumi.

The preload applies to Node.js Pulumi language processes launched by the CLI. On the first uncaught exception or unhandled rejection, it writes the original error and stack directly to stderr and exits with Pulumi's user-actionable-message code `32`. This prevents secondary diagnostic failures from obscuring the original program error or exhausting the container memory.

Projects do not need to import a helper or add `nodeargs` to `Pulumi.yaml`. Direct shell and MCP `pulumi` commands both resolve the same wrapper through `PATH`.

The wrapper preserves existing `NODE_OPTIONS` and adds the preload only once. It invokes the real CLI by absolute path to avoid recursion.
