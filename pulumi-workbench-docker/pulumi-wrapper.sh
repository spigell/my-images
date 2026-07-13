#!/usr/bin/env bash
set -euo pipefail

readonly PULUMI_REAL_BIN=/usr/local/pulumi/pulumi
readonly PULUMI_FAIL_FAST_PRELOAD=/usr/local/lib/pulumi-fail-fast.mjs
readonly preload_option="--import=${PULUMI_FAIL_FAST_PRELOAD}"

if [[ " ${NODE_OPTIONS:-} " != *" ${preload_option} "* ]]; then
  export NODE_OPTIONS="${NODE_OPTIONS:+${NODE_OPTIONS} }${preload_option}"
fi

exec "${PULUMI_REAL_BIN}" "$@"
