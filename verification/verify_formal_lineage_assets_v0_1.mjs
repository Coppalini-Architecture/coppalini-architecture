import { createHash } from 'node:crypto';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const manifestPath = resolve(root, 'assets/lineage-1028/lineage-data.json');
const receiptPath = resolve(root, 'verification/formal-lineage-1028-assets-v0.1.json');
const manifestBytes = readFileSync(manifestPath);
const manifest = JSON.parse(manifestBytes);
const sha256 = (bytes) => createHash('sha256').update(bytes).digest('hex');
const errors = [];
const plates = [];

for (const card of manifest.cards) {
  if (card.art.startsWith('/') || card.art.split('/').includes('..')) {
    errors.push(`${card.id}: invalid art path`);
    continue;
  }
  const platePath = resolve(root, card.art);
  if (!existsSync(platePath)) {
    errors.push(`${card.id}: missing plate`);
    continue;
  }
  const bytes = readFileSync(platePath);
  const digest = sha256(bytes);
  const svg = bytes.toString('utf8').trimStart().startsWith('<svg');
  if (!svg) errors.push(`${card.id}: plate is not SVG`);
  if (digest !== card.artSha256) errors.push(`${card.id}: sha256 mismatch`);
  plates.push({ id: card.id, path: card.art, sha256: digest, svg });
}

const report = {
  status: errors.length === 0 ? 'passed' : 'failed',
  scope: 'Formal Lineage card-art presence, SVG type, and manifest hash verification.',
  source: 'assets/lineage-1028/lineage-data.json',
  data_sha256: sha256(manifestBytes),
  cards: manifest.cards.length,
  plates_verified: plates.length,
  errors,
  plates
};

const output = `${JSON.stringify(report, null, 2)}\n`;
if (process.argv.includes('--write')) writeFileSync(receiptPath, output);
process.stdout.write(output);
if (errors.length) process.exitCode = 1;
