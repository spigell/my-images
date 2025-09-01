FROM ghcr.io/spigell/pulumi-workbench:3.192.0

ARG K9S_VERSION=0.32.5
ARG TALOSCTL_VERSION=1.8.2

# Install dependencies
RUN curl -Lo k9s.deb https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_linux_amd64.deb && \
    dpkg -i k9s.deb || apt-get install -f -y && \
    rm k9s.deb && \
    curl -Lo talosctl https://github.com/siderolabs/talos/releases/download/v${TALOSCTL_VERSION}/talosctl-linux-amd64 && \
    chmod +x talosctl && mv talosctl /usr/local/bin/talosctl
