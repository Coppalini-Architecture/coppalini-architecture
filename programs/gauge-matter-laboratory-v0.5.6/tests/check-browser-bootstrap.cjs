'use strict';

/* Executes the built three-script page in a minimal browser-shaped realm.
 * It catches cross-script name failures and verifies the stripped reader has
 * no undeclared animation layer. */
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { resolve } = require('node:path');
const vm = require('node:vm');

const html = readFileSync(resolve(__dirname, '..', 'clear-onyx-gauge-laboratory-v0.5.6.html'), 'utf8');
assert.equal((html.match(/id="study-frame"/g) || []).length, 1, 'bundles one selected study frame');
assert.equal((html.match(/<iframe/g) || []).length, 1, 'does not instantiate parallel study frames');
assert.ok(html.includes('ClearOnyxStudyRegistry'), 'build embeds the declared study registry');
for (const id of ['signal-carrier', 'signal-colour', 'signal-meaning', 'signal-memory', 'signal-motion', 'signal-check', 'signal-scope']) assert.ok(html.includes(`id="${id}"`), `signal frame includes ${id}`);
assert.equal(html.includes('OPEN visual study · declared finite reader · no admitted main-carrier PASS'), false, 'study rail uses the declared signal contract');
const parent = html;
const scripts = [...parent.matchAll(/<script>\s*([\s\S]*?)\s*<\/script>/g)].map((match) => match[1]);
assert.equal(scripts.length, 3, 'built page retains its three ordered scripts');

function context2d() { return { clearRect() {}, fillRect() {}, }; }
function element() {
  const listeners = new Map();
  return {
    listeners,
    value: '0', textContent: '', disabled: false, hidden: false, width: 640, height: 480,
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
const classNames = new Set();
const classList = { add: (name) => classNames.add(name), remove: (name) => classNames.delete(name), toggle: (name, force) => { const on = force === undefined ? !classNames.has(name) : Boolean(force); if (on) classNames.add(name); else classNames.delete(name); return on; }, contains: (name) => classNames.has(name) };
const realm = {
  console,
  performance: { now: () => clock },
  document: { body: { classList }, querySelector: getElement, createElement: () => element() },
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
assert.equal((scripts[2].match(/\bfillText\(/g) || []).length, 1, 'only the separate compass carries its numerical text read');
const selector = elements.get('#carrier');
assert.ok(elements.get('#signal-colour').textContent.includes('RGB = three colour-basis populations'), 'default SU(3) signal frame gives the literal RGB mapping');
for (const type of ['flux', 'higgs', 'electron', 'neutrino', 'photon', 'scalar', 'noether', 'dirac', 'phi4', 'oscillation']) {
  selector.value = type;
  selector.listeners.get('change')();
  assert.notEqual(elements.get('#signal-carrier').textContent, '', `${type} updates the signal frame`);
}
selector.value = 'study:phi4-domain';
selector.listeners.get('change')();
assert.ok(classList.contains('study-mode'), 'study route enters isolated study mode');
assert.ok(elements.get('#study-frame').srcdoc.includes('Φ⁴ Domain Study'), 'selected study mounts its declared document');
assert.ok(elements.get('#signal-scope').textContent.includes('Finite signed-field reader'), 'study signal frame is read from its study source');
const returnButton = elements.get('#return-to-carrier');
assert.ok(returnButton.textContent.includes('Return to'), 'study rail exposes a return control');
returnButton.listeners.get('click')();
assert.equal(classList.contains('study-mode'), false, 'return control restores a live carrier');
assert.ok(scheduled.length >= 1, 'application frame loop is scheduled');

console.log(JSON.stringify({ browserBootstrap: { scripts: scripts.length, sleepRemoved: true, fieldClear: true, signalFrame: true, studyMount: true } }, null, 2));
