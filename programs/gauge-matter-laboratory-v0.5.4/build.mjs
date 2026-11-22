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
  ['Λ Mirror · Δ′', 'lambda-mirror'],
  ['Real Φ⁴ · signed Dirichlet sectors', 'phi4-domain-study'],
  ['Hydrogen · orbital ladder', 'hydrogen-orbital-ladder'],
  ['Helium · singlet dynamics', 'helium-dynamics'],
  ['Water · two-center field', 'water-field']
];
const studyPanels = await Promise.all(studies.map(async ([title, file]) => {
  const source = await readFile(resolve(root, 'studies', file + '.html'), 'utf8');
  const escaped = source.replaceAll('&', '&amp;').replaceAll('"', '&quot;').replaceAll('<', '&lt;');
  return `<details><summary>${title}</summary><iframe title="${title}" loading="lazy" sandbox="allow-scripts" srcdoc="${escaped}"></iframe></details>`;
}));
const html = template.replace('<!--__STUDIES__-->', () => studyPanels.join('\n')).replace('/*__EXTRA__*/', `${phi4}\n${oscillation}\n${dirac}\n${gauge}\n${higgs}`).replace('/*__CORE__*/', core).replace('/*__APP__*/', app);
const output = resolve(root, 'clear-onyx-gauge-laboratory-v0.5.4.html');
const previewOutput = resolve(root, 'dist/index.html');
await mkdir(dirname(output), { recursive: true });
await writeFile(output, html);
await mkdir(dirname(previewOutput), { recursive: true });
await writeFile(previewOutput, html);
console.log(output);
