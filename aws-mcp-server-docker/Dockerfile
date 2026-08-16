# syntax=docker/dockerfile:1.26

ARG UNIVERSAL_WORKBENCH_IMAGE_TAG=sha-dev
ARG AWS_EKS_MCP_VERSION=0.1.35 # renovate: datasource=pypi depName=awslabs.eks-mcp-server
ARG AWS_PRICING_MCP_VERSION=1.0.32 # renovate: datasource=pypi depName=awslabs.aws-pricing-mcp-server

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_IMAGE_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG UNIVERSAL_WORKBENCH_IMAGE_TAG
ARG AWS_EKS_MCP_VERSION
ARG AWS_PRICING_MCP_VERSION

RUN UV_PYTHON_INSTALL_DIR=/usr/local/share/uv-python \
    XDG_DATA_HOME=/usr/local/share/uv-data \
    XDG_BIN_HOME=/usr/local/bin \
    uv tool install "awslabs.eks-mcp-server==${AWS_EKS_MCP_VERSION}" \
    && UV_PYTHON_INSTALL_DIR=/usr/local/share/uv-python \
       XDG_DATA_HOME=/usr/local/share/uv-data \
       XDG_BIN_HOME=/usr/local/bin \
       uv tool install "awslabs.aws-pricing-mcp-server==${AWS_PRICING_MCP_VERSION}" \
    && test -x /usr/local/bin/awslabs.eks-mcp-server \
    && test -x /usr/local/bin/awslabs.aws-pricing-mcp-server

ENV MCP_PROXY_HOST=0.0.0.0 \
    MCP_PROXY_PORT=8080 \
    MCP_PROXY_ALLOW_ORIGIN=*

EXPOSE 8080

LABEL org.opencontainers.image.title="AWS MCP Server" \
      org.opencontainers.image.description="Shared AWS EKS and Pricing MCP server runtime built on the universal workbench" \
      org.opencontainers.image.version="eks-${AWS_EKS_MCP_VERSION}-pricing-${AWS_PRICING_MCP_VERSION}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/aws-mcp-server-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_IMAGE_TAG}" \
      com.spigell.aws-mcp.eks.version="${AWS_EKS_MCP_VERSION}" \
      com.spigell.aws-mcp.pricing.version="${AWS_PRICING_MCP_VERSION}"

USER ubuntu
ENV HOME=/home/ubuntu

ENTRYPOINT ["/usr/local/bin/start-shell-mcp"]
CMD ["/usr/local/bin/awslabs.eks-mcp-server"]
