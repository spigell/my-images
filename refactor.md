### Plan: Unified Workbench Image

This plan outlines a multi-stage approach to building a single Docker image containing all your specified runtimes and tools.

**1. Create a New Directory Structure:**

First, create a new directory to house your unified Dockerfile and installation scripts. This will keep your project organized.

```bash
mkdir -p unified-workbench/scripts
```

**2. Create a Base Dockerfile:**

Create a file named `unified-workbench/Dockerfile` that will define your new image. This Dockerfile will be a multi-stage build. The first stage will be the `base` with all the runtimes.

**`unified-workbench/Dockerfile` (Initial Base Stage):**
```dockerfile
# Stage 1: Base Image with Runtimes
FROM ubuntu:22.04 as base

# Install essential dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN curl -OL https://golang.org/dl/go1.19.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz \
    && rm go1.19.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Node.js (for TypeScript)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Install Python
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*
```

**3. Create Tool Installation Scripts:**

For each tool, create a dedicated installation script in the `unified-workbench/scripts/` directory. This makes the main Dockerfile cleaner and the installation of each tool modular.

**`unified-workbench/scripts/install_pulumi.sh`:**
```bash
#!/bin/bash
curl -fsSL https://get.pulumi.com | sh
```

**`unified-workbench/scripts/install_gemini.sh`:**
```bash
#!/bin/bash
# Add Gemini installation commands here.
# You would source these from your existing google-gemini-docker/Dockerfile
echo "Installing Gemini..."
```

**`unified-workbench/scripts/install_codex.sh`:**
```bash
#!/bin/bash
# Add Codex installation commands here.
# You would source these from your existing openai-codex-docker/Dockerfile
echo "Installing Codex..."
```

Make these scripts executable:

```bash
chmod +x unified-workbench/scripts/*.sh
```

**4. Extend the Main Dockerfile for Tools:**

Now, extend the `unified-workbench/Dockerfile` to include a new stage that builds on the `base` and runs the installation scripts.

**`unified-workbench/Dockerfile` (Full Version):**
```dockerfile
# Stage 1: Base Image with Runtimes
FROM ubuntu:22.04 as base

# Install essential dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN curl -OL https://golang.org/dl/go1.19.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz \
    && rm go1.19.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Node.js (for TypeScript)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Install Python
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*

# Stage 2: Final Image with Tools
FROM base as final

# Copy and run installation scripts
COPY ./scripts/ /tmp/scripts/
RUN /tmp/scripts/install_pulumi.sh
RUN /tmp/scripts/install_gemini.sh
RUN /tmp/scripts/install_codex.sh

# Set the entrypoint or default command
CMD ["/bin/bash"]
```

**5. Build the Image:**

You can now build your unified workbench image with a single command from the root of your project.

```bash
docker build -t unified-workbench:latest ./unified-workbench
```

This plan provides a clear path to creating a single, well-organized, and maintainable Docker image for your workbenches. You can adapt the installation scripts and Dockerfile as needed for your specific versions and configurations.

