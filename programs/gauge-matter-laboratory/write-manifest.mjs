import { readFile, writeFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = dirname(fileURLToPath(import.meta.url));
const files = [
  '.openai/hosting.json',
  'build.mjs',
  'write-manifest.mjs',
  'README.md',
  'PROVENANCE.md',
  'AUDIT.md',
  'src/app.js',
  'src/core.js',
  'src/template.html',
  'src/carriers/complex-phi4.js',
  'src/carriers/two-flavour-neutrino.js',
  'src/carriers/massive-dirac.js',
  'src/carriers/gauge.js',
  'src/carriers/electroweak-higgs.js',
  'tests/check-v042.cjs',
  'tests/check-v05.cjs',
  'tests/check-browser-bootstrap.cjs',
  'tests/check-manifest.cjs',
  'clear-onyx-gauge-laboratory-v0.5.2.html'
];

const entries = [];
for (const path of files) {
  const bytes = await readFile(resolve(root, path));
  entries.push({ path, sha256: createHash('sha256').update(bytes).digest('hex') });
}

const manifest = {
  name: 'Clear Onyx Gauge & Matter Laboratory',
  version: '0.5.2',
  entry: 'clear-onyx-gauge-laboratory-v0.5.2.html',
  scope: 'Finite gauge and matter carriers, including a 2+1D electroweak Higgs-sector lattice with fixed declared SU(2)L x U(1)Y background links and a separate tree-level mass-algebra receipt. SU(3) transport supplies QCD kinematics only; a confinement ensemble remains open.',
  files: entries
};

await writeFile(resolve(root, 'source-manifest.json'), `${JSON.stringify(manifest, null, 2)}\n`);
console.log(resolve(root, 'source-manifest.json'));
