# agy-docker

This image layers the Antigravity CLI (`agy`) on top of
`ghcr.io/spigell/universal-workbench`.

## What the upstream installer does

The published installer at `https://antigravity.google/cli/install.sh`:

1. Detects OS and architecture, including `musl` vs `glibc` on Linux.
2. Fetches a platform manifest from the Antigravity release service.
3. Downloads the referenced payload and verifies its SHA-512 checksum.
4. Extracts the `antigravity` binary and installs it as `agy`.
5. Runs `agy install` to append a PATH export to shell profile files.

For container builds, this image keeps the artifact download and checksum
verification but skips shell-profile mutation. The binary is installed directly
to `/usr/local/bin/agy`, which is already on the workbench PATH.
