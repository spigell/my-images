#!/usr/bin/env bash
set -euo pipefail

bundle_dir="$(yarn global dir)/node_modules/@google/gemini-cli/bundle"

if [[ ! -d "${bundle_dir}" ]]; then
  echo "gemini-cli bundle directory not found: ${bundle_dir}" >&2
  exit 1
fi

node - <<'NODE' "${bundle_dir}"
const fs = require('node:fs');
const path = require('node:path');

const bundleDir = process.argv[2];
const files = fs
  .readdirSync(bundleDir)
  .filter((name) => /^chunk-.*\.js$/.test(name));

const oldSnippet =
  'const chainKey = previewEnabled ? "preview" : "default";\n' +
  '        chain2 = config2.modelConfigService.resolveChain(chainKey, context2);';

const newSnippet =
  'const modelChainKey = isProModel(resolvedModel, config2) ? "pro" : resolvedModel.includes("flash") && !resolvedModel.includes("flash-lite") ? "flash" : void 0;\n' +
  '        if (modelChainKey && config2.modelConfigService.getModelChain(modelChainKey)) {\n' +
  '          chain2 = config2.modelConfigService.resolveChain(modelChainKey, context2);\n' +
  '        }\n' +
  '        if (!chain2) {\n' +
  '          const chainKey = previewEnabled ? "preview" : "default";\n' +
  '          chain2 = config2.modelConfigService.resolveChain(chainKey, context2);\n' +
  '        }';

const fallbackOldSnippet = 'const chain2 = resolvePolicyChain(config2);';
const fallbackNewSnippet =
  "const chain2 = resolvePolicyChain(config2, failedModel, true);";

let routingReplacements = 0;
let fallbackReplacements = 0;

for (const file of files) {
  const fullPath = path.join(bundleDir, file);
  const source = fs.readFileSync(fullPath, 'utf8');
  let nextSource = source;

  if (!nextSource.includes(newSnippet) && nextSource.includes(oldSnippet)) {
    nextSource = nextSource.replace(oldSnippet, newSnippet);
    routingReplacements += 1;
  }

  if (
    !nextSource.includes(fallbackNewSnippet) &&
    nextSource.includes(fallbackOldSnippet)
  ) {
    nextSource = nextSource.replace(fallbackOldSnippet, fallbackNewSnippet);
    fallbackReplacements += 1;
  }

  if (nextSource !== source) {
    fs.writeFileSync(fullPath, nextSource, 'utf8');
  }
}

if (routingReplacements === 0) {
  throw new Error('No routing chunks were patched');
}

if (fallbackReplacements === 0) {
  throw new Error('No fallback chunks were patched');
}

console.log(
  `Patched routing in ${routingReplacements} chunk file(s) and fallback in ${fallbackReplacements} chunk file(s)`,
);
NODE
