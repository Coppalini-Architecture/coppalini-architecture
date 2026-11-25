// MOONLIGHT harmonizer, pure module (no DOM): exact BigInt rationals, same definition as harmonizer.py.
'use strict';
const S = 137n, SCHEMA = 'CoppaliniArchitecture.MOONLIGHT-Harmonizer-Receipt/v0.1';
const RULE = {id: 'nearest_sector_pull', tie: 'half_up', profile: 'plateau_smoothstep'};
const CHECKS = {q_preserved: true, address_relation: true};
const TOP = ['schema', 'rule', 'input', 'trace', 'recomputed', 'recorded', 'checks', 'delta', 'reader'];
const gcd = (a, b) => { a = a < 0n ? -a : a; b = b < 0n ? -b : b; while (b) [a, b] = [b, a % b]; return a; };
const fr = (n, d = 1n) => { if (d < 0n) { n = -n; d = -d; } const g = gcd(n, d) || 1n; return [n / g, d / g]; };
const add = (a, b) => fr(a[0] * b[1] + b[0] * a[1], a[1] * b[1]);
const sub = (a, b) => fr(a[0] * b[1] - b[0] * a[1], a[1] * b[1]);
const mul = (a, b) => fr(a[0] * b[0], a[1] * b[1]);
const div = (a, b) => fr(a[0] * b[1], a[1] * b[0]);
const cmp = (a, b) => { const l = a[0] * b[1], r = b[0] * a[1]; return l < r ? -1 : l > r ? 1 : 0; };
const abs = a => [a[0] < 0n ? -a[0] : a[0], a[1]];
const floorDiv = (n, d) => { const q = n / d; return (n % d !== 0n && (n < 0n) !== (d < 0n)) ? q - 1n : q; };
const floor = a => floorDiv(a[0], a[1]);
const modS = a => sub(a, [S * floorDiv(a[0], a[1] * S), 1n]);
const HALF = [1n, 2n], ZERO = [0n, 1n], ONE = [1n, 1n];
const smooth = u => sub(mul([3n, 1n], mul(u, u)), mul([2n, 1n], mul(u, mul(u, u))));
const fs = a => a[0] + '/' + a[1];
const mod = (a, b) => ((a % b) + b) % b;
const addr = (q, s) => s + 137 * mod(q - s, 4);
const DEC = /^-?(0|[1-9][0-9]*)(\.[0-9]+)?$/, FRA = /^-?(0|[1-9][0-9]*)\/[1-9][0-9]*$/;
function dec(text, lo, hi) {
  if (typeof text !== 'string' || text.length > 64 || !DEC.test(text)) return null;
  const neg = text[0] === '-', body = neg ? text.slice(1) : text, [ip, fp = ''] = body.split('.');
  let v = fr(BigInt(ip + fp), 10n ** BigInt(fp.length)); if (neg) v = fr(-v[0], v[1]);
  if ((lo && cmp(v, lo) < 0) || (hi && cmp(v, hi) > 0)) return null;
  return v;
}
function unfs(text) {
  if (typeof text !== 'string' || text.length > 200 || !FRA.test(text)) return null;
  const [n, d] = text.split('/').map(BigInt);
  return gcd(n, d) === 1n && fs([n, d]) === text ? [n, d] : null;   // canonical text only: '-0/1' is not '0/1'
}
function H(q, x, h, kappa) {
  const x0 = modS(x), k = floor(add(x0, HALF)), s = mod(k, S), d = sub(x0, [k, 1n]), m = abs(d);
  const w = cmp(m, h) <= 0 ? kappa : mul(kappa, smooth(div(sub(HALF, m), sub(HALF, h))));
  const y = modS(sub(x0, mul(w, d)));
  const sn = Number(s);
  return {x0, s: sn, d, w, y, a: addr(q, sn)};
}
const outRecord = r => ({s: r.s, a: r.a, y: fs(r.y)});
const isInt = (v, lo, hi) => typeof v === 'number' && Number.isInteger(v) && !Object.is(v, -0) && v >= lo && v <= hi;
const isObj = v => v !== null && typeof v === 'object' && !Array.isArray(v) && Object.getPrototypeOf(v) === Object.prototype;
const keys = (v, ks) => isObj(v) && Object.keys(v).length === ks.length && ks.every(k => Object.prototype.hasOwnProperty.call(v, k));
const same = (a, b) => {
  if (typeof a !== typeof b) return false;
  if (a === null || b === null) return a === b;
  if (Array.isArray(a) || Array.isArray(b)) return Array.isArray(a) && Array.isArray(b) && a.length === b.length && a.every((v, i) => same(v, b[i]));
  if (typeof a === 'object') { const ka = Object.keys(a), kb = Object.keys(b); return ka.length === kb.length && ka.every(k => Object.prototype.hasOwnProperty.call(b, k) && same(a[k], b[k])); }
  return Object.is(a, b);
};
const outOk = (q, o) => {
  if (!keys(o, ['s', 'a', 'y']) || !isInt(o.s, 0, 136) || !isInt(o.a, 0, 547) || o.a !== addr(q, o.s)) return false;
  const y = unfs(o.y); return y !== null && cmp(y, ZERO) >= 0 && cmp(y, [S, 1n]) < 0;
};
function checkReceipt(rc) {
  try {
    if (!keys(rc, TOP) || rc.schema !== SCHEMA || !same(rc.rule, RULE)) return 'INVALID';
    if (!keys(rc.reader, ['label']) || typeof rc.reader.label !== 'string' || !rc.reader.label.trim()) return 'INVALID';
    const i = rc.input;
    if (!keys(i, ['q', 'x', 'h', 'kappa']) || !isInt(i.q, 0, 3)) return 'INVALID';
    const x = dec(i.x), h = dec(i.h, ZERO, HALF), k = dec(i.kappa, ZERO, ONE);
    if (!x || !h || !k) return 'INVALID';
    const r = H(i.q, x, h, k), want = outRecord(r), tr = {x_mod: fs(r.x0), d: fs(r.d), w: fs(r.w)};
    const rec = rc.recorded, rcp = rc.recomputed, d = rc.delta;
    if (!(outOk(i.q, rec) && outOk(i.q, rcp))) return 'INVALID';
    if (!same(rcp, want) || !same(rc.trace, tr) || !same(rc.checks, CHECKS) || !Array.isArray(d)) return 'INVALID';
    if (same(rec, rcp)) return d.length === 0 ? 'OK' : 'INVALID';
    return same(d, [{recorded: rec, recomputed: rcp}]) ? 'OK_WITH_DELTA' : 'INVALID';
  } catch (e) { return 'INVALID'; }
}
// Lexical numeric-token validation: every number outside a string must be an integer literal
// (-?(0|[1-9][0-9]*)); 1.0, 1e0, +1 and the like are rejected before JSON.parse can erase the distinction.
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
module.exports = {H, dec, fs, checkReceipt, checkText, lexicalOk, addr};
