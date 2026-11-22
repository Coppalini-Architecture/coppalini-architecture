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
  ['lambda-mirror', 'Λ Mirror · Δ′', 'lambda-mirror'],
  ['phi4-domain', 'Real Φ⁴ · signed Dirichlet sectors', 'phi4-domain-study'],
  ['hydrogen', 'Hydrogen · orbital ladder', 'hydrogen-orbital-ladder'],
  ['helium', 'Helium · singlet dynamics', 'helium-dynamics'],
  ['water', 'Water · two-center field', 'water-field']
];
const registry = Object.fromEntries(await Promise.all(studies.map(async ([id, title, file]) => [
  id, { title, srcdoc: await readFile(resolve(root, 'studies', file + '.html'), 'utf8') }
])));
const registryScript = `globalThis.ClearOnyxStudyRegistry = Object.freeze(${JSON.stringify(registry).replaceAll('<', '\\u003c')});`;
const html = template.replace('/*__EXTRA__*/', `${registryScript}\n${phi4}\n${oscillation}\n${dirac}\n${gauge}\n${higgs}`).replace('/*__CORE__*/', core).replace('/*__APP__*/', app);
const output = resolve(root, 'clear-onyx-gauge-laboratory-v0.5.5.html');
const previewOutput = resolve(root, 'dist/index.html');
await mkdir(dirname(output), { recursive: true });
await writeFile(output, html);
await mkdir(dirname(previewOutput), { recursive: true });
await writeFile(previewOutput, html);
console.log(output);
