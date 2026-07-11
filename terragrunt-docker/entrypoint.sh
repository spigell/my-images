#!/usr/bin/env bash
set -euo pipefail

install_requested_version() {
  local tool="$1"
  local version="$2"

  if [[ -n "${version}" ]]; then
    tenv "${tool}" install "${version}"
  fi
}

install_requested_version tf "${TFENV_TERRAFORM_VERSION:-}"
install_requested_version tofu "${TOFUENV_TOFU_VERSION:-}"
install_requested_version tg "${TG_VERSION:-}"

exec "$@"
