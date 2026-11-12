// R51 browser-check contract: run explicitly, bind displayed data, reject drift.
// This tests the UI execution behavior. Historical scientific verifiers are unchanged.
'use strict';
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const implementation = fs.readFileSync(path.join(root, 'exact/exact-reader.js'), 'utf8');
const registry = JSON.parse(fs.readFileSync(path.join(root, 'exact/read-registry.json'), 'utf8'));
const record = registry.records.find((item) => item.id === 'CA-ALG-001');
assert.equal(crypto.createHash('sha256').update(implementation).digest('hex'), record.procedure.implementation_sha256);
const matrixText = (matrix) => `[[${matrix[0].join(', ')}], [${matrix[1].join(', ')}]]`;
const declared = `G = [Q, Ω] = ${matrixText(record.output.G)}\nG² = ${matrixText(record.output.G_squared)}\ntr(G) = ${record.output.trace_G}\ndet(G) = ${record.output.determinant_G}`;

for (const page of ['exact/index.html', 'exact/matrix-root-g-001/index.html']) {
  const html = fs.readFileSync(path.join(root, page), 'utf8');
  const text = (attribute) => {
    const match = html.match(new RegExp(`<[^>]*\\b${attribute}(?=[\\s=>])[^>]*>([^<]*)<`));
    assert.ok(match, `Missing ${attribute}: ${page}`);
    return match[1].trim();
  };
  assert.equal(text('data-exact-expected'), declared);
  assert.deepEqual(JSON.parse(text('data-input-q')), record.input.Q);
  assert.deepEqual(JSON.parse(text('data-input-omega')), record.input.Omega);
  const elements = {
    '[data-input-q]': {textContent: text('data-input-q')},
    '[data-input-omega]': {textContent: text('data-input-omega')},
    '[data-exact-expected]': {textContent: text('data-exact-expected')},
    '[data-exact-output]': {textContent: text('data-exact-output')},
    '[data-exact-status]': {textContent: text('data-exact-status'), classList: {toggle() {}}},
    '[data-exact-recompute]': {addEventListener(type, callback) {assert.equal(type, 'click'); this.run = callback;}}
  };
  const document = {
    querySelector: (selector) => elements[selector],
    addEventListener(event, callback) {assert.equal(event, 'DOMContentLoaded'); callback();}
  };
  vm.runInNewContext(implementation, {document});
  assert.equal(elements['[data-exact-status]'].textContent, 'Execution status: ready.');
  const run = () => elements['[data-exact-recompute]'].run();
  const status = () => elements['[data-exact-status]'].textContent;
  run(); assert.equal(elements['[data-exact-output]'].textContent, declared); assert.match(status(), /^PASS/);
  elements['[data-exact-expected]'].textContent = declared.replace('det(G) = -5', 'det(G) = -4');
  run(); assert.match(status(), /^FAIL/);
  elements['[data-exact-expected]'].textContent = declared;
  elements['[data-input-q]'].textContent = '[[2,1],[1,0]]';
  run(); assert.match(status(), /^FAIL/);
  elements['[data-input-q]'].textContent = 'malformed';
  run(); assert.match(status(), /^FAIL/);
  elements['[data-input-q]'].textContent = JSON.stringify(record.input.Q);
  run(); assert.match(status(), /^PASS/);
  console.log(`PASS ${page}: static/registry agreement, ready before activation, exact output, three rejected faults, restored reference.`);
}
