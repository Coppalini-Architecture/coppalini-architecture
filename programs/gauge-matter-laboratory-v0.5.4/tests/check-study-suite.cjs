'use strict';

/* The study documents are isolated with iframe srcdoc.  Parse every
 * executable inline script at build time so a syntax error cannot hide behind
 * the primary laboratory bootstrap. */
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { resolve } = require('node:path');

const root = resolve(__dirname, '..');
const studies = [
  'lambda-mirror.html',
  'phi4-domain-study.html',
  'hydrogen-orbital-ladder.html',
  'helium-dynamics.html',
  'water-field.html'
];

function executableScripts(markup) {
  return [...markup.matchAll(/<script([^>]*)>([\s\S]*?)<\/script>/gi)]
    .filter(([, attributes]) => !/type\s*=\s*["'](?:application\/json|application\/ld\+json)["']/i.test(attributes))
    .map(([, , source]) => source);
}

const parsed = [];
for (const name of studies) {
  const markup = readFileSync(resolve(root, 'studies', name), 'utf8');
  const scripts = executableScripts(markup);
  assert.ok(scripts.length > 0, `${name} supplies an executable reader`);
  for (const source of scripts) new Function(source);
  parsed.push([name, scripts.length]);
}

const phi4 = readFileSync(resolve(root, 'studies', 'phi4-domain-study.html'), 'utf8');
for (const required of [
  'reflectedSector',
  'field.map(value => -value)',
  'λₘᵢₙ(Lₕ) − λv²',
  'Quadratic test degenerate',
  'Gradient residual (max)',
  'Hessian residual (max entry)'
]) assert.ok(phi4.includes(required), `Φ⁴ study retains ${required}`);

const lambdaMirror = readFileSync(resolve(root, 'studies', 'lambda-mirror.html'), 'utf8');
assert.ok(lambdaMirror.includes('registry reflection') && lambdaMirror.includes('have distinct carriers'), 'Λ mirror keeps its carrier distinction');

console.log(JSON.stringify({ studySuite: Object.fromEntries(parsed) }, null, 2));
