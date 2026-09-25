# agent-usage-proxy

A `scratch` image that carries `agent-usage-proxy` from
[`spigell/my-nodejs-libs`](https://github.com/spigell/my-nodejs-libs), built
from the git tag pinned by `MY_NODEJS_LIBS_TAG`. It is not runnable on its own
because it ships no Node. The Claude, Codex, and agy workbench images copy it
in, the same way they consume `codex-binary` and `zmx-binary`:

```dockerfile
ARG AGENT_USAGE_PROXY_IMAGE=ghcr.io/spigell/agent-usage-proxy
ARG AGENT_USAGE_PROXY_IMAGE_TAG=sha-dev
FROM ${AGENT_USAGE_PROXY_IMAGE}:${AGENT_USAGE_PROXY_IMAGE_TAG} AS agent-usage-proxy

COPY --from=agent-usage-proxy /opt/agent-usage-proxy /opt/agent-usage-proxy
COPY --from=agent-usage-proxy /usr/local/bin/agent-usage-proxy /usr/local/bin/agent-usage-proxy
```

Contents:

| Path                                  | What                                          |
| ------------------------------------- | --------------------------------------------- |
| `/opt/agent-usage-proxy`              | `package.json`, `dist/`, production `node_modules` |
| `/usr/local/bin/agent-usage-proxy`    | Wrapper running the bin on the image's `node` |

Deployments run it as a sidecar from the agent's own image, with the agent home
mounted writable:

```bash
USAGE_AGENT=codex CODEX_HOME=/home/ubuntu/.codex PORT=8080 agent-usage-proxy
```

It serves `GET /usage` and polls in the background so the Claude and Codex OAuth
tokens keep rotating. See the library README for configuration and metrics.

## Node version

The pruned `node_modules` is built on `node:${NODE_IMAGE_TAG}` and executed on
the workbench's Node from `universal-workbench`. Keep `NODE_IMAGE_TAG` on the
same major as that image's `NODE_VERSION`.

## Releases

1. Bump `version` in `my-nodejs-libs/package.json`, then push a `vX.Y.Z` tag on
   `main`. The build fetches the tag from GitHub, so it must exist first.
2. Bump `MY_NODEJS_LIBS_TAG` here and `version` in
   `.github/workflows/agent-usage-proxy-publish.yaml`.
3. The publish workflow dispatches `agent-usage-proxy-updated`, which rebuilds
   the three agent workbench images.
