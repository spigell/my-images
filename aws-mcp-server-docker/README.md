# AWS MCP Server Image

This shared image preinstalls the pinned AWS Labs EKS and Pricing MCP servers.
It exposes the selected stdio server over streamable HTTP using the universal
workbench's `start-shell-mcp` wrapper and `mcp-proxy`.

The EKS server is the default:

```bash
docker run --rm -p 8080:8080 \
  -e AWS_REGION=eu-central-1 \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  ghcr.io/spigell/aws-mcp-server:eks-0.1.35-pricing-1.0.32
```

Select the Pricing server by replacing the image command:

```bash
docker run --rm -p 8080:8080 \
  -e AWS_REGION=eu-central-1 \
  ghcr.io/spigell/aws-mcp-server:eks-0.1.35-pricing-1.0.32 \
  /usr/local/bin/awslabs.aws-pricing-mcp-server
```

Both packages are installed during the image build. Container startup does not
contact PyPI. Override `MCP_PROXY_PORT` when the service must listen on a port
other than `8080`.

## Renovation policy

The Dockerfile arguments are the source of truth for both package versions.
The publish workflow derives the image tag from those arguments, so each
Renovate update produces a new compound tag. Renovate groups the two packages,
waits seven days after release, runs weekly, and never automerges the update.
