'use strict';

const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { resolve } = require('node:path');

const root = resolve(__dirname, '..');
const documents = { 'lambda-mirror': 'lambda-mirror.html', 'phi4-domain': 'phi4-domain-study.html', hydrogen: 'hydrogen-orbital-ladder.html', helium: 'helium-dynamics.html', water: 'water-field.html' };
function executableScripts(markup) { return [...markup.matchAll(/<script([^>]*)>([\s\S]*?)<\/script>/gi)].filter(([, attributes]) => !/type\s*=\s*["'](?:application\/json|application\/ld\+json)["']/i.test(attributes)).map(([, , source]) => source); }
const parsed = [];
for (const [id, name] of Object.entries(documents)) { const markup = readFileSync(resolve(root, 'studies', name), 'utf8'); const scripts = executableScripts(markup); assert.ok(scripts.length > 0, `${name} supplies an executable reader`); for (const source of scripts) new Function(source); parsed.push([id, scripts.length]); }
const app = readFileSync(resolve(root, 'src', 'app.js'), 'utf8');
const template = readFileSync(resolve(root, 'src', 'template.html'), 'utf8');
const build = readFileSync(resolve(root, 'build.mjs'), 'utf8');
assert.ok(template.includes('id="study-reader"') && template.includes('id="study-frame"'), 'template exposes one study reader mount');
assert.equal(template.includes('study-suite'), false, 'template has no parallel study-suite panels');
assert.ok(app.includes("type.startsWith('study:')") && app.includes('function switchStudy'), 'app dispatches study routes');
assert.ok(app.indexOf("type.startsWith('study:')") < app.indexOf('state.engine = makeEngine(type)'), 'study routes precede the legacy factory');
for (const id of Object.keys(documents)) { assert.ok(template.includes(`value="study:${id}"`), `selector exposes study:${id}`); assert.ok(build.includes(`'${id}'`), `build registers ${id}`); }
const phi4 = readFileSync(resolve(root, 'studies', documents['phi4-domain']), 'utf8');
for (const required of ['reflectedSector','field.map(value => -value)','λₘᵢₙ(Lₕ) − λv²','Quadratic test degenerate','Gradient residual (max)','Hessian residual (max entry)']) assert.ok(phi4.includes(required), `Φ⁴ study retains ${required}`);
const lambdaMirror = readFileSync(resolve(root, 'studies', documents['lambda-mirror']), 'utf8');
assert.ok(lambdaMirror.includes('registry reflection') && lambdaMirror.includes('have distinct carriers'), 'Λ mirror keeps its carrier distinction');
const water = readFileSync(resolve(root, 'studies', documents.water), 'utf8');
assert.ok(water.includes('RAW_CONSTRUCTIVE') && water.includes('RAW_NODAL'), 'water remains a raw constructive/nodal reader');
console.log(JSON.stringify({ studySuite: Object.fromEntries(parsed), mounted: 'one', status: 'OPEN / no main-carrier PASS' }, null, 2));
