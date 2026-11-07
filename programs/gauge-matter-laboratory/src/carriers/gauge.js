/* Clear Onyx v0.4.2 — finite gauge carriers.
 *
 * U(1) flux ring: a gauge-covariant split-step transport on a closed graph.
 * SU(3) colour transport: a gauge-covariant split-step transport of a colour
 * triplet on a 2D lattice in a declared, non-commuting SU(3) background.
 *
 * These are lattice-gauge kinematics. They do not claim an ensemble QCD
 * confinement calculation.
 */
'use strict';

const GaugeCarriers = (() => {
  const TAU = Math.PI * 2;
  const mod = (value, divisor) => ((value % divisor) + divisor) % divisor;
  const wrap = (value) => Math.atan2(Math.sin(value), Math.cos(value));

  const cmul = (ar, ai, br, bi) => [ar * br - ai * bi, ar * bi + ai * br];
  const cabs2 = (re, im) => re * re + im * im;

  function matrixIdentity() {
    const re = new Float64Array(9), im = new Float64Array(9);
    re[0] = re[4] = re[8] = 1;
    return { re, im };
  }
  function matrixClone(m) { return { re: new Float64Array(m.re), im: new Float64Array(m.im) }; }
  function matrixMultiply(a, b) {
    const re = new Float64Array(9), im = new Float64Array(9);
    for (let row = 0; row < 3; row += 1) for (let col = 0; col < 3; col += 1) {
      let rr = 0, ii = 0;
      for (let k = 0; k < 3; k += 1) {
        const [pr, pi] = cmul(a.re[row * 3 + k], a.im[row * 3 + k], b.re[k * 3 + col], b.im[k * 3 + col]);
        rr += pr; ii += pi;
      }
      re[row * 3 + col] = rr; im[row * 3 + col] = ii;
    }
    return { re, im };
  }
  function matrixDagger(a) {
    const re = new Float64Array(9), im = new Float64Array(9);
    for (let row = 0; row < 3; row += 1) for (let col = 0; col < 3; col += 1) {
      re[row * 3 + col] = a.re[col * 3 + row]; im[row * 3 + col] = -a.im[col * 3 + row];
    }
    return { re, im };
  }
  function matrixVector(m, vector) {
    const out = new Float64Array(6);
    for (let row = 0; row < 3; row += 1) for (let k = 0; k < 3; k += 1) {
      const [rr, ii] = cmul(m.re[row * 3 + k], m.im[row * 3 + k], vector[k * 2], vector[k * 2 + 1]);
      out[row * 2] += rr; out[row * 2 + 1] += ii;
    }
    return out;
  }
  function matrixTrace(m) { return { re: m.re[0] + m.re[4] + m.re[8], im: m.im[0] + m.im[4] + m.im[8] }; }
  function matrixDet(m) {
    const e = (a, b, c, d, e0, f, g, h, i) => {
      const ab = cmul(a[0], a[1], e0[0], e0[1]); const abf = cmul(ab[0], ab[1], i[0], i[1]);
      const bc = cmul(b[0], b[1], f[0], f[1]); const bch = cmul(bc[0], bc[1], g[0], g[1]);
      const cd = cmul(c[0], c[1], d[0], d[1]); const cde = cmul(cd[0], cd[1], h[0], h[1]);
      const ce = cmul(c[0], c[1], e0[0], e0[1]); const ceg = cmul(ce[0], ce[1], g[0], g[1]);
      const bf = cmul(b[0], b[1], d[0], d[1]); const bfi = cmul(bf[0], bf[1], i[0], i[1]);
      const ah = cmul(a[0], a[1], f[0], f[1]); const ahh = cmul(ah[0], ah[1], h[0], h[1]);
      return { re: abf[0] + bch[0] + cde[0] - ceg[0] - bfi[0] - ahh[0], im: abf[1] + bch[1] + cde[1] - ceg[1] - bfi[1] - ahh[1] };
    };
    const v = (i) => [m.re[i], m.im[i]];
    return e(v(0), v(1), v(2), v(3), v(4), v(5), v(6), v(7), v(8));
  }
  function su3R12(angle) {
    const out = matrixIdentity(), c = Math.cos(angle), s = Math.sin(angle);
    out.re[0] = out.re[4] = c; out.im[1] = s; out.im[3] = s;
    return out;
  }
  function su3R23(angle) {
    const out = matrixIdentity(), c = Math.cos(angle), s = Math.sin(angle);
    out.re[4] = out.re[8] = c; out.im[5] = s; out.im[7] = s;
    return out;
  }
  function su3Diagonal(alpha, beta) {
    const out = matrixIdentity();
    for (const [index, phase] of [[0, alpha], [4, beta], [8, -alpha - beta]]) { out.re[index] = Math.cos(phase); out.im[index] = Math.sin(phase); }
    return out;
  }
  function maxMatrixDifference(a, b) {
    let result = 0; for (let i = 0; i < 9; i += 1) result = Math.max(result, Math.abs(a.re[i] - b.re[i]), Math.abs(a.im[i] - b.im[i])); return result;
  }

  class U1FluxRingEngine {
    constructor(width = 128, height = 128, nodes = 128, flux = 1.27 * Math.PI) {
      this.width = width; this.height = height; this.size = width * height; this.nodes = nodes; this.flux = flux; this.theta = .105;
      this.re = new Float64Array(nodes); this.im = new Float64Array(nodes); this.frame = 0; this.pulses = [];
      this.gauge = null; this.seedPacket(); this.baseline = this.read();
    }
    link(index) {
      const base = this.flux / this.nodes;
      const shift = this.gauge ? this.gauge[index] - this.gauge[mod(index + 1, this.nodes)] : 0;
      return base + shift;
    }
    seedPacket() {
      const centre = this.nodes * .13, spread = this.nodes * .055;
      let norm = 0;
      for (let i = 0; i < this.nodes; i += 1) { const distance = Math.min(Math.abs(i - centre), this.nodes - Math.abs(i - centre)); this.re[i] = Math.exp(-distance * distance / (2 * spread * spread)); this.im[i] = 0; norm += this.re[i] ** 2; }
      const scale = 1 / Math.sqrt(norm); for (let i = 0; i < this.nodes; i += 1) this.re[i] *= scale;
      this.frame = 0; this.pulses.length = 0;
    }
    bond(index) {
      const next = mod(index + 1, this.nodes), phase = this.link(index), c = Math.cos(this.theta), s = Math.sin(this.theta);
      const ar = this.re[index], ai = this.im[index];
      const [br, bi] = cmul(Math.cos(phase), Math.sin(phase), this.re[next], this.im[next]);
      const naR = c * ar + s * bi, naI = c * ai - s * br;
      const nbR = s * ai + c * br, nbI = -s * ar + c * bi;
      const [outR, outI] = cmul(Math.cos(phase), -Math.sin(phase), nbR, nbI);
      this.re[index] = naR; this.im[index] = naI; this.re[next] = outR; this.im[next] = outI;
    }
    step(count = 1) {
      for (let turn = 0; turn < count; turn += 1) { for (let parity = 0; parity < 2; parity += 1) for (let i = parity; i < this.nodes; i += 2) this.bond(i); this.frame += 1; }
    }
    rotateGlobal(degrees) { const a = degrees * Math.PI / 180, c = Math.cos(a), s = Math.sin(a); for (let i = 0; i < this.nodes; i += 1) { const r = this.re[i], q = this.im[i]; this.re[i] = r * c - q * s; this.im[i] = r * s + q * c; } }
    inject(x = this.width * .5, y = this.height * .5) {
      const angle = Math.atan2(y / this.height - .5, x / this.width - .5); const centre = mod(Math.round((angle / TAU + .5) * this.nodes), this.nodes);
      for (let i = 0; i < this.nodes; i += 1) { const distance = Math.min(Math.abs(i - centre), this.nodes - Math.abs(i - centre)); const phase = .9 * Math.exp(-distance * distance / (2 * 5 ** 2)); const c = Math.cos(phase), s = Math.sin(phase), r = this.re[i], q = this.im[i]; this.re[i] = r * c - q * s; this.im[i] = r * s + q * c; }
      this.pulses.push({ node: centre, frame: this.frame });
    }
    nodeAt(x, y) { return mod(Math.round((Math.atan2(y / this.height - .5, x / this.width - .5) / TAU + .5) * this.nodes), this.nodes); }
    visualAt(index) {
      const x = index % this.width, y = Math.floor(index / this.width), dx = x / this.width - .5, dy = y / this.height - .5;
      const radius = Math.hypot(dx, dy), radial = Math.exp(-(((radius - .30) / .036) ** 2)), node = this.nodeAt(x, y);
      return { density: radial * cabs2(this.re[node], this.im[node]), phase: Math.atan2(this.im[node], this.re[node]) };
    }
    norm() { let sum = 0; for (let i = 0; i < this.nodes; i += 1) sum += cabs2(this.re[i], this.im[i]); return sum; }
    holonomy() { let phase = 0; for (let i = 0; i < this.nodes; i += 1) phase += this.link(i); return wrap(phase); }
    read() {
      let c = 0, s = 0; for (let i = 0; i < this.nodes; i += 1) { const density = cabs2(this.re[i], this.im[i]); c += density * Math.cos(TAU * i / this.nodes); s += density * Math.sin(TAU * i / this.nodes); }
      const n = this.norm() || 1;
      return { norm: n, energyProxy: wrap(this.flux), current: { x: c / n, y: s / n }, spin: { x: Math.cos(this.holonomy()), y: Math.sin(this.holonomy()), z: Math.hypot(c, s) / n } };
    }
    clone() { const copy = new U1FluxRingEngine(this.width, this.height, this.nodes, this.flux); copy.re.set(this.re); copy.im.set(this.im); copy.frame = this.frame; copy.pulses = [...this.pulses]; copy.gauge = this.gauge && new Float64Array(this.gauge); copy.baseline = copy.read(); return copy; }
    withFlux(flux) { const copy = new U1FluxRingEngine(this.width, this.height, this.nodes, flux); copy.re.set(this.re); copy.im.set(this.im); copy.frame = this.frame; copy.pulses = [...this.pulses]; copy.baseline = copy.read(); return copy; }
    twist(momentumQuantum = -1) {
      for (let i = 0; i < this.nodes; i += 1) { const phase = momentumQuantum * TAU * i / this.nodes, [r, q] = cmul(Math.cos(phase), Math.sin(phase), this.re[i], this.im[i]); this.re[i] = r; this.im[i] = q; }
      return this;
    }
    gaugeTransform() { const copy = this.clone(), gauge = new Float64Array(this.nodes); for (let i = 0; i < this.nodes; i += 1) gauge[i] = .43 * Math.sin(TAU * i / this.nodes) + .19 * Math.cos(2 * TAU * i / this.nodes); for (let i = 0; i < this.nodes; i += 1) { const [r, q] = cmul(Math.cos(gauge[i]), Math.sin(gauge[i]), copy.re[i], copy.im[i]); copy.re[i] = r; copy.im[i] = q; } copy.gauge = gauge; return copy; }
    gaugeCovarianceResidual(steps = 11) { const base = this.clone(), transformed = this.gaugeTransform(); base.step(steps); transformed.step(steps); const expected = base.gaugeTransform(); let residual = 0; for (let i = 0; i < this.nodes; i += 1) residual = Math.max(residual, Math.abs(expected.re[i] - transformed.re[i]), Math.abs(expected.im[i] - transformed.im[i])); return residual; }
    largeGaugeResidual(steps = 400) {
      const base = this.clone(), shifted = this.withFlux(this.flux + TAU).twist(-1);
      base.step(steps); shifted.step(steps);
      let residual = 0; for (let i = 0; i < this.nodes; i += 1) residual = Math.max(residual, Math.abs(cabs2(base.re[i], base.im[i]) - cabs2(shifted.re[i], shifted.im[i])));
      return residual;
    }
    halfFluxResponse(steps = 400) {
      const base = this.clone(), shifted = this.withFlux(this.flux + Math.PI);
      base.step(steps); shifted.step(steps);
      let response = 0; for (let i = 0; i < this.nodes; i += 1) response = Math.max(response, Math.abs(cabs2(base.re[i], base.im[i]) - cabs2(shifted.re[i], shifted.im[i])));
      return response;
    }
    audit(read) { return Math.abs(read.norm - this.baseline.norm) < 2e-12 ? 'PASS · gauge-unitary transport' : 'WATCH · norm residual'; }
  }

  class SU3ColorTransportEngine {
    constructor(width = 64, height = 64) {
      if (width % 2 || height % 2) throw new Error('SU(3) bond partition requires even lattice dimensions.');
      this.width = width; this.height = height; this.size = width * height; this.theta = .067;
      this.re = [new Float64Array(this.size), new Float64Array(this.size), new Float64Array(this.size)];
      this.im = [new Float64Array(this.size), new Float64Array(this.size), new Float64Array(this.size)];
      this.linkX = su3R12(.31); this.linkY = su3R23(.23); this.localX = null; this.localY = null; this.frame = 0; this.pulses = [];
      this.seedPacket(); this.baseline = this.read();
    }
    index(x, y) { return mod(y, this.height) * this.width + mod(x, this.width); }
    link(direction, index) { const links = direction === 'x' ? this.localX : this.localY; return links ? links[index] : direction === 'x' ? this.linkX : this.linkY; }
    vector(index) { return new Float64Array([this.re[0][index], this.im[0][index], this.re[1][index], this.im[1][index], this.re[2][index], this.im[2][index]]); }
    setVector(index, v) { for (let k = 0; k < 3; k += 1) { this.re[k][index] = v[k * 2]; this.im[k][index] = v[k * 2 + 1]; } }
    seedPacket(basis = 0) {
      const cx = this.width * .28, cy = this.height * .5, spread = Math.min(this.width, this.height) * .09; let norm = 0;
      for (let k = 0; k < 3; k += 1) { this.re[k].fill(0); this.im[k].fill(0); }
      for (let y = 0; y < this.height; y += 1) for (let x = 0; x < this.width; x += 1) { const i = this.index(x, y), amp = Math.exp(-((x - cx) ** 2 + (y - cy) ** 2) / (2 * spread * spread)); this.re[basis][i] = amp; norm += amp * amp; }
      const scale = 1 / Math.sqrt(norm); for (let i = 0; i < this.size; i += 1) this.re[basis][i] *= scale;
      this.frame = 0; this.pulses.length = 0;
    }
    bond(index, neighbour, link) {
      const a = this.vector(index), b = this.vector(neighbour), atB = matrixVector(link, b), c = Math.cos(this.theta), s = Math.sin(this.theta);
      const na = new Float64Array(6), nbAtA = new Float64Array(6);
      for (let k = 0; k < 3; k += 1) { const ar = a[2 * k], ai = a[2 * k + 1], br = atB[2 * k], bi = atB[2 * k + 1]; na[2 * k] = c * ar + s * bi; na[2 * k + 1] = c * ai - s * br; nbAtA[2 * k] = s * ai + c * br; nbAtA[2 * k + 1] = -s * ar + c * bi; }
      this.setVector(index, na); this.setVector(neighbour, matrixVector(matrixDagger(link), nbAtA));
    }
    stage(direction, parity) {
      if (direction === 'x') for (let y = 0; y < this.height; y += 1) for (let x = parity; x < this.width; x += 2) { const i = this.index(x, y); this.bond(i, this.index(x + 1, y), this.link('x', i)); }
      else for (let y = parity; y < this.height; y += 2) for (let x = 0; x < this.width; x += 1) { const i = this.index(x, y); this.bond(i, this.index(x, y + 1), this.link('y', i)); }
    }
    step(count = 1) { for (let turn = 0; turn < count; turn += 1) { this.stage('x', 0); this.stage('x', 1); this.stage('y', 0); this.stage('y', 1); this.frame += 1; } }
    rotateGlobal(degrees) { const a = degrees * Math.PI / 180, c = Math.cos(a), s = Math.sin(a); for (let k = 0; k < 3; k += 1) for (let i = 0; i < this.size; i += 1) { const r = this.re[k][i], q = this.im[k][i]; this.re[k][i] = r * c - q * s; this.im[k][i] = r * s + q * c; } }
    inject(x = this.width * .5, y = this.height * .5) {
      const spread = Math.min(this.width, this.height) * .08;
      for (let row = 0; row < this.height; row += 1) for (let col = 0; col < this.width; col += 1) { const i = this.index(col, row), amount = .88 * Math.exp(-((col - x) ** 2 + (row - y) ** 2) / (2 * spread * spread)), rotation = matrixMultiply(su3R12(amount), su3R23(amount * .72)); this.setVector(i, matrixVector(rotation, this.vector(i))); }
      this.pulses.push({ x: x / this.width, y: y / this.height, frame: this.frame });
    }
    norm() { let sum = 0; for (let k = 0; k < 3; k += 1) for (let i = 0; i < this.size; i += 1) sum += cabs2(this.re[k][i], this.im[k][i]); return sum; }
    populations() { const out = [0, 0, 0]; for (let k = 0; k < 3; k += 1) for (let i = 0; i < this.size; i += 1) out[k] += cabs2(this.re[k][i], this.im[k][i]); return out; }
    plaquette(index = this.index(Math.floor(this.width / 2), Math.floor(this.height / 2))) { const x = index % this.width, y = Math.floor(index / this.width), right = this.index(x + 1, y), up = this.index(x, y + 1); return matrixMultiply(matrixMultiply(matrixMultiply(this.link('x', index), this.link('y', right)), matrixDagger(this.link('x', up))), matrixDagger(this.link('y', index))); }
    plaquetteTrace() { return matrixTrace(this.plaquette()); }
    wilsonLoop(dx = 2, dy = 1, x0 = Math.floor(this.width / 2), y0 = Math.floor(this.height / 2)) {
      let product = matrixIdentity();
      for (let step = 0; step < dx; step += 1) product = matrixMultiply(product, this.link('x', this.index(x0 + step, y0)));
      for (let step = 0; step < dy; step += 1) product = matrixMultiply(product, this.link('y', this.index(x0 + dx, y0 + step)));
      for (let step = 0; step < dx; step += 1) product = matrixMultiply(product, matrixDagger(this.link('x', this.index(x0 + dx - step - 1, y0 + dy))));
      for (let step = 0; step < dy; step += 1) product = matrixMultiply(product, matrixDagger(this.link('y', this.index(x0, y0 + dy - step - 1))));
      return product;
    }
    wilsonLoopTrace(dx = 2, dy = 1) { return matrixTrace(this.wilsonLoop(dx, dy)); }
    visualAt(index) {
      const channels = [cabs2(this.re[0][index], this.im[0][index]), cabs2(this.re[1][index], this.im[1][index]), cabs2(this.re[2][index], this.im[2][index])];
      const density = channels[0] + channels[1] + channels[2];
      const phase = Math.atan2(this.im[0][index] + this.im[1][index] + this.im[2][index], this.re[0][index] + this.re[1][index] + this.re[2][index]);
      return { density, phase, rgb: channels, spin: { x: 0, y: 0, z: 0 } };
    }
    read() {
      const n = this.norm() || 1, p = this.populations(), phase = Math.atan2(this.im[0].reduce((a, b) => a + b, 0) + this.im[1].reduce((a, b) => a + b, 0), this.re[0].reduce((a, b) => a + b, 0) + this.re[1].reduce((a, b) => a + b, 0));
      const trace = this.plaquetteTrace();
      return { norm: n, energyProxy: 1 - trace.re / 3, current: { x: p[0] / n, y: p[1] / n }, spin: { x: (p[0] - p[1]) / n, y: (p[1] - p[2]) / n, z: Math.cos(phase) }, populations: p.map((value) => value / n), plaquette: trace };
    }
    clone() { const copy = new SU3ColorTransportEngine(this.width, this.height); for (let k = 0; k < 3; k += 1) { copy.re[k].set(this.re[k]); copy.im[k].set(this.im[k]); } copy.linkX = matrixClone(this.linkX); copy.linkY = matrixClone(this.linkY); copy.localX = this.localX && this.localX.map(matrixClone); copy.localY = this.localY && this.localY.map(matrixClone); copy.frame = this.frame; copy.pulses = [...this.pulses]; copy.baseline = copy.read(); return copy; }
    gaugeMatrices() {
      const matrices = new Array(this.size);
      for (let y = 0; y < this.height; y += 1) for (let x = 0; x < this.width; x += 1) {
        const a = .31 * Math.sin(TAU * x / this.width), b = .23 * Math.cos(TAU * y / this.height), c = .19 * Math.sin(TAU * (x + y) / this.width), d = .17 * Math.cos(TAU * (2 * x - y) / this.height);
        matrices[this.index(x, y)] = matrixMultiply(matrixMultiply(matrixMultiply(su3R12(a), su3R23(b)), su3Diagonal(c, d)), su3R12(.13 * Math.sin(TAU * y / this.height)));
      }
      return matrices;
    }
    gaugeTransform() {
      const copy = this.clone(), gauge = this.gaugeMatrices(); copy.localX = new Array(this.size); copy.localY = new Array(this.size);
      for (let y = 0; y < this.height; y += 1) for (let x = 0; x < this.width; x += 1) { const i = this.index(x, y), g = gauge[i]; copy.setVector(i, matrixVector(g, copy.vector(i))); copy.localX[i] = matrixMultiply(matrixMultiply(g, this.link('x', i)), matrixDagger(gauge[this.index(x + 1, y)])); copy.localY[i] = matrixMultiply(matrixMultiply(g, this.link('y', i)), matrixDagger(gauge[this.index(x, y + 1)])); }
      return copy;
    }
    gaugeCovarianceResidual(steps = 5) { const base = this.clone(), transformed = this.gaugeTransform(); base.step(steps); transformed.step(steps); const expected = base.gaugeTransform(); let result = 0; for (let k = 0; k < 3; k += 1) for (let i = 0; i < this.size; i += 1) result = Math.max(result, Math.abs(expected.re[k][i] - transformed.re[k][i]), Math.abs(expected.im[k][i] - transformed.im[k][i])); return result; }
    colourSingletResidual(steps = 9) {
      const trio = [0, 1, 2].map((basis) => { const engine = new SU3ColorTransportEngine(this.width, this.height); engine.seedPacket(basis); return engine; });
      const transformed = trio.map((engine) => engine.gaugeTransform());
      for (const engine of [...trio, ...transformed]) engine.step(steps);
      let selected = 0, magnitude = 0, before = null;
      for (let index = 0; index < this.size; index += 1) {
        const matrix = matrixIdentity();
        for (let row = 0; row < 3; row += 1) for (let column = 0; column < 3; column += 1) { matrix.re[row * 3 + column] = trio[column].re[row][index]; matrix.im[row * 3 + column] = trio[column].im[row][index]; }
        const determinant = matrixDet(matrix), candidate = Math.hypot(determinant.re, determinant.im);
        if (candidate > magnitude) { selected = index; magnitude = candidate; before = determinant; }
      }
      const afterMatrix = matrixIdentity();
      for (let row = 0; row < 3; row += 1) for (let column = 0; column < 3; column += 1) { afterMatrix.re[row * 3 + column] = transformed[column].re[row][selected]; afterMatrix.im[row * 3 + column] = transformed[column].im[row][selected]; }
      const after = matrixDet(afterMatrix);
      return { residual: Math.hypot(before.re - after.re, before.im - after.im), magnitude };
    }
    plaquetteGaugeResidual() { const before = this.plaquetteTrace(), after = this.gaugeTransform().plaquetteTrace(); return Math.hypot(before.re - after.re, before.im - after.im); }
    wilsonLoopGaugeResidual() { const before = this.wilsonLoopTrace(2, 1), after = this.gaugeTransform().wilsonLoopTrace(2, 1); return Math.hypot(before.re - after.re, before.im - after.im); }
    audit(read) { return Math.abs(read.norm - this.baseline.norm) < 3e-11 ? 'PASS · SU(3) link transport' : 'WATCH · norm residual'; }
  }

  return { TAU, mod, wrap, U1FluxRingEngine, SU3ColorTransportEngine, matrixIdentity, matrixClone, matrixMultiply, matrixDagger, matrixVector, matrixTrace, matrixDet, su3R12, su3R23, su3Diagonal, maxMatrixDifference };
})();

if (typeof module !== 'undefined') module.exports = GaugeCarriers;
