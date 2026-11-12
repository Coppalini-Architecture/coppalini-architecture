'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const html = fs.readFileSync(path.join(__dirname, '..', 'models', 'view', 'clear-onyx-mitosis-reader-v0.1.html'), 'utf8');
const scripts = [...html.matchAll(/<script(?:\s+[^>]*)?>\s*([\s\S]*?)\s*<\/script>/g)].map(match => match[1]);
const match = html.match(/<script id="cell-division-core">\s*([\s\S]*?)\s*<\/script>/);
assert.ok(match, 'core script was found');

const context = { console };
context.globalThis = context;
vm.createContext(context);
vm.runInContext(match[1], context, { filename: 'cell-division-core.js' });
const Core = context.CellDivisionCore;
assert.ok(Core, 'core API attached to globalThis');
assert.equal(Core.assertModel(), true, 'internal model assertions pass');
assert.equal(Core.SPECS.length, 6, 'toy diploid genome has six chromosomes');
assert.equal(Core.TOTAL_BASES, 108, 'toy genome has 108 loci');

let clean = Core.runToTerminal(Core.createState());
assert.equal(clean.phase, 'Daughters', 'clean cycle reaches two daughters');
assert.equal(Core.segregationPasses(clean.segregation), true, 'each daughter has one sister per chromosome');
assert.equal(clean.segregation.A.length, 6, 'daughter A receives six chromosomes');
assert.equal(clean.segregation.B.length, 6, 'daughter B receives six chromosomes');

const cleanReceipt = Core.exportReceipt(clean);
const cleanReplay = Core.verifyReceipt(cleanReceipt);
assert.equal(cleanReplay.pass, true, 'clean receipt replays');
assert.equal(cleanReplay.events, clean.ledger.length, 'replay retains all event addresses');

let repairPath = Core.advance(Core.createState());
repairPath = Core.advance(repairPath);
repairPath = Core.injectMismatch(repairPath);
assert.equal(repairPath.mismatches.length, 1, 'injected mismatch is retained');
while (repairPath.phase === 'S') repairPath = Core.advance(repairPath);
assert.equal(repairPath.phase, 'G2', 'copy process reaches G2');
const heldAtG2 = Core.advance(repairPath);
assert.equal(heldAtG2.phase, 'G2', 'G2 gate holds unresolved mismatch');
assert.equal(heldAtG2.ledger.at(-1).type, 'G2_CHECKPOINT_HOLD', 'G2 hold is recorded');
repairPath = Core.repairMismatch(heldAtG2);
assert.equal(repairPath.mismatches.length, 0, 'repair clears the exact mismatch');
repairPath = Core.runToTerminal(repairPath);
assert.equal(repairPath.phase, 'Daughters', 'repaired cycle closes');
assert.equal(Core.verifyReceipt(Core.exportReceipt(repairPath)).pass, true, 'repair-path receipt replays');

let spindlePath = Core.createState();
while (spindlePath.phase !== 'Metaphase') spindlePath = Core.advance(spindlePath);
assert.equal(spindlePath.phase, 'Metaphase', 'bounded run arrives at metaphase');
spindlePath = Core.setSpindle(spindlePath, false);
const spindleHold = Core.advance(spindlePath);
assert.equal(spindleHold.phase, 'Metaphase', 'spindle gate holds misalignment');
assert.equal(spindleHold.ledger.at(-1).type, 'SPINDLE_CHECKPOINT_HOLD', 'spindle hold is recorded');
spindlePath = Core.setSpindle(spindleHold, true);
spindlePath = Core.runToTerminal(spindlePath);
assert.equal(spindlePath.phase, 'Daughters', 'aligned spindle closes mitosis');

const tampered = JSON.parse(JSON.stringify(cleanReceipt));
tampered.events[0].after.phase = 'Daughters';
assert.equal(Core.verifyReceipt(tampered).pass, false, 'tampered receipt is refused by replay');

function runUIBootstrapSmoke() {
  const uiScript = scripts[1];
  assert.ok(uiScript, 'UI script was found');
  const context2d = new Proxy({}, {
    get(target, key) {
      if (key === 'measureText') return () => ({ width: 72 });
      if (key === 'createRadialGradient') return () => ({ addColorStop() {} });
      return () => {};
    },
    set() { return true; }
  });
  class Element {
    constructor(id) {
      this.id = id;
      this.innerHTML = '';
      this.textContent = '';
      this.value = '';
      this.disabled = false;
      this.style = {};
      this.handlers = {};
      this.classList = { toggle() {} };
      this.width = id === 'genome-canvas' ? 1300 : id === 'clock-canvas' ? 360 : 900;
      this.height = id === 'genome-canvas' ? 490 : id === 'clock-canvas' ? 240 : 690;
      this.selectedOptions = [{ text: 'Read' }];
    }
    getContext() { return context2d; }
    addEventListener(type, fn) { this.handlers[type] = fn; }
    click() { if (this.handlers.click) this.handlers.click(); }
    showModal() {}
    close() {}
    appendChild() {}
    remove() {}
  }
  const ids = ['cell-canvas','genome-canvas','clock-canvas','stats','audits','history','status','scope-caption','gate-chip','advance','play','pause','reset','inject','repair','misalign','align','speed','view-receipt','export-receipt','receipt-dialog','close-receipt','receipt-json','download-receipt','receipt-verdict','genome-declaration','model-declaration'];
  const elements = Object.fromEntries(ids.map(id => [id, new Element(id)]));
  const document = { getElementById: id => elements[id] || new Element(id), body: { appendChild() {} }, createElement: () => new Element('created') };
  const window = { setInterval: () => 1, clearInterval() {}, setTimeout() {}, addEventListener() {}, CellDivisionCore: null };
  const uiContext = { console, document, window, Blob: class {}, URL: { createObjectURL: () => '', revokeObjectURL() {} }, globalThis: window };
  vm.createContext(uiContext);
  vm.runInContext(scripts[0], uiContext, { filename: 'cell-division-core-ui-test.js' });
  window.CellDivisionCore = uiContext.CellDivisionCore || window.CellDivisionCore;
  vm.runInContext(uiScript, uiContext, { filename: 'mitosis-reader-ui.js' });

  elements.advance.click();
  elements.advance.click();
  elements.inject.click();
  for (let i = 0; i < 9; i += 1) elements.advance.click();
  assert.match(elements.status.textContent, /G2 checkpoint/, 'UI reaches the G2 repair hold');
  elements.repair.click();
  elements.advance.click();
  elements.advance.click();
  elements.misalign.click();
  elements.advance.click();
  assert.match(elements.status.textContent, /Spindle checkpoint/, 'UI reaches the spindle hold');
  elements.align.click();
  for (let i = 0; i < 4; i += 1) elements.advance.click();
  assert.match(elements.stats.innerHTML, /DAUGHTERS/, 'UI renders the daughter phase');
  assert.match(elements['receipt-verdict'].textContent, /REPLAY PASS/, 'UI renders a passing receipt verdict');
}

runUIBootstrapSmoke();
console.log(`PASS ${Core.VERSION}: ${clean.ledger.length} clean events, ${repairPath.ledger.length} repair-path events, deterministic replay and UI bootstrap verified.`);
