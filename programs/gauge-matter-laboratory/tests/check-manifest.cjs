'use strict';

const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { createHash } = require('node:crypto');
const { resolve } = require('node:path');

const root = resolve(__dirname, '..');
const manifest = JSON.parse(readFileSync(resolve(root, 'source-manifest.json'), 'utf8'));
assert.equal(manifest.version, '0.5.2');
assert.equal(manifest.entry, 'clear-onyx-gauge-laboratory-v0.5.2.html');
assert.ok(Array.isArray(manifest.files) && manifest.files.length >= 10, 'manifest has a complete source list');
for (const entry of manifest.files) {
  const bytes = readFileSync(resolve(root, entry.path));
  const actual = createHash('sha256').update(bytes).digest('hex');
  assert.equal(actual, entry.sha256, `sha256 ${entry.path}`);
}
console.log(JSON.stringify({ version: manifest.version, files: manifest.files.length, entry: manifest.entry }, null, 2));
