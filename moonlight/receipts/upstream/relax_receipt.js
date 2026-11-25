// MOONLIGHT relax receipt, JS port (BigInt, no DOM). Mirrors relax_receipt.py; local draft, O-X6 of RELAX-001.
'use strict';
const Q = 4, S = 137, N = 548, KMIN = 2, KMAX = 300;
const SCHEMA = 'CoppaliniArchitecture.MOONLIGHT-Relax-Receipt/v0.1';
const RULE = {id: 'fibonacci_quotient_relax', schedule: 'rho_k=Fib_{k-1}/Fib_k'};
const CHECKS = {s_preserved: true, address_relation_input: true, address_relation_output: true, non_expansion: true};
const TOP = ['schema', 'rule', 'input', 'trace', 'recomputed', 'recorded', 'checks', 'delta', 'reader'];
const FIB = [0n, 1n]; for (let i = 0; i < KMAX + 2; i++) FIB.push(FIB[FIB.length - 1] + FIB[FIB.length - 2]);
const gcd = (a, b) => { a = a < 0n ? -a : a; b = b < 0n ? -b : b; while (b) [a, b] = [b, a % b]; return a; };
const addr = (q, s) => s + S * (((q - s) % Q + Q) % Q);
function red(n, d) { const g = gcd(n, d); return [n / g, d / g]; }
const fs = f => f[0] + '/' + f[1];
const FRA = /^-?(0|[1-9][0-9]*)\/[1-9][0-9]*$/;
function unfs(t) {
  if (typeof t !== 'string' || t.length > 200 || !FRA.test(t)) return null;
  const [a, b] = t.split('/'); const n = BigInt(a), d = BigInt(b);
  if (gcd(n, d) !== 1n) return null;
  return fs([n, d]) === t ? [n, d] : null;
}
const rho = k => red(FIB[k - 1], FIB[k]);
const kappa = k => red(FIB[k] - FIB[k - 1], FIB[k]);
function step(q, s, d, k) {
  const q2 = (q + 2) % Q, r = rho(k);
  return {q: q2, s, a: addr(q2, s), d: fs(red(r[0] * d[0], r[1] * d[1]))};
}
const isObj = v => v !== null && typeof v === 'object' && !Array.isArray(v);
function same(a, b) {
  if (typeof a !== typeof b || Array.isArray(a) !== Array.isArray(b) || (a === null) !== (b === null)) return false;
  if (Array.isArray(a)) return a.length === b.length && a.every((x, i) => same(x, b[i]));
  if (isObj(a)) { const ka = Object.keys(a), kb = Object.keys(b); return ka.length === kb.length && ka.every(k => k in b && same(a[k], b[k])); }
  return a === b;
}
const keysIs = (o, ks) => isObj(o) && Object.keys(o).length === ks.length && ks.every(k => k in o);
const isInt = (v, lo, hi) => typeof v === 'number' && Number.isInteger(v) && v >= lo && v <= hi;
function outOk(o) {
  if (!keysIs(o, ['q', 's', 'a', 'd'])) return false;
  if (!(isInt(o.q, 0, 3) && isInt(o.s, 0, S - 1) && isInt(o.a, 0, N - 1)) || o.a !== addr(o.q, o.s)) return false;
  const d = unfs(o.d); return d !== null && 2n * (d[0] < 0n ? -d[0] : d[0]) <= d[1];
}
function checkReceipt(rc) {
  try {
    if (!isObj(rc) || rc.schema !== SCHEMA || !keysIs(rc, TOP) || !same(rc.rule, RULE)) return 'INVALID';
    if (!keysIs(rc.reader, ['label']) || typeof rc.reader.label !== 'string' || rc.reader.label.trim() === '') return 'INVALID';
    const i = rc.input;
    if (!keysIs(i, ['q', 's', 'a', 'd', 'k'])) return 'INVALID';
    if (!(isInt(i.q, 0, 3) && isInt(i.s, 0, S - 1) && isInt(i.a, 0, N - 1) && isInt(i.k, KMIN, KMAX))) return 'INVALID';
    const d = unfs(i.d);
    if (d === null || !(2n * d[0] >= -d[1] && 2n * d[0] < d[1]) || i.a !== addr(i.q, i.s)) return 'INVALID';
    const want = step(i.q, i.s, d, i.k);
    const tr = {rho: fs(rho(i.k)), kappa: fs(kappa(i.k)), phase_step: 2};
    const rec = rc.recorded, rcp = rc.recomputed, dl = rc.delta;
    if (!(outOk(rec) && outOk(rcp))) return 'INVALID';
    if (!same(rcp, want) || !same(rc.trace, tr) || !same(rc.checks, CHECKS) || !Array.isArray(dl)) return 'INVALID';
    if (same(rec, rcp)) return dl.length === 0 ? 'OK' : 'INVALID';
    return same(dl, [{recorded: rec, recomputed: rcp}]) ? 'OK_WITH_DELTA' : 'INVALID';
  } catch (e) { return 'INVALID'; }
}
// Numeric tokens outside strings must be plain integers; JSON.parse alone erases 1 vs 1.0 and -0.
function lexicalOk(text) {
  let i = 0; const n = text.length;
  while (i < n) {
    const c = text[i];
    if (c === '"') { i += 1; while (i < n && text[i] !== '"') { if (text[i] === '\\') i += 1; i += 1; } i += 1; continue; }
    if (c === '-' || (c >= '0' && c <= '9')) {
      let j = i; while (j < n && /[-+0-9.eE]/.test(text[j])) j += 1;
      if (!/^-?(0|[1-9][0-9]*)$/.test(text.slice(i, j))) return false;
      i = j; continue;
    }
    i += 1;
  }
  return true;
}
function checkText(text) {
  try {
    if (!lexicalOk(text)) return 'INVALID';
    return checkReceipt(JSON.parse(text, (k, v) => (typeof v === 'number' && Object.is(v, -0) ? 0 : v)));
  } catch (e) { return 'INVALID'; }
}
module.exports = {step, unfs, fs, rho, kappa, addr, checkReceipt, checkText, lexicalOk};
