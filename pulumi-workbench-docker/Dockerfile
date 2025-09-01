FROM pulumi/pulumi:3.192.0

ARG PULUMICTL_VERSION=0.0.46
ARG DELVE_VERSION=v1.24.2
ARG GOLANGCI_LINT_VERSION=2.1.6

# Install dependencies
RUN apt-get update && \
    apt-get install -y vim curl tar sudo bash-completion make kubectl iproute2 rsync && \
    go install github.com/go-delve/delve/cmd/dlv@${DELVE_VERSION} && \
    mv /go/bin/dlv /usr/local/bin/dlv && \
    curl -Lo pulumictl.tar.gz https://github.com/pulumi/pulumictl/releases/download/v${PULUMICTL_VERSION}/pulumictl-v${PULUMICTL_VERSION}-linux-amd64.tar.gz && \
    tar -xzf pulumictl.tar.gz && \
    mv pulumictl /usr/local/bin/pulumictl && \
    rm pulumictl.tar.gz && \
    curl -Lo golangci-lint.deb https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64.deb && \
    dpkg -i golangci-lint.deb || apt-get install -f -y && \
    rm golangci-lint.deb && \
    rm -rf /var/lib/apt/lists/*
