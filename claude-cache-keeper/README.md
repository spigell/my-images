# claude-cache-keeper

A `busybox` image that carries `claude-cache-keeper` from
[`spigell/my-nodejs-libs`](https://github.com/spigell/my-nodejs-libs), built
from the git tag pinned by `MY_NODEJS_LIBS_TAG`. It keeps the prompt cache of
idle Claude Code zmx sessions warm.

Unlike `agent-usage-proxy`, it is not baked into the workbench images. A pod
copies it in with an init container and runs it in a sidecar on the Claude
workbench image's own Node and `zmx`, so a keeper release never rebuilds a
workbench image and the keeper always uses the zmx the sessions run under:

```yaml
initContainers:
  - name: cache-keeper-install
    image: ghcr.io/spigell/claude-cache-keeper:<tag>@sha256:<digest>
    command: [cp, -a, /opt/claude-cache-keeper/., /cache-keeper/]
    volumeMounts:
      - { name: cache-keeper, mountPath: /cache-keeper }
containers:
  - name: cache-keeper
    image: <the pod's Claude workbench image>
    command: [node, /cache-keeper/dist/bin/claude-cache-keeper.js, watch, --min-context, "100000", --max-idle, "15"]
    volumeMounts:
      - { name: cache-keeper, mountPath: /cache-keeper, readOnly: true }
      - { name: agent-home, mountPath: /home/ubuntu/.claude }
      - { name: tmp, mountPath: /tmp } # the zmx sockets
volumes:
  - { name: cache-keeper, emptyDir: {} }
```

Contents:

| Path                       | What                                                        |
| -------------------------- | ----------------------------------------------------------- |
| `/opt/claude-cache-keeper` | `package.json` and the two compiled modules; no dependencies |

The sessions' instructions must tell Claude to answer a `[keepalive]` message
with `ok` only. See the library README for settings.

## Releases

1. Bump `version` in `my-nodejs-libs/package.json`, then push a `vX.Y.Z` tag on
   `main`. The build fetches the tag from GitHub, so it must exist first.
2. Bump `MY_NODEJS_LIBS_TAG` here and `version` in
   `.github/workflows/claude-cache-keeper-publish.yaml`.
3. Renovate bumps the image pin in the deployments (spigell `my-agents`
   Pulumi config, schukh `my-work-agents` Ansible vars).
