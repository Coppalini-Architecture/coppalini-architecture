import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = dirname(fileURLToPath(import.meta.url));
const template = await readFile(resolve(root, 'src/template.html'), 'utf8');
const core = await readFile(resolve(root, 'src/core.js'), 'utf8');
const app = await readFile(resolve(root, 'src/app.js'), 'utf8');
const phi4 = await readFile(resolve(root, 'src/carriers/complex-phi4.js'), 'utf8');
const oscillation = await readFile(resolve(root, 'src/carriers/two-flavour-neutrino.js'), 'utf8');
const dirac = await readFile(resolve(root, 'src/carriers/massive-dirac.js'), 'utf8');
const gauge = await readFile(resolve(root, 'src/carriers/gauge.js'), 'utf8');
const higgs = await readFile(resolve(root, 'src/carriers/electroweak-higgs.js'), 'utf8');
const studies = [
  { id: 'lambda-mirror', title: 'Λ Mirror · Δ′', file: 'lambda-mirror' },
  { id: 'phi4-domain', title: 'Real Φ⁴ · signed Dirichlet sectors', file: 'phi4-domain-study' },
  { id: 'hydrogen', title: 'Hydrogen · orbital ladder', file: 'hydrogen-orbital-ladder' },
  { id: 'helium', title: 'Helium · singlet dynamics', file: 'helium-dynamics' },
  { id: 'water', title: 'Water · two-center field', file: 'water-field' }
];
const signalKeys = ['carrier', 'plane', 'colourMode', 'colour', 'meaning', 'memory', 'motion', 'check', 'scope'];
async function loadStudy({ id, title, file }) {
  const srcdoc = await readFile(resolve(root, 'studies', file + '.html'), 'utf8');
  const match = srcdoc.match(/<script\s+type=["']application\/json["']\s+id=["']clear-onyx-signal["']\s*>([\s\S]*?)<\/script>/i);
  if (!match) throw new Error(`${id}: missing #clear-onyx-signal`);
  const signal = JSON.parse(match[1]);
  for (const key of signalKeys) if (typeof signal[key] !== 'string' || !signal[key].trim()) throw new Error(`${id}: missing signal.${key}`);
  if (!srcdoc.includes(`data-signal-frame="${id}"`)) throw new Error(`${id}: missing local signal anchor`);
  return [id, { title, signal, srcdoc }];
}
const registry = Object.fromEntries(await Promise.all(studies.map(loadStudy)));
const registryScript = `globalThis.ClearOnyxStudyRegistry = Object.freeze(${JSON.stringify(registry).replaceAll('<', '\\u003c')});`;
const html = template.replace('/*__EXTRA__*/', `${registryScript}\n${phi4}\n${oscillation}\n${dirac}\n${gauge}\n${higgs}`).replace('/*__CORE__*/', core).replace('/*__APP__*/', app);
const output = resolve(root, 'clear-onyx-gauge-laboratory-v0.5.6.html');
const previewOutput = resolve(root, 'dist/index.html');
await mkdir(dirname(output), { recursive: true });
await writeFile(output, html);
await mkdir(dirname(previewOutput), { recursive: true });
await writeFile(previewOutput, html);
console.log(output);
