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

let replacements = 0;

for (const file of files) {
  const fullPath = path.join(bundleDir, file);
  const source = fs.readFileSync(fullPath, 'utf8');
  if (source.includes(newSnippet)) {
    continue;
  }
  if (!source.includes(oldSnippet)) {
    continue;
  }
  fs.writeFileSync(fullPath, source.replace(oldSnippet, newSnippet), 'utf8');
  replacements += 1;
}

if (replacements === 0) {
  throw new Error('No routing chunks were patched');
}

console.log(`Patched ${replacements} gemini-cli chunk file(s)`);
NODE
