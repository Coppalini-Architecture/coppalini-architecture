'use strict';

/* Executes the built three-script page in a minimal browser-shaped realm.
 * It catches cross-script name failures and verifies the stripped reader has
 * no undeclared animation layer. */
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { resolve } = require('node:path');
const vm = require('node:vm');

const html = readFileSync(resolve(__dirname, '..', 'clear-onyx-gauge-laboratory-v0.5.5.html'), 'utf8');
assert.equal((html.match(/id="study-frame"/g) || []).length, 1, 'bundles one selected study frame');
assert.equal((html.match(/<iframe/g) || []).length, 1, 'does not instantiate parallel study frames');
assert.ok(html.includes('ClearOnyxStudyRegistry'), 'build embeds the declared study registry');
const parent = html;
const scripts = [...parent.matchAll(/<script>\s*([\s\S]*?)\s*<\/script>/g)].map((match) => match[1]);
assert.equal(scripts.length, 3, 'built page retains its three ordered scripts');

function context2d() { return { clearRect() {}, fillRect() {}, }; }
function element() {
  const listeners = new Map();
  return {
    listeners,
    value: '0', textContent: '', disabled: false, width: 640, height: 480,
    getContext: context2d,
    getBoundingClientRect: () => ({ width: 640, height: 480 }),
    addEventListener: (name, handler) => listeners.set(name, handler),
    setAttribute() {}
  };
}

const elements = new Map();
const getElement = (selector) => {
  if (!elements.has(selector)) elements.set(selector, element());
  return elements.get(selector);
};
let clock = 0;
const scheduled = [];
const realm = {
  console,
  performance: { now: () => clock },
  document: { body: { classList: { add() {}, remove() {}, toggle() {} } }, querySelector: getElement, createElement: () => element() },
  window: { devicePixelRatio: 1 },
  ResizeObserver: class { constructor() {} observe() {} },
  requestAnimationFrame: (frame) => { scheduled.push(frame); return scheduled.length; }
};
vm.createContext(realm);
for (const script of scripts) vm.runInContext(script, realm, { timeout: 1000 });

assert.equal(parent.includes('SleepReturn'), false, 'no reader-level sleep law is bundled');
assert.equal(parent.includes('id="sleep"'), false, 'no sleep control is rendered');
assert.equal(parent.includes('scope-overlay'), false, 'field guidance is outside the canvas frame');
assert.ok(parent.includes('scope-rail-top') && parent.includes('scope-rail-bottom'), 'top and bottom perimeter rails are rendered');
assert.ok(parent.includes('study:phi4-domain') && parent.includes('study:water'), 'selector exposes routed studies');
assert.equal((parent.match(/\bfillText\(/g) || []).length, 1, 'only the separate compass carries its numerical text read');
assert.ok(scheduled.length >= 1, 'application frame loop is scheduled');

console.log(JSON.stringify({ browserBootstrap: { scripts: scripts.length, sleepRemoved: true, fieldClear: true, studyMount: true } }, null, 2));
