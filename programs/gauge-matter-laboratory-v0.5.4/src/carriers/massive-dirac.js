/* Clear Onyx v0.4.2 — 2+1D finite massive Dirac carrier.
 * H(k) = k_x sigma_x + k_y sigma_y + m sigma_z.
 * Browser and Node compatible; no dependencies.
 */
'use strict';

const MassiveDiracCore = (() => {
  const TAU = Math.PI * 2;
  const mod = (value, divisor) => ((value % divisor) + divisor) % divisor;

  function fft1d(re, im, inverse) {
    const n = re.length;
    for (let i = 1, j = 0; i < n; i += 1) {
      let bit = n >> 1;
      for (; j & bit; bit >>= 1) j ^= bit;
      j ^= bit;
      if (i < j) { [re[i], re[j]] = [re[j], re[i]]; [im[i], im[j]] = [im[j], im[i]]; }
    }
    for (let length = 2; length <= n; length <<= 1) {
      const angle = (inverse ? TAU : -TAU) / length;
      const sr = Math.cos(angle), si = Math.sin(angle);
      for (let start = 0; start < n; start += length) {
        let wr = 1, wi = 0;
        const half = length >> 1;
        for (let offset = 0; offset < half; offset += 1) {
          const even = start + offset, odd = even + half;
          const or = re[odd] * wr - im[odd] * wi;
          const oi = re[odd] * wi + im[odd] * wr;
          const er = re[even], ei = im[even];
          re[even] = er + or; im[even] = ei + oi;
          re[odd] = er - or; im[odd] = ei - oi;
          const nr = wr * sr - wi * si;
          wi = wr * si + wi * sr; wr = nr;
        }
      }
    }
    if (inverse) for (let i = 0; i < n; i += 1) { re[i] /= n; im[i] /= n; }
  }

  function fft2d(re, im, width, height, inverse) {
    const rowRe = new Float64Array(width), rowIm = new Float64Array(width);
    for (let y = 0; y < height; y += 1) {
      const base = y * width;
      for (let x = 0; x < width; x += 1) { rowRe[x] = re[base + x]; rowIm[x] = im[base + x]; }
      fft1d(rowRe, rowIm, inverse);
      for (let x = 0; x < width; x += 1) { re[base + x] = rowRe[x]; im[base + x] = rowIm[x]; }
    }
    const colRe = new Float64Array(height), colIm = new Float64Array(height);
    for (let x = 0; x < width; x += 1) {
      for (let y = 0; y < height; y += 1) { const i = y * width + x; colRe[y] = re[i]; colIm[y] = im[i]; }
      fft1d(colRe, colIm, inverse);
      for (let y = 0; y < height; y += 1) { const i = y * width + x; re[i] = colRe[y]; im[i] = colIm[y]; }
    }
  }

  function energy(kx, ky, mass) { return Math.hypot(kx, ky, mass); }

  // Normalized eigenvectors of d.sigma. Values are [aRe,aIm,bRe,bIm].
  function eigenSpinor(kx, ky, mass, branch = 1) {
    const e = energy(kx, ky, mass);
    const transverse = Math.hypot(kx, ky);
    if (transverse < 1e-13) {
      return branch > 0 ? (mass >= 0 ? [1, 0, 0, 0] : [0, 0, 1, 0]) : (mass >= 0 ? [0, 0, 1, 0] : [1, 0, 0, 0]);
    }
    const cosHalf = Math.sqrt((e + mass) / (2 * e));
    const sinHalf = Math.sqrt((e - mass) / (2 * e));
    const phaseRe = kx / transverse, phaseIm = ky / transverse;
    if (branch > 0) return [cosHalf, 0, phaseRe * sinHalf, phaseIm * sinHalf];
    return [-phaseRe * sinHalf, phaseIm * sinHalf, cosHalf, 0];
  }

  function modeStep(vector, kx, ky, mass, dt) {
    const [aRe, aIm, bRe, bIm] = vector;
    const e = energy(kx, ky, mass);
    const c = Math.cos(e * dt), s = Math.sin(e * dt) / e;
    const hARe = mass * aRe + kx * bRe + ky * bIm;
    const hAIm = mass * aIm + kx * bIm - ky * bRe;
    const hBRe = kx * aRe - ky * aIm - mass * bRe;
    const hBIm = kx * aIm + ky * aRe - mass * bIm;
    return [c * aRe + s * hAIm, c * aIm - s * hARe, c * bRe + s * hBIm, c * bIm - s * hBRe];
  }

  function inner(left, right) {
    return {
      re: left[0] * right[0] + left[1] * right[1] + left[2] * right[2] + left[3] * right[3],
      im: left[0] * right[1] - left[1] * right[0] + left[2] * right[3] - left[3] * right[2]
    };
  }

  function normVector(vector) { return vector[0] ** 2 + vector[1] ** 2 + vector[2] ** 2 + vector[3] ** 2; }

  // In this 2+1D representation use C = sigma_x K. It maps a mode at k to
  // the charge-conjugate mode at -k while retaining the mass representation.
  function chargeConjugate(vector) { return [vector[2], -vector[3], vector[0], -vector[1]]; }

  function sigmaRead(vector) {
    const [aRe, aIm, bRe, bIm] = vector;
    const norm = normVector(vector) || 1;
    return {
      x: 2 * (aRe * bRe + aIm * bIm) / norm,
      y: 2 * (aRe * bIm - aIm * bRe) / norm,
      z: (aRe ** 2 + aIm ** 2 - bRe ** 2 - bIm ** 2) / norm
    };
  }

  class MassiveDiracEngine {
    constructor(width = 128, height = 128, mass = .74) {
      if ((width & (width - 1)) || (height & (height - 1))) throw new Error('width and height must be powers of two');
      this.width = width; this.height = height; this.size = width * height; this.mass = mass;
      this.aRe = new Float64Array(this.size); this.aIm = new Float64Array(this.size);
      this.bRe = new Float64Array(this.size); this.bIm = new Float64Array(this.size);
      this.frame = 0; this.seedPacket(); this.baseline = this.read();
    }

    seedPacket() {
      const cx = this.width * .27, cy = this.height * .50, spread = Math.min(this.width, this.height) * .085;
      const kx = .48, ky = .12;
      const u = eigenSpinor(kx, ky, this.mass, 1);
      let norm = 0;
      for (let y = 0; y < this.height; y += 1) for (let x = 0; x < this.width; x += 1) {
        const i = y * this.width + x;
        const envelope = Math.exp(-((x - cx) ** 2 + (y - cy) ** 2) / (2 * spread * spread));
        const phase = kx * (x - cx) + ky * (y - cy);
        const cr = Math.cos(phase), ci = Math.sin(phase);
        this.aRe[i] = envelope * (u[0] * cr - u[1] * ci); this.aIm[i] = envelope * (u[0] * ci + u[1] * cr);
        this.bRe[i] = envelope * (u[2] * cr - u[3] * ci); this.bIm[i] = envelope * (u[2] * ci + u[3] * cr);
        norm += this.aRe[i] ** 2 + this.aIm[i] ** 2 + this.bRe[i] ** 2 + this.bIm[i] ** 2;
      }
      const scale = 1 / Math.sqrt(norm);
      for (const array of [this.aRe, this.aIm, this.bRe, this.bIm]) for (let i = 0; i < this.size; i += 1) array[i] *= scale;
      this.frame = 0;
    }

    setPlaneWave(nx = 5, ny = 3, branch = 1) {
      const kx = TAU * nx / this.width, ky = TAU * ny / this.height;
      const u = eigenSpinor(kx, ky, this.mass, branch);
      const scale = 1 / Math.sqrt(this.size);
      for (let y = 0; y < this.height; y += 1) for (let x = 0; x < this.width; x += 1) {
        const i = y * this.width + x;
        const phase = kx * x + ky * y, cr = Math.cos(phase), ci = Math.sin(phase);
        this.aRe[i] = scale * (u[0] * cr - u[1] * ci); this.aIm[i] = scale * (u[0] * ci + u[1] * cr);
        this.bRe[i] = scale * (u[2] * cr - u[3] * ci); this.bIm[i] = scale * (u[2] * ci + u[3] * cr);
      }
      this.frame = 0; this.baseline = this.read();
      return { kx, ky };
    }

    step(dt = .05) {
      for (const pair of [[this.aRe, this.aIm], [this.bRe, this.bIm]]) fft2d(pair[0], pair[1], this.width, this.height, false);
      for (let y = 0; y < this.height; y += 1) {
        const ky = TAU * (y <= this.height / 2 ? y : y - this.height) / this.height;
        for (let x = 0; x < this.width; x += 1) {
          const kx = TAU * (x <= this.width / 2 ? x : x - this.width) / this.width;
          const i = y * this.width + x;
          const next = modeStep([this.aRe[i], this.aIm[i], this.bRe[i], this.bIm[i]], kx, ky, this.mass, dt);
          this.aRe[i] = next[0]; this.aIm[i] = next[1]; this.bRe[i] = next[2]; this.bIm[i] = next[3];
        }
      }
      for (const pair of [[this.aRe, this.aIm], [this.bRe, this.bIm]]) fft2d(pair[0], pair[1], this.width, this.height, true);
      this.frame += 1;
    }

    read() {
      let norm = 0, sx = 0, sy = 0, sz = 0, xMoment = 0, yMoment = 0;
      for (let y = 0; y < this.height; y += 1) for (let x = 0; x < this.width; x += 1) {
        const i = y * this.width + x;
        const density = this.aRe[i] ** 2 + this.aIm[i] ** 2 + this.bRe[i] ** 2 + this.bIm[i] ** 2;
        norm += density; xMoment += x * density; yMoment += y * density;
        sx += 2 * (this.aRe[i] * this.bRe[i] + this.aIm[i] * this.bIm[i]);
        sy += 2 * (this.aRe[i] * this.bIm[i] - this.aIm[i] * this.bRe[i]);
        sz += this.aRe[i] ** 2 + this.aIm[i] ** 2 - this.bRe[i] ** 2 - this.bIm[i] ** 2;
      }
      return { norm, spin: { x: sx / norm, y: sy / norm, z: sz / norm }, centroid: { x: xMoment / norm / this.width, y: yMoment / norm / this.height } };
    }

    visualAt(index) {
      const density = this.aRe[index] ** 2 + this.aIm[index] ** 2 + this.bRe[index] ** 2 + this.bIm[index] ** 2;
      return { density, phase: Math.atan2(this.aIm[index] + this.bIm[index], this.aRe[index] + this.bRe[index]), spin: sigmaRead([this.aRe[index], this.aIm[index], this.bRe[index], this.bIm[index]]) };
    }

    clone() {
      const copy = new MassiveDiracEngine(this.width, this.height, this.mass);
      for (const key of ['aRe', 'aIm', 'bRe', 'bIm']) copy[key].set(this[key]);
      copy.frame = this.frame; copy.baseline = copy.read();
      return copy;
    }

    chargeConjugate() {
      const out = this.clone();
      for (let i = 0; i < this.size; i += 1) {
        out.aRe[i] = this.bRe[i]; out.aIm[i] = -this.bIm[i];
        out.bRe[i] = this.aRe[i]; out.bIm[i] = -this.aIm[i];
      }
      return out;
    }
  }

  function planeWave(width, height, mass, nx, ny, branch) {
    const kx = TAU * nx / width, ky = TAU * ny / height;
    const spinor = eigenSpinor(kx, ky, mass, branch);
    const vector = spinor.map((value) => value / Math.sqrt(width * height));
    return { kx, ky, spinor, vector };
  }

  function phaseEnergyMeasurement(kx, ky, mass, branch, dt = .037) {
    const initial = eigenSpinor(kx, ky, mass, branch);
    const next = modeStep(initial, kx, ky, mass, dt);
    const overlap = inner(initial, next);
    const measured = -Math.atan2(overlap.im, overlap.re) / dt;
    return { measured, expected: branch * energy(kx, ky, mass), residual: measured - branch * energy(kx, ky, mass) };
  }

  function zitterbewegungMeasurement(kx, ky, mass, dt = .035) {
    const plus = eigenSpinor(kx, ky, mass, 1), minus = eigenSpinor(kx, ky, mass, -1);
    const root = Math.SQRT1_2;
    const initial = plus.map((value, i) => root * (value + minus[i]));
    const next = modeStep(initial, kx, ky, mass, dt);
    const project = (state, basis) => inner(basis, state);
    const p0 = project(initial, plus), m0 = project(initial, minus);
    const p1 = project(next, plus), m1 = project(next, minus);
    const coherence = (p, m) => ({ re: p.re * m.re + p.im * m.im, im: p.re * m.im - p.im * m.re });
    const c0 = coherence(p0, m0), c1 = coherence(p1, m1);
    const ratio = { re: c1.re * c0.re + c1.im * c0.im, im: c1.im * c0.re - c1.re * c0.im };
    const measuredFrequency = Math.atan2(ratio.im, ratio.re) / dt;
    const v0 = sigmaRead(initial).x, v1 = sigmaRead(next).x;
    return { measuredFrequency, expectedFrequency: 2 * energy(kx, ky, mass), residual: measuredFrequency - 2 * energy(kx, ky, mass), velocityChange: v1 - v0 };
  }

  function maxDifference(left, right) {
    let max = 0;
    for (let i = 0; i < left.size; i += 1) {
      max = Math.max(max, Math.abs(left.aRe[i] - right.aRe[i]), Math.abs(left.aIm[i] - right.aIm[i]), Math.abs(left.bRe[i] - right.bRe[i]), Math.abs(left.bIm[i] - right.bIm[i]));
    }
    return max;
  }

  return { TAU, MassiveDiracEngine, fft1d, fft2d, energy, eigenSpinor, modeStep, inner, normVector, chargeConjugate, sigmaRead, planeWave, phaseEnergyMeasurement, zitterbewegungMeasurement, maxDifference, mod };
})();

if (typeof module !== 'undefined') module.exports = MassiveDiracCore;
