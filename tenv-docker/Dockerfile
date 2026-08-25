# syntax=docker/dockerfile:1.26

ARG UNIVERSAL_WORKBENCH_IMAGE_TAG=sha-dev
ARG DEBIAN_IMAGE_TAG=bookworm-slim # renovate: datasource=docker depName=debian
ARG TENV_WORKBENCH_VERSION=v4.16
ARG TENV_VERSION=v4.15.1 # renovate: datasource=github-releases depName=tofuutils/tenv
ARG TERRAFORM_VERSION=1.15.1 # renovate: datasource=github-releases depName=hashicorp/terraform
ARG TERRAGRUNT_VERSION=1.0.2 # renovate: datasource=github-releases depName=gruntwork-io/terragrunt
ARG AWS_PROVIDER_VERSION=6.45.0 # renovate: datasource=github-releases depName=hashicorp/terraform-provider-aws
ARG VAULT_PROVIDER_VERSION=4.6.0 # renovate: datasource=github-releases depName=hashicorp/terraform-provider-vault
ARG TARGETARCH=amd64

FROM debian:${DEBIAN_IMAGE_TAG} AS fetch
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ARG TENV_VERSION
ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/fetch

RUN arch="${TARGETARCH:-amd64}"; \
    case "${arch}" in \
      amd64) tenv_arch="x86_64" ;; \
      arm64) tenv_arch="arm64" ;; \
      *) echo "Unsupported tenv architecture: ${arch}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o tenv.tar.gz \
      "https://github.com/tofuutils/tenv/releases/download/${TENV_VERSION}/tenv_${TENV_VERSION}_Linux_${tenv_arch}.tar.gz"; \
    tar -xzf tenv.tar.gz tenv terraform tofu terragrunt tf; \
    chmod +x tenv terraform tofu terragrunt tf; \
    rm -f tenv.tar.gz

FROM ghcr.io/spigell/universal-workbench:${UNIVERSAL_WORKBENCH_IMAGE_TAG}
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

USER root
ENV HOME=/root

ARG TENV_VERSION
ARG TERRAFORM_VERSION
ARG TERRAGRUNT_VERSION
ARG AWS_PROVIDER_VERSION
ARG VAULT_PROVIDER_VERSION
ARG UNIVERSAL_WORKBENCH_IMAGE_TAG
ARG TENV_WORKBENCH_VERSION

COPY --from=fetch /tmp/fetch/tenv /usr/local/bin/tenv
COPY --from=fetch /tmp/fetch/terraform /usr/local/bin/terraform
COPY --from=fetch /tmp/fetch/tofu /usr/local/bin/tofu
COPY --from=fetch /tmp/fetch/terragrunt /usr/local/bin/terragrunt
COPY --from=fetch /tmp/fetch/tf /usr/local/bin/tf

USER ubuntu
ENV HOME=/home/ubuntu
ENV TF_PLUGIN_CACHE_DIR=/home/ubuntu/.terraform.d/plugin-cache

RUN install -d "${TF_PLUGIN_CACHE_DIR}" \
    && tenv tf install "${TERRAFORM_VERSION}" \
    && tenv tf use "${TERRAFORM_VERSION}" \
    && tenv tg install "${TERRAGRUNT_VERSION}" \
    && tenv tg use "${TERRAGRUNT_VERSION}" \
    && terraform version \
    && terragrunt --version

RUN provider_config_dir="$(mktemp -d)" \
    && printf '%s\n' \
      'terraform {' \
      '  required_providers {' \
      '    aws = {' \
      '      source = "hashicorp/aws"' \
      "      version = \"${AWS_PROVIDER_VERSION}\"" \
      '    }' \
      '    vault = {' \
      '      source = "hashicorp/vault"' \
      "      version = \"${VAULT_PROVIDER_VERSION}\"" \
      '    }' \
      '  }' \
      '}' \
      > "${provider_config_dir}/providers.tf" \
    && terraform -chdir="${provider_config_dir}" init -backend=false -input=false \
    && rm -rf "${provider_config_dir}/.terraform" \
    && terraform -chdir="${provider_config_dir}" init -backend=false -input=false \
    && rm -rf "${provider_config_dir}"

LABEL org.opencontainers.image.title="tenv Workbench" \
      org.opencontainers.image.description="Universal workbench derivative with tenv-managed IaC CLIs" \
      org.opencontainers.image.version="${TENV_WORKBENCH_VERSION}" \
      org.opencontainers.image.source="https://github.com/spigell/my-images/tenv-docker" \
      com.spigell.workbench.base-image="universal-workbench" \
      com.spigell.workbench.base-image-tag="${UNIVERSAL_WORKBENCH_IMAGE_TAG}" \
      com.spigell.workbench.tenv.version="${TENV_VERSION}" \
      com.spigell.workbench.terraform.version="${TERRAFORM_VERSION}" \
      com.spigell.workbench.terragrunt.version="${TERRAGRUNT_VERSION}" \
      com.spigell.workbench.terraform-provider-aws.version="${AWS_PROVIDER_VERSION}" \
      com.spigell.workbench.terraform-provider-vault.version="${VAULT_PROVIDER_VERSION}"

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["terraform version && terragrunt --version"]
