/* Clear Onyx Gauge Laboratory v0.5.2 — finite field, gauge, and matter carriers.
 * Browser and Node compatible. No external dependencies.
 */
'use strict';

const ParticleAtlasCore = (() => {
  const Phi4Core = typeof module !== 'undefined' ? require('./carriers/complex-phi4.js') : ComplexPhi4;
  const OscillationCore = typeof module !== 'undefined' ? require('./carriers/two-flavour-neutrino.js') : TwoFlavourNeutrino;
  const DiracCore = typeof module !== 'undefined' ? require('./carriers/massive-dirac.js') : MassiveDiracCore;
  const GaugeCore = typeof module !== 'undefined' ? require('./carriers/gauge.js') : GaugeCarriers;
  const ElectroweakCore = typeof module !== 'undefined' ? require('./carriers/electroweak-higgs.js') : ElectroweakHiggs;
  const TAU = Math.PI * 2;
  const clamp = (value, low, high) => Math.min(high, Math.max(low, value));
  const mod = (value, divisor) => ((value % divisor) + divisor) % divisor;
  const indexAt = (x, y, width, height) => mod(y, height) * width + mod(x, width);
  const signed = (value, places = 3) => `${value >= 0 ? '+' : '−'}${Math.abs(value).toFixed(places)}`;

  function fft1d(re, im, inverse) {
    const n = re.length;
    for (let i = 1, j = 0; i < n; i += 1) {
      let bit = n >> 1;
      for (; j & bit; bit >>= 1) j ^= bit;
      j ^= bit;
      if (i < j) {
        [re[i], re[j]] = [re[j], re[i]];
        [im[i], im[j]] = [im[j], im[i]];
      }
    }
    for (let length = 2; length <= n; length <<= 1) {
      const angle = (inverse ? TAU : -TAU) / length;
      const stepRe = Math.cos(angle);
      const stepIm = Math.sin(angle);
      for (let start = 0; start < n; start += length) {
        let unitRe = 1;
        let unitIm = 0;
        const half = length >> 1;
        for (let offset = 0; offset < half; offset += 1) {
          const even = start + offset;
          const odd = even + half;
          const oddRe = re[odd] * unitRe - im[odd] * unitIm;
          const oddIm = re[odd] * unitIm + im[odd] * unitRe;
          const evenRe = re[even];
          const evenIm = im[even];
          re[even] = evenRe + oddRe;
          im[even] = evenIm + oddIm;
          re[odd] = evenRe - oddRe;
          im[odd] = evenIm - oddIm;
          const nextRe = unitRe * stepRe - unitIm * stepIm;
          unitIm = unitRe * stepIm + unitIm * stepRe;
          unitRe = nextRe;
        }
      }
    }
    if (inverse) {
      for (let i = 0; i < n; i += 1) {
        re[i] /= n;
        im[i] /= n;
      }
    }
  }

  function fft2d(re, im, width, height, inverse) {
    const rowRe = new Float64Array(width);
    const rowIm = new Float64Array(width);
    for (let y = 0; y < height; y += 1) {
      const base = y * width;
      for (let x = 0; x < width; x += 1) {
        rowRe[x] = re[base + x];
        rowIm[x] = im[base + x];
      }
      fft1d(rowRe, rowIm, inverse);
      for (let x = 0; x < width; x += 1) {
        re[base + x] = rowRe[x];
        im[base + x] = rowIm[x];
      }
    }
    const columnRe = new Float64Array(height);
    const columnIm = new Float64Array(height);
    for (let x = 0; x < width; x += 1) {
      for (let y = 0; y < height; y += 1) {
        const index = y * width + x;
        columnRe[y] = re[index];
        columnIm[y] = im[index];
      }
      fft1d(columnRe, columnIm, inverse);
      for (let y = 0; y < height; y += 1) {
        const index = y * width + x;
        re[index] = columnRe[y];
        im[index] = columnIm[y];
      }
    }
  }

  function multiplyPhase(re, im, phase) {
    const cosine = Math.cos(phase);
    const sine = Math.sin(phase);
    const nextRe = re * cosine - im * sine;
    return [nextRe, re * sine + im * cosine];
  }

  function spinNorm(state) {
    let sum = 0;
    for (let i = 0; i < state.size; i += 1) {
      sum += state.aRe[i] ** 2 + state.aIm[i] ** 2 + state.bRe[i] ** 2 + state.bIm[i] ** 2;
    }
    return sum;
  }

  function scaleSpin(state, scale) {
    for (const key of ['aRe', 'aIm', 'bRe', 'bIm']) {
      const array = state[key];
      for (let i = 0; i < array.length; i += 1) array[i] *= scale;
    }
  }

  function spinRead(state) {
    const { width, height, size, aRe, aIm, bRe, bIm } = state;
    let norm = 0;
    let sx = 0;
    let sy = 0;
    let sz = 0;
    let energyWeight = 0;
    let xMoment = 0;
    let yMoment = 0;
    let currentX = 0;
    let currentY = 0;
    for (let y = 0; y < height; y += 1) {
      for (let x = 0; x < width; x += 1) {
        const index = y * width + x;
        const density = aRe[index] ** 2 + aIm[index] ** 2 + bRe[index] ** 2 + bIm[index] ** 2;
        const abRe = aRe[index] * bRe[index] + aIm[index] * bIm[index];
        const abIm = aRe[index] * bIm[index] - aIm[index] * bRe[index];
        norm += density;
        sx += 2 * abRe;
        sy += 2 * abIm;
        sz += aRe[index] ** 2 + aIm[index] ** 2 - bRe[index] ** 2 - bIm[index] ** 2;
        const right = indexAt(x + 1, y, width, height);
        const left = indexAt(x - 1, y, width, height);
        const down = indexAt(x, y + 1, width, height);
        const up = indexAt(x, y - 1, width, height);
        const gradAxRe = (aRe[right] - aRe[left]) * .5;
        const gradAxIm = (aIm[right] - aIm[left]) * .5;
        const gradBxRe = (bRe[right] - bRe[left]) * .5;
        const gradBxIm = (bIm[right] - bIm[left]) * .5;
        const gradAyRe = (aRe[down] - aRe[up]) * .5;
        const gradAyIm = (aIm[down] - aIm[up]) * .5;
        const gradByRe = (bRe[down] - bRe[up]) * .5;
        const gradByIm = (bIm[down] - bIm[up]) * .5;
        const jx = aRe[index] * gradAxIm - aIm[index] * gradAxRe + bRe[index] * gradBxIm - bIm[index] * gradBxRe;
        const jy = aRe[index] * gradAyIm - aIm[index] * gradAyRe + bRe[index] * gradByIm - bIm[index] * gradByRe;
        const localEnergy = .5 * (gradAxRe ** 2 + gradAxIm ** 2 + gradBxRe ** 2 + gradBxIm ** 2 + gradAyRe ** 2 + gradAyIm ** 2 + gradByRe ** 2 + gradByIm ** 2);
        currentX += jx;
        currentY += jy;
        energyWeight += localEnergy;
        xMoment += x * density;
        yMoment += y * density;
      }
    }
    const safeNorm = norm || 1;
    return {
      norm,
      density: norm / size,
      spin: { x: sx / safeNorm, y: sy / safeNorm, z: sz / safeNorm },
      spinLength: Math.hypot(sx / safeNorm, sy / safeNorm, sz / safeNorm),
      current: state.type === 'neutrino' ? { x: sx / safeNorm, y: sy / safeNorm } : { x: currentX / safeNorm, y: currentY / safeNorm },
      energyProxy: energyWeight,
      centroid: { x: xMoment / safeNorm / width, y: yMoment / safeNorm / height }
    };
  }

  class SpinorEngine {
    constructor(type, width = 128, height = 128) {
      this.type = type;
      this.width = width;
      this.height = height;
      this.size = width * height;
      this.aRe = new Float64Array(this.size);
      this.aIm = new Float64Array(this.size);
      this.bRe = new Float64Array(this.size);
      this.bIm = new Float64Array(this.size);
      this.frame = 0;
      this.pulses = [];
      this.phaseDegrees = 0;
      this.zeeman = .15;
      this.seed();
    }

    seed() {
      const { width, height } = this;
      this.aRe.fill(0); this.aIm.fill(0); this.bRe.fill(0); this.bIm.fill(0);
      const cx = width * .225;
      const cy = height * .50;
      const spread = Math.min(width, height) * .108;
      const kx = this.type === 'neutrino' ? .46 : .61;
      const theta = this.type === 'neutrino' ? Math.PI / 2 : 1.03;
      const up = Math.cos(theta / 2);
      const down = Math.sin(theta / 2);
      for (let y = 0; y < height; y += 1) {
        for (let x = 0; x < width; x += 1) {
          const index = y * width + x;
          const envelope = Math.exp(-((x - cx) ** 2 + (y - cy) ** 2) / (2 * spread * spread));
          const phase = kx * (x - cx) + .035 * (y - cy);
          this.aRe[index] = envelope * up * Math.cos(phase);
          this.aIm[index] = envelope * up * Math.sin(phase);
          this.bRe[index] = envelope * down * Math.cos(phase);
          this.bIm[index] = envelope * down * Math.sin(phase);
        }
      }
      const norm = spinNorm(this);
      scaleSpin(this, 1 / Math.sqrt(norm || 1));
      this.frame = 0;
      this.pulses.length = 0;
      this.phaseDegrees = 0;
      this.baseline = this.read();
    }

    applyPotential(dt) {
      const { width, height } = this;
      const barrierX = width * .565;
      for (let y = 0; y < height; y += 1) {
        for (let x = 0; x < width; x += 1) {
          const index = y * width + x;
          const slitUpper = Math.abs(y - height * .36) < height * .055;
          const slitLower = Math.abs(y - height * .64) < height * .055;
          const barrier = Math.abs(x - barrierX) < 1.4 && !(slitUpper || slitLower) ? 2.85 : 0;
          const localB = this.zeeman * (1 + .17 * Math.tanh((x - width * .53) / 12));
          let pair = multiplyPhase(this.aRe[index], this.aIm[index], -(barrier - localB * .5) * dt);
          this.aRe[index] = pair[0]; this.aIm[index] = pair[1];
          pair = multiplyPhase(this.bRe[index], this.bIm[index], -(barrier + localB * .5) * dt);
          this.bRe[index] = pair[0]; this.bIm[index] = pair[1];
        }
      }
    }

    applyKinetic(dt) {
      const { width, height } = this;
      fft2d(this.aRe, this.aIm, width, height, false);
      fft2d(this.bRe, this.bIm, width, height, false);
      for (let y = 0; y < height; y += 1) {
        const ky = TAU * (y <= height / 2 ? y : y - height) / height;
        for (let x = 0; x < width; x += 1) {
          const kx = TAU * (x <= width / 2 ? x : x - width) / width;
          const index = y * width + x;
          const phase = -.5 * (kx * kx + ky * ky) * dt;
          let pair = multiplyPhase(this.aRe[index], this.aIm[index], phase);
          this.aRe[index] = pair[0]; this.aIm[index] = pair[1];
          pair = multiplyPhase(this.bRe[index], this.bIm[index], phase);
          this.bRe[index] = pair[0]; this.bIm[index] = pair[1];
        }
      }
      fft2d(this.aRe, this.aIm, width, height, true);
      fft2d(this.bRe, this.bIm, width, height, true);
    }

    applyWeyl(dt) {
      const { width, height } = this;
      fft2d(this.aRe, this.aIm, width, height, false);
      fft2d(this.bRe, this.bIm, width, height, false);
      for (let y = 0; y < height; y += 1) {
        const ky = TAU * (y <= height / 2 ? y : y - height) / height;
        for (let x = 0; x < width; x += 1) {
          const kx = TAU * (x <= width / 2 ? x : x - width) / width;
          const index = y * width + x;
          const magnitude = Math.hypot(kx, ky);
          if (magnitude < 1e-12) continue;
          const cosine = Math.cos(magnitude * dt);
          const sineByK = Math.sin(magnitude * dt) / magnitude;
          const aRe = this.aRe[index], aIm = this.aIm[index];
          const bRe = this.bRe[index], bIm = this.bIm[index];
          const offABRe = kx * bRe + ky * bIm;
          const offABIm = kx * bIm - ky * bRe;
          const offBARe = kx * aRe - ky * aIm;
          const offBAIm = kx * aIm + ky * aRe;
          this.aRe[index] = cosine * aRe + sineByK * offABIm;
          this.aIm[index] = cosine * aIm - sineByK * offABRe;
          this.bRe[index] = cosine * bRe + sineByK * offBAIm;
          this.bIm[index] = cosine * bIm - sineByK * offBARe;
        }
      }
      fft2d(this.aRe, this.aIm, width, height, true);
      fft2d(this.bRe, this.bIm, width, height, true);
    }

    step(dt = .052) {
      if (this.type === 'electron') {
        this.applyPotential(dt * .5);
        this.applyKinetic(dt);
        this.applyPotential(dt * .5);
      } else {
        this.applyWeyl(dt * 1.13);
      }
      this.frame += 1;
    }

    rotateGlobal(degrees) {
      const delta = degrees * Math.PI / 180;
      for (const [reName, imName] of [['aRe', 'aIm'], ['bRe', 'bIm']]) {
        const re = this[reName], im = this[imName];
        for (let i = 0; i < this.size; i += 1) {
          const pair = multiplyPhase(re[i], im[i], delta);
          re[i] = pair[0]; im[i] = pair[1];
        }
      }
      this.phaseDegrees = mod(this.phaseDegrees + degrees, 360);
    }

    inject(x = this.width * .5, y = this.height * .5) {
      const spread = Math.min(this.width, this.height) * .052;
      const angle = this.phaseDegrees * Math.PI / 180 + this.pulses.length * .61803398875;
      for (let row = 0; row < this.height; row += 1) {
        for (let col = 0; col < this.width; col += 1) {
          const index = row * this.width + col;
          const envelope = .030 * Math.exp(-((col - x) ** 2 + (row - y) ** 2) / (2 * spread * spread));
          this.aRe[index] += envelope * Math.cos(angle);
          this.aIm[index] += envelope * Math.sin(angle);
          this.bRe[index] += envelope * .54 * Math.cos(angle + .82);
          this.bIm[index] += envelope * .54 * Math.sin(angle + .82);
        }
      }
      this.pulses.push({ x: x / this.width, y: y / this.height, frame: this.frame });
    }

    visualAt(index) {
      const a2 = this.aRe[index] ** 2 + this.aIm[index] ** 2;
      const b2 = this.bRe[index] ** 2 + this.bIm[index] ** 2;
      const density = a2 + b2;
      const phase = Math.atan2(this.aIm[index] + this.bIm[index], this.aRe[index] + this.bRe[index]);
      const sx = density ? 2 * (this.aRe[index] * this.bRe[index] + this.aIm[index] * this.bIm[index]) / density : 0;
      const sy = density ? 2 * (this.aRe[index] * this.bIm[index] - this.aIm[index] * this.bRe[index]) / density : 0;
      const sz = density ? (a2 - b2) / density : 0;
      return { density, phase, spin: { x: sx, y: sy, z: sz } };
    }

    read() {
      return spinRead(this);
    }
  }

  class PhotonEngine {
    constructor(width = 128, height = 128) {
      this.type = 'photon';
      this.width = width;
      this.height = height;
      this.size = width * height;
      this.e = new Float64Array(this.size);
      this.hx = new Float64Array(this.size);
      this.hy = new Float64Array(this.size);
      this.frame = 0;
      this.pulses = [];
      this.seed();
    }

    seed() {
      const { width, height } = this;
      this.e.fill(0); this.hx.fill(0); this.hy.fill(0);
      const cx = width * .23;
      const cy = height * .50;
      const sx = width * .083;
      const sy = height * .13;
      for (let y = 0; y < height; y += 1) {
        for (let x = 0; x < width; x += 1) {
          const index = y * width + x;
          const envelope = Math.exp(-((x - cx) ** 2 / (2 * sx * sx) + (y - cy) ** 2 / (2 * sy * sy)));
          const carrier = Math.cos(.58 * (x - cx));
          this.e[index] = envelope * carrier;
          this.hy[index] = -this.e[index];
        }
      }
      this.frame = 0;
      this.pulses.length = 0;
      this.baseline = this.read();
    }

    step(dt = .29) {
      const { width, height, e, hx, hy } = this;
      for (let y = 0; y < height; y += 1) {
        for (let x = 0; x < width; x += 1) {
          const index = y * width + x;
          const up = indexAt(x, y + 1, width, height);
          const right = indexAt(x + 1, y, width, height);
          hx[index] -= dt * (e[up] - e[index]);
          hy[index] += dt * (e[right] - e[index]);
        }
      }
      for (let y = 0; y < height; y += 1) {
        for (let x = 0; x < width; x += 1) {
          const index = y * width + x;
          const left = indexAt(x - 1, y, width, height);
          const above = indexAt(x, y - 1, width, height);
          e[index] += dt * ((hy[index] - hy[left]) - (hx[index] - hx[above]));
        }
      }
      this.frame += 1;
    }

    inject(x = this.width * .5, y = this.height * .5) {
      const spread = Math.min(this.width, this.height) * .06;
      for (let row = 0; row < this.height; row += 1) {
        for (let col = 0; col < this.width; col += 1) {
          const index = row * this.width + col;
          const pulse = .18 * Math.exp(-((col - x) ** 2 + (row - y) ** 2) / (2 * spread * spread));
          this.e[index] += pulse;
          this.hy[index] -= pulse;
        }
      }
      this.pulses.push({ x: x / this.width, y: y / this.height, frame: this.frame });
    }

    visualAt(index) {
      const e = this.e[index], hx = this.hx[index], hy = this.hy[index], density = e * e + hx * hx + hy * hy, safeDensity = density || 1;
      return { density, phase: Math.atan2(-hy, e), spin: { x: (e * e - hy * hy) / safeDensity, y: 2 * e * hy / safeDensity, z: 2 * e * hx / safeDensity } };
    }

    read() {
      let energy = 0;
      let px = 0;
      let py = 0;
      let qx = 0;
      let qy = 0;
      let qz = 0;
      for (let i = 0; i < this.size; i += 1) {
        energy += .5 * (this.e[i] ** 2 + this.hx[i] ** 2 + this.hy[i] ** 2);
        px += -this.e[i] * this.hy[i];
        py += this.e[i] * this.hx[i];
        qx += this.e[i] ** 2 - this.hy[i] ** 2;
        qy += 2 * this.e[i] * this.hy[i];
        qz += 2 * this.e[i] * this.hx[i];
      }
      const fieldNorm = 2 * energy || 1;
      return { norm: energy, energyProxy: energy, current: { x: px / (energy || 1), y: py / (energy || 1) }, spin: { x: qx / fieldNorm, y: qy / fieldNorm, z: qz / fieldNorm }, spinLength: Math.hypot(qx, qy, qz) / fieldNorm };
    }
  }

  class ScalarEngine {
    constructor(width = 128, height = 128) {
      this.type = 'scalar';
      this.width = width;
      this.height = height;
      this.size = width * height;
      this.reNow = new Float64Array(this.size);
      this.imNow = new Float64Array(this.size);
      this.rePrev = new Float64Array(this.size);
      this.imPrev = new Float64Array(this.size);
      this.reNext = new Float64Array(this.size);
      this.imNext = new Float64Array(this.size);
      this.c2 = .152;
      this.m2 = .005;
      this.frame = 0;
      this.pulses = [];
      this.phaseDegrees = 0;
      this.seed();
    }

    seed() {
      const { width, height } = this;
      this.reNow.fill(0); this.imNow.fill(0); this.rePrev.fill(0); this.imPrev.fill(0);
      const cxA = width * .32, cyA = height * .44;
      const cxB = width * .68, cyB = height * .57;
      for (let y = 0; y < height; y += 1) {
        for (let x = 0; x < width; x += 1) {
          const index = y * width + x;
          const a = Math.exp(-((x - cxA) ** 2 + (y - cyA) ** 2) / 142);
          const b = .85 * Math.exp(-((x - cxB) ** 2 + (y - cyB) ** 2) / 176);
          const phaseA = .27 * (x - cxA) + .10 * (y - cyA);
          const phaseB = -.22 * (x - cxB) + .12 * (y - cyB) + 2.5;
          this.reNow[index] = a * Math.cos(phaseA) + b * Math.cos(phaseB);
          this.imNow[index] = a * Math.sin(phaseA) + b * Math.sin(phaseB);
          this.rePrev[index] = a * Math.cos(phaseA + .34) + b * Math.cos(phaseB + .34);
          this.imPrev[index] = a * Math.sin(phaseA + .34) + b * Math.sin(phaseB + .34);
        }
      }
      this.frame = 0;
      this.pulses.length = 0;
      this.phaseDegrees = 0;
      this.baseline = this.read();
    }

    step() {
      const { width, height, c2, m2, reNow, imNow, rePrev, imPrev, reNext, imNext } = this;
      for (let y = 0; y < height; y += 1) {
        for (let x = 0; x < width; x += 1) {
          const index = y * width + x;
          const right = indexAt(x + 1, y, width, height);
          const left = indexAt(x - 1, y, width, height);
          const down = indexAt(x, y + 1, width, height);
          const up = indexAt(x, y - 1, width, height);
          reNext[index] = 2 * reNow[index] - rePrev[index] + c2 * (reNow[right] + reNow[left] + reNow[down] + reNow[up] - 4 * reNow[index]) - m2 * reNow[index];
          imNext[index] = 2 * imNow[index] - imPrev[index] + c2 * (imNow[right] + imNow[left] + imNow[down] + imNow[up] - 4 * imNow[index]) - m2 * imNow[index];
        }
      }
      this.rePrev = this.reNow; this.imPrev = this.imNow;
      this.reNow = this.reNext; this.imNow = this.imNext;
      this.reNext = this.rePrev; this.imNext = this.imPrev;
      this.frame += 1;
    }

    rotateGlobal(degrees) {
      const angle = degrees * Math.PI / 180;
      for (const [reName, imName] of [['reNow', 'imNow'], ['rePrev', 'imPrev']]) {
        const re = this[reName], im = this[imName];
        for (let i = 0; i < this.size; i += 1) {
          const pair = multiplyPhase(re[i], im[i], angle);
          re[i] = pair[0]; im[i] = pair[1];
        }
      }
      this.phaseDegrees = mod(this.phaseDegrees + degrees, 360);
    }

    inject(x = this.width * .5, y = this.height * .5) {
      const spread = Math.min(this.width, this.height) * .06;
      const phase = this.phaseDegrees * Math.PI / 180 + this.pulses.length * .618;
      for (let row = 0; row < this.height; row += 1) {
        for (let col = 0; col < this.width; col += 1) {
          const index = row * this.width + col;
          const amplitude = .55 * Math.exp(-((col - x) ** 2 + (row - y) ** 2) / (2 * spread * spread));
          this.reNow[index] += amplitude * Math.cos(phase);
          this.imNow[index] += amplitude * Math.sin(phase);
          this.rePrev[index] += amplitude * Math.cos(phase + .22);
          this.imPrev[index] += amplitude * Math.sin(phase + .22);
        }
      }
      this.pulses.push({ x: x / this.width, y: y / this.height, frame: this.frame });
    }

    visualAt(index) {
      const re = this.reNow[index], im = this.imNow[index];
      return { density: re * re + im * im, phase: Math.atan2(im, re), spin: { x: 0, y: 0, z: 0 } };
    }

    read() {
      const { width, height, reNow, imNow, rePrev, imPrev, c2, m2 } = this;
      let charge = 0;
      let energy = 0;
      let totalDensity = 0;
      let meanRe = 0;
      let meanIm = 0;
      for (let y = 0; y < height; y += 1) {
        for (let x = 0; x < width; x += 1) {
          const index = y * width + x;
          const right = indexAt(x + 1, y, width, height);
          const left = indexAt(x - 1, y, width, height);
          const down = indexAt(x, y + 1, width, height);
          const up = indexAt(x, y - 1, width, height);
          const vr = reNow[index] - rePrev[index];
          const vi = imNow[index] - imPrev[index];
          const gxR = (reNow[right] - reNow[left]) * .5;
          const gxI = (imNow[right] - imNow[left]) * .5;
          const gyR = (reNow[down] - reNow[up]) * .5;
          const gyI = (imNow[down] - imNow[up]) * .5;
          const density = reNow[index] ** 2 + imNow[index] ** 2;
          totalDensity += density;
          meanRe += reNow[index];
          meanIm += imNow[index];
          charge += reNow[index] * vi - imNow[index] * vr;
          energy += .5 * (vr * vr + vi * vi + c2 * (gxR * gxR + gxI * gxI + gyR * gyR + gyI * gyI) + m2 * density);
        }
      }
      const coherenceScale = Math.sqrt(Math.max(totalDensity * this.size, 1e-12));
      return { norm: charge, charge, energyProxy: energy, current: { x: 0, y: 0 }, spin: { x: meanRe / coherenceScale, y: meanIm / coherenceScale, z: Math.tanh(charge / Math.sqrt(Math.max(totalDensity, 1e-12))) }, spinLength: Math.hypot(meanRe / coherenceScale, meanIm / coherenceScale, Math.tanh(charge / Math.sqrt(Math.max(totalDensity, 1e-12)))) };
    }
  }

  // The memory field keeps the previously separate Noether–Klein visual
  // carrier inside the shared reader. Its field law remains a complex scalar
  // update; the retained samples are a display receipt, not a physical-memory
  // measurement.
  class NoetherKleinEngine extends ScalarEngine {
    constructor(width = 160, height = 112) {
      super(width, height);
      this.type = 'noether';
      this.c2 = .160;
      this.m2 = .004;
      this.memoryLimit = 156;
      this.seed();
    }

    packet(x, y, cx, cy, spread, kx, ky, phaseOffset, amplitude) {
      const dx = x - cx;
      const dy = y - cy;
      const envelope = amplitude * Math.exp(-(dx * dx + dy * dy) / (2 * spread * spread));
      const theta = kx * dx + ky * dy + phaseOffset;
      const omega = Math.sqrt(this.m2 + 4 * this.c2 * (Math.sin(kx / 2) ** 2 + Math.sin(ky / 2) ** 2));
      return { envelope, theta, omega };
    }

    seed() {
      const { width, height, reNow, imNow, rePrev, imPrev } = this;
      reNow.fill(0); imNow.fill(0); rePrev.fill(0); imPrev.fill(0);
      for (let y = 0; y < height; y += 1) {
        for (let x = 0; x < width; x += 1) {
          const a = this.packet(x, y, width * .30, height * .46, Math.min(width, height) * .094, .24, .085, .15, .96);
          const b = this.packet(x, y, width * .70, height * .56, Math.min(width, height) * .105, -.20, .115, Math.PI * .83, .88);
          const ringDistance = Math.hypot(x - width * .50, y - height * .50);
          const ringEnvelope = .13 * Math.exp(-((ringDistance - Math.min(width, height) * .18) ** 2) / (Math.min(width, height) * .42));
          const ringTheta = ringDistance * .42 - .7;
          const ringOmega = Math.sqrt(this.m2 + 4 * this.c2 * Math.sin(.42 / 2) ** 2);
          const index = y * width + x;
          reNow[index] = a.envelope * Math.cos(a.theta) + b.envelope * Math.cos(b.theta) + ringEnvelope * Math.cos(ringTheta);
          imNow[index] = a.envelope * Math.sin(a.theta) + b.envelope * Math.sin(b.theta) + ringEnvelope * Math.sin(ringTheta);
          rePrev[index] = a.envelope * Math.cos(a.theta + a.omega) + b.envelope * Math.cos(b.theta + b.omega) + ringEnvelope * Math.cos(ringTheta + ringOmega);
          imPrev[index] = a.envelope * Math.sin(a.theta + a.omega) + b.envelope * Math.sin(b.theta + b.omega) + ringEnvelope * Math.sin(ringTheta + ringOmega);
        }
      }
      this.frame = 0;
      this.pulses = [];
      this.phaseDegrees = 0;
      this.memory = [];
      this.baseline = this.read();
      this.retainMemory(true);
    }

    retainMemory(force = false) {
      if (!force && this.frame % 3 !== 0) return;
      const m = this.read();
      this.memory.push({ frame: this.frame, phase: m.probePhase, charge: m.charge, energy: m.energyProxy, x: m.centroid.x, y: m.centroid.y, centroidResolved: m.centroid.resolved });
      const limit = this.memoryLimit || 156;
      if (this.memory.length > limit) this.memory.shift();
    }

    step() {
      super.step();
      this.retainMemory();
    }

    inject(x = this.width * .5, y = this.height * .5) {
      super.inject(x, y);
      this.baseline = this.read();
      this.retainMemory(true);
    }

    circularCentroid() {
      let total = 0;
      let xCos = 0;
      let xSin = 0;
      let yCos = 0;
      let ySin = 0;
      for (let y = 0; y < this.height; y += 1) {
        for (let x = 0; x < this.width; x += 1) {
          const index = y * this.width + x;
          const density = this.reNow[index] ** 2 + this.imNow[index] ** 2;
          total += density;
          xCos += density * Math.cos(TAU * x / this.width);
          xSin += density * Math.sin(TAU * x / this.width);
          yCos += density * Math.cos(TAU * y / this.height);
          ySin += density * Math.sin(TAU * y / this.height);
        }
      }
      const safeTotal = total || 1;
      const xResultant = Math.hypot(xCos, xSin) / safeTotal;
      const yResultant = Math.hypot(yCos, ySin) / safeTotal;
      if (!Number.isFinite(xResultant) || !Number.isFinite(yResultant) || xResultant < 1e-8 || yResultant < 1e-8) return { x: null, y: null, resolved: false, xResultant, yResultant };
      return { x: mod(Math.atan2(xSin, xCos) / TAU, 1), y: mod(Math.atan2(ySin, yCos) / TAU, 1), resolved: true, xResultant, yResultant };
    }

    read() {
      const base = super.read();
      const center = Math.floor(this.height / 2) * this.width + Math.floor(this.width / 2);
      const probePhase = Math.atan2(this.imNow[center], this.reNow[center]);
      const centroid = this.circularCentroid();
      const offsetX = centroid.resolved ? centroid.x - .5 : 0;
      const offsetY = centroid.resolved ? centroid.y - .5 : 0;
      return {
        ...base,
        current: { x: centroid.resolved ? offsetX : null, y: centroid.resolved ? offsetY : null, resolved: centroid.resolved, xResultant: centroid.xResultant, yResultant: centroid.yResultant },
        spin: { x: offsetX * 2, y: offsetY * 2, z: Math.sin(probePhase) },
        centroid,
        probePhase,
        memoryCount: this.memory ? this.memory.length : 0
      };
    }

    audit(m) {
      const drift = relative(m.charge, this.baseline.charge);
      return Math.abs(drift) < 1e-10 ? 'PASS · U(1) charge proxy' : 'WATCH · charge-proxy drift';
    }
  }

  // A real, one-dimensional phi^4 field with a double-well potential.
  class Higgs1DEngine {
    constructor(width = 192, height = 96) {
      this.type = 'higgs1d';
      this.dimension = 1;
      this.width = width;
      this.height = height;
      this.size = width * height;
      this.phiNow = new Float64Array(width);
      this.phiPrev = new Float64Array(width);
      this.phiNext = new Float64Array(width);
      this.c2 = .22;
      this.lambda = .032;
      this.v = .86;
      this.frame = 0;
      this.pulses = [];
      this.seed();
    }

    seed() {
      for (let x = 0; x < this.width; x += 1) {
        const q = x / this.width;
        const domain = this.v * Math.tanh((x - this.width * .34) / 7) * Math.tanh((x - this.width * .66) / 7);
        const ripple = .048 * Math.sin(TAU * 3 * q + .31);
        this.phiNow[x] = domain + ripple;
        this.phiPrev[x] = domain + .048 * Math.sin(TAU * 3 * q + .31 + .22);
      }
      this.frame = 0;
      this.pulses.length = 0;
      this.baseline = this.read();
    }

    step() {
      for (let x = 0; x < this.width; x += 1) {
        const left = mod(x - 1, this.width);
        const right = mod(x + 1, this.width);
        const value = this.phiNow[x];
        const lap = this.phiNow[right] + this.phiNow[left] - 2 * value;
        const force = this.lambda * (value * value - this.v * this.v) * value;
        this.phiNext[x] = 2 * value - this.phiPrev[x] + this.c2 * lap - force;
      }
      const previous = this.phiPrev;
      this.phiPrev = this.phiNow;
      this.phiNow = this.phiNext;
      this.phiNext = previous;
      this.frame += 1;
    }

    inject(x = this.width * .5) {
      const spread = Math.max(3, this.width * .032);
      for (let index = 0; index < this.width; index += 1) {
        const kick = .17 * Math.exp(-((index - x) ** 2) / (2 * spread * spread));
        this.phiPrev[index] -= kick;
      }
      this.pulses.push({ x: x / this.width, y: .5, frame: this.frame });
    }

    profileAt(x) {
      const index = clamp(Math.round(x), 0, this.width - 1);
      return { value: this.phiNow[index], velocity: this.phiNow[index] - this.phiPrev[index] };
    }

    visualAt(index) {
      const x = index % this.width;
      const y = Math.floor(index / this.width);
      const value = this.phiNow[x];
      const velocity = value - this.phiPrev[x];
      const yNorm = y / Math.max(1, this.height - 1) - .5;
      const bandCenter = -value / Math.max(this.v, 1e-9) * .22;
      const ribbon = Math.exp(-((yNorm - bandCenter) ** 2) * 84);
      return {
        density: ribbon * (.15 + Math.abs(value) / Math.max(this.v, 1e-9)),
        phase: value >= 0 ? velocity * 3 : Math.PI + velocity * 3,
        spin: { x: clamp(value / this.v, -1, 1), y: clamp(velocity * 4, -1, 1), z: Math.tanh(value * velocity * 3) }
      };
    }

    read() {
      let energy = 0;
      let magnitude = 0;
      let mean = 0;
      let meanVelocity = 0;
      let walls = 0;
      for (let x = 0; x < this.width; x += 1) {
        const right = mod(x + 1, this.width);
        const value = this.phiNow[x];
        const velocity = this.phiNow[x] - this.phiPrev[x];
        const gradient = this.phiNow[right] - value;
        energy += .5 * velocity * velocity + .5 * this.c2 * gradient * gradient + this.lambda * .25 * (value * value - this.v * this.v) ** 2;
        magnitude += Math.abs(value);
        mean += value;
        meanVelocity += velocity;
        if (value * this.phiNow[right] < 0) walls += 1;
      }
      const order = mean / this.width / this.v;
      return {
        norm: magnitude / this.width / this.v,
        energyProxy: energy / this.width,
        current: { x: order, y: meanVelocity / this.width },
        spin: { x: clamp(order, -1, 1), y: clamp(meanVelocity / this.width * 4, -1, 1), z: clamp(walls / 4, 0, 1) },
        spinLength: 1,
        order,
        walls
      };
    }

    audit(m) {
      const drift = relative(m.energyProxy, this.baseline.energyProxy);
      return Math.abs(drift) < .35 ? 'PASS · bounded φ⁴ slice' : 'WATCH · energy-proxy drift';
    }
  }

  // Analytic, normalized two-basis orbital slices. They deliberately expose
  // the projection boundary: the canvas is a 2D effective orbital view.
  class OrbitalEngine {
    constructor(type, width = 128, height = 128) {
      this.type = type;
      this.width = width;
      this.height = height;
      this.size = width * height;
      this.re = new Float64Array(this.size);
      this.im = new Float64Array(this.size);
      this.sBasis = new Float64Array(this.size);
      this.pBasis = new Float64Array(this.size);
      this.frame = 0;
      this.pulses = [];
      this.phaseDegrees = 0;
      this.mix = type === 'lithium' ? .20 : .16;
      this.energyGap = type === 'lithium' ? .045 : .115;
      this.scale = type === 'lithium' ? Math.min(width, height) * .145 : Math.min(width, height) * .135;
      this.seed();
    }

    normalizeBasis(array) {
      let sum = 0;
      for (let i = 0; i < array.length; i += 1) sum += array[i] * array[i];
      const scale = 1 / Math.sqrt(sum || 1);
      for (let i = 0; i < array.length; i += 1) array[i] *= scale;
    }

    seed() {
      const cx = (this.width - 1) * .5;
      const cy = (this.height - 1) * .5;
      for (let y = 0; y < this.height; y += 1) {
        for (let x = 0; x < this.width; x += 1) {
          const index = y * this.width + x;
          const dx = x - cx;
          const dy = y - cy;
          const r = Math.hypot(dx, dy);
          if (this.type === 'lithium') {
            const q = r / this.scale;
            this.sBasis[index] = (1 - q * .72) * Math.exp(-q * .72);
            this.pBasis[index] = (dx / this.scale) * Math.exp(-q * .84);
          } else {
            const q = r / this.scale;
            this.sBasis[index] = Math.exp(-q);
            this.pBasis[index] = (dx / this.scale) * Math.exp(-q * .64);
          }
        }
      }
      this.normalizeBasis(this.sBasis);
      this.normalizeBasis(this.pBasis);
      this.frame = 0;
      this.pulses.length = 0;
      this.phaseDegrees = 0;
      this.rebuild();
      this.baseline = this.read();
    }

    rebuild() {
      const phase = this.phaseDegrees * Math.PI / 180;
      const slow = this.frame * this.energyGap;
      const cs = Math.cos(phase - slow * .32);
      const ss = Math.sin(phase - slow * .32);
      const cp = Math.cos(phase - slow * 1.32 + .71);
      const sp = Math.sin(phase - slow * 1.32 + .71);
      const latest = this.pulses.slice(-4);
      let norm = 0;
      for (let y = 0; y < this.height; y += 1) {
        for (let x = 0; x < this.width; x += 1) {
          const index = y * this.width + x;
          let re = this.sBasis[index] * cs + this.mix * this.pBasis[index] * cp;
          let im = this.sBasis[index] * ss + this.mix * this.pBasis[index] * sp;
          for (const pulse of latest) {
            const age = this.frame - pulse.frame;
            const envelope = pulse.amplitude * Math.exp(-age / 145) * Math.exp(-((x - pulse.x) ** 2 + (y - pulse.y) ** 2) / (2 * pulse.spread * pulse.spread));
            const pulsePhase = pulse.phase - age * .085;
            re += envelope * Math.cos(pulsePhase);
            im += envelope * Math.sin(pulsePhase);
          }
          this.re[index] = re;
          this.im[index] = im;
          norm += re * re + im * im;
        }
      }
      const scale = 1 / Math.sqrt(norm || 1);
      for (let i = 0; i < this.size; i += 1) { this.re[i] *= scale; this.im[i] *= scale; }
    }

    step() { this.frame += 1; this.rebuild(); }

    rotateGlobal(degrees) {
      this.phaseDegrees = mod(this.phaseDegrees + degrees, 360);
      this.rebuild();
    }

    inject(x = this.width * .5, y = this.height * .5) {
      this.pulses.push({ x, y, frame: this.frame, phase: this.phaseDegrees * Math.PI / 180 + this.pulses.length * .618, amplitude: .13, spread: Math.min(this.width, this.height) * .085 });
      this.rebuild();
    }

    visualAt(index) {
      const re = this.re[index];
      const im = this.im[index];
      return { density: re * re + im * im, phase: Math.atan2(im, re), spin: { x: 0, y: 0, z: 0 } };
    }

    read() {
      let norm = 0;
      let energy = 0;
      let xMoment = 0;
      let yMoment = 0;
      for (let y = 0; y < this.height; y += 1) {
        for (let x = 0; x < this.width; x += 1) {
          const index = y * this.width + x;
          const density = this.re[index] ** 2 + this.im[index] ** 2;
          norm += density;
          xMoment += x * density;
          yMoment += y * density;
          energy += density * (1 + (this.type === 'lithium' ? .28 : .52) * this.mix * this.mix);
        }
      }
      const centroid = { x: xMoment / Math.max(norm, 1e-12) / this.width, y: yMoment / Math.max(norm, 1e-12) / this.height };
      return {
        norm,
        energyProxy: energy,
        current: { x: centroid.x - .5, y: centroid.y - .5 },
        spin: { x: (centroid.x - .5) * 2, y: (centroid.y - .5) * 2, z: this.mix },
        spinLength: 1,
        centroid
      };
    }

    audit(m) {
      const drift = relative(m.norm, this.baseline.norm);
      return Math.abs(drift) < 2e-11 ? 'PASS · normalized orbital slice' : 'WATCH · normalization drift';
    }
  }

  // A two-coordinate, exchange-symmetric configuration-space slice. The
  // square is explicitly (r1,r2), never a square-shaped helium atom.
  class HeliumEngine {
    constructor(width = 128, height = 128) {
      this.type = 'helium';
      this.width = width;
      this.height = height;
      this.size = width * height;
      this.re = new Float64Array(this.size);
      this.im = new Float64Array(this.size);
      this.frame = 0;
      this.phaseDegrees = 0;
      this.pulses = [];
      this.seed();
    }

    seed() {
      this.frame = 0;
      this.phaseDegrees = 0;
      this.pulses.length = 0;
      this.rebuild();
      this.baseline = this.read();
    }

    rebuild() {
      const phase = this.phaseDegrees * Math.PI / 180;
      const breathing = .14 * Math.sin(this.frame * .045);
      const scale = 1.18 + breathing;
      const latest = this.pulses.slice(-3);
      let norm = 0;
      for (let y = 0; y < this.height; y += 1) {
        for (let x = 0; x < this.width; x += 1) {
          const index = y * this.width + x;
          const r1 = x / Math.max(1, this.width - 1) * 5.8;
          const r2 = y / Math.max(1, this.height - 1) * 5.8;
          const orbital = Math.exp(-(r1 + r2) / scale);
          const correlation = 1 - .42 * Math.exp(-((r1 - r2) ** 2) / .26);
          const configuration = 1 + .11 * Math.cos(this.frame * .071) * ((r1 + r2) / 5.8 - .75);
          let re = orbital * correlation * configuration * Math.cos(phase - this.frame * .035);
          let im = orbital * correlation * configuration * Math.sin(phase - this.frame * .035);
          for (const pulse of latest) {
            const age = this.frame - pulse.frame;
            const envelope = .08 * Math.exp(-age / 130) * Math.exp(-((x - pulse.x) ** 2 + (y - pulse.y) ** 2) / (2 * pulse.spread * pulse.spread));
            const localPhase = pulse.phase - age * .055;
            re += envelope * Math.cos(localPhase);
            im += envelope * Math.sin(localPhase);
          }
          this.re[index] = re;
          this.im[index] = im;
          norm += re * re + im * im;
        }
      }
      const normalize = 1 / Math.sqrt(norm || 1);
      for (let i = 0; i < this.size; i += 1) { this.re[i] *= normalize; this.im[i] *= normalize; }
    }

    step() { this.frame += 1; this.rebuild(); }

    rotateGlobal(degrees) { this.phaseDegrees = mod(this.phaseDegrees + degrees, 360); this.rebuild(); }

    inject(x = this.width * .5, y = this.height * .5) {
      this.pulses.push({ x, y, frame: this.frame, phase: this.phaseDegrees * Math.PI / 180 + this.pulses.length * .618, spread: Math.min(this.width, this.height) * .07 });
      this.rebuild();
    }

    visualAt(index) {
      const re = this.re[index];
      const im = this.im[index];
      return { density: re * re + im * im, phase: Math.atan2(im, re), spin: { x: 0, y: 0, z: 0 } };
    }

    read() {
      let norm = 0;
      let diagonal = 0;
      let offDiagonal = 0;
      let energy = 0;
      for (let y = 0; y < this.height; y += 1) {
        for (let x = 0; x < this.width; x += 1) {
          const index = y * this.width + x;
          const density = this.re[index] ** 2 + this.im[index] ** 2;
          norm += density;
          energy += density * (1 + Math.abs(x - y) / Math.max(this.width, this.height));
          if (Math.abs(x - y) < 3) diagonal += density;
          if (Math.abs(x - y) > this.width * .16) offDiagonal += density;
        }
      }
      const correlation = (offDiagonal - diagonal) / Math.max(norm, 1e-12);
      return {
        norm,
        energyProxy: energy,
        current: { x: correlation, y: 0 },
        spin: { x: 0, y: correlation, z: Math.cos(this.frame * .045) },
        spinLength: 1,
        correlation
      };
    }

    audit(m) {
      const drift = relative(m.norm, this.baseline.norm);
      return Math.abs(drift) < 2e-11 ? 'PASS · exchange-symmetric slice' : 'WATCH · normalization drift';
    }
  }

  // A dimensionless three-mass H2O normal-mode read. Its atoms and bonds are
  // a geometric mode display, not an electronic-structure or chemistry model.
  class WaterEngine {
    constructor(width = 160, height = 112) {
      this.type = 'water';
      this.width = width;
      this.height = height;
      this.size = width * height;
      this.frame = 0;
      this.pulses = [];
      this.kick = 0;
      this.geometry = null;
      this.seed();
    }

    updateGeometry() {
      const t = this.frame * .058;
      const qStretch = .11 * Math.sin(t) + this.kick * .08;
      const qBend = .075 * Math.sin(t * 1.618 + .78) + this.kick * .035;
      const bond = .235 + qStretch;
      const halfAngle = Math.PI * (52.25 + qBend * 96) / 180;
      const oxygen = { x: .5, y: .56 };
      const h1 = { x: oxygen.x - Math.sin(halfAngle) * bond, y: oxygen.y - Math.cos(halfAngle) * bond };
      const h2 = { x: oxygen.x + Math.sin(halfAngle) * bond, y: oxygen.y - Math.cos(halfAngle) * bond };
      this.geometry = { oxygen, h1, h2, qStretch, qBend, halfAngle };
    }

    seed() {
      this.frame = 0;
      this.pulses.length = 0;
      this.kick = 0;
      this.updateGeometry();
      this.baseline = this.read();
    }

    step() {
      this.frame += 1;
      this.kick *= .988;
      this.updateGeometry();
    }

    inject(x = this.width * .5, y = this.height * .5) {
      this.kick += .75 * (1 - .35 * Math.hypot(x / this.width - .5, y / this.height - .5));
      this.pulses.push({ x: x / this.width, y: y / this.height, frame: this.frame });
      this.updateGeometry();
    }

    visualAt(index) {
      const x = (index % this.width) / Math.max(1, this.width - 1);
      const y = Math.floor(index / this.width) / Math.max(1, this.height - 1);
      const g = this.geometry;
      const gaussian = (point, spread) => Math.exp(-((x - point.x) ** 2 + (y - point.y) ** 2) / (2 * spread * spread));
      const oxygen = gaussian(g.oxygen, .075);
      const h1 = gaussian(g.h1, .052);
      const h2 = gaussian(g.h2, .052);
      const density = .82 * oxygen + .34 * (h1 + h2);
      const phase = Math.atan2(y - g.oxygen.y, x - g.oxygen.x) + g.qStretch * 6 + g.qBend * 4;
      return { density: density * density, phase, spin: { x: g.qStretch * 5, y: g.qBend * 7, z: Math.cos(this.frame * .058) } };
    }

    read() {
      const g = this.geometry;
      const stretchVelocity = .11 * .058 * Math.cos(this.frame * .058);
      const bendVelocity = .075 * .058 * 1.618 * Math.cos(this.frame * .058 * 1.618 + .78);
      const energy = .5 * (stretchVelocity ** 2 + bendVelocity ** 2 + 1.8 * g.qStretch ** 2 + 2.5 * g.qBend ** 2);
      return {
        norm: Math.hypot(g.qStretch, g.qBend),
        energyProxy: energy,
        current: { x: g.qStretch, y: g.qBend },
        spin: { x: clamp(g.qStretch * 5, -1, 1), y: clamp(g.qBend * 7, -1, 1), z: Math.cos(this.frame * .058) },
        spinLength: 1,
        geometry: g
      };
    }

    audit(m) {
      return Number.isFinite(m.energyProxy) ? 'PASS · three-mass normal mode' : 'WATCH · invalid mode value';
    }
  }

  class Phi4DisplayEngine extends Phi4Core.Engine {
    constructor(width = 96, height = 96) {
      super({ width: width === 128 ? 96 : width, height: height === 128 ? 96 : height });
      this.dimension = 2;
      this.seedVortexPair();
      this.baseline = this.read();
    }
    seedVortexPair() {
      const first = [this.width * .37, this.height * .50, 1];
      const second = [this.width * .63, this.height * .50, -1];
      const core = Math.min(this.width, this.height) * .034, omega = .057;
      for (let y = 0; y < this.height; y += 1) for (let x = 0; x < this.width; x += 1) {
        const index = y * this.width + x;
        let amplitude = this.v, phase = 0;
        for (const [cx, cy, sign] of [first, second]) { const radius = Math.hypot(x - cx, y - cy); amplitude *= Math.tanh(radius / core); phase += sign * Math.atan2(y - cy, x - cx); }
        this.reNow[index] = amplitude * Math.cos(phase); this.imNow[index] = amplitude * Math.sin(phase);
        this.rePrev[index] = amplitude * Math.cos(phase - omega * this.dt); this.imPrev[index] = amplitude * Math.sin(phase - omega * this.dt);
      }
      this.frame = 0; this.pulses.length = 0; this.baselineCharge = this.charge();
    }
    step(count = 1) { super.step(count); }
    windingAt(cx, cy, radius = Math.min(this.width, this.height) * .075) {
      let total = 0, previous = null;
      for (let tick = 0; tick <= 48; tick += 1) { const angle = TAU * tick / 48, x = mod(Math.round(cx + radius * Math.cos(angle)), this.width), y = mod(Math.round(cy + radius * Math.sin(angle)), this.height), phase = Math.atan2(this.imNow[y * this.width + x], this.reNow[y * this.width + x]); if (previous !== null) total += Math.atan2(Math.sin(phase - previous), Math.cos(phase - previous)); previous = phase; }
      return total / TAU;
    }
    windingNumbers() { return [this.windingAt(this.width * .37, this.height * .50), this.windingAt(this.width * .63, this.height * .50)]; }
    plaquetteWinding(x, y) {
      const phaseAt = (col, row) => Math.atan2(this.imNow[mod(row, this.height) * this.width + mod(col, this.width)], this.reNow[mod(row, this.height) * this.width + mod(col, this.width)]);
      const phases = [phaseAt(x, y), phaseAt(x + 1, y), phaseAt(x + 1, y + 1), phaseAt(x, y + 1), phaseAt(x, y)];
      let total = 0; for (let i = 0; i < 4; i += 1) total += Math.atan2(Math.sin(phases[i + 1] - phases[i]), Math.cos(phases[i + 1] - phases[i]));
      return total / TAU;
    }
    vortexCount() {
      let positive = 0, negative = 0;
      for (let y = 0; y < this.height; y += 1) for (let x = 0; x < this.width; x += 1) { const winding = this.plaquetteWinding(x, y); if (winding > .5) positive += 1; if (winding < -.5) negative += 1; }
      return { positive, negative, total: positive + negative };
    }
    read() {
      let magnitude = 0, phaseX = 0, phaseY = 0;
      for (let i = 0; i < this.size; i += 1) { magnitude += this.densityAt(i); phaseX += this.reNow[i]; phaseY += this.imNow[i]; }
      const radial = Math.hypot(phaseX, phaseY) || 1;
      return { norm: this.charge(), energyProxy: this.energyProxy(), current: { x: phaseX / this.size, y: phaseY / this.size }, spin: { x: phaseX / radial, y: phaseY / radial, z: Math.min(1, Math.max(-1, (magnitude / this.size - this.v * this.v))) } };
    }
    audit() { return Math.abs(this.relativeChargeDrift()) < 2e-10 ? 'PASS · discrete U(1) charge' : 'WATCH · charge drift'; }
  }

  class OscillationDisplayEngine extends OscillationCore.OscillationEngine {
    constructor(width = 96, height = 96) {
      super(); this.width = width === 128 ? 96 : width; this.height = height === 128 ? 96 : height; this.size = this.width * this.height; this.dimension = 2; this.baseline = this.read();
    }
    visualAt(index) {
      const r = this.read(), x = index % this.width, y = Math.floor(index / this.width), horizontal = x / Math.max(1, this.width - 1), vertical = y / Math.max(1, this.height - 1);
      const alphaLobe = Math.exp(-((horizontal - .28) ** 2 + (vertical - .50) ** 2) / .055);
      const betaLobe = Math.exp(-((horizontal - .72) ** 2 + (vertical - .50) ** 2) / .055);
      return { density: r.alphaProbability * alphaLobe + r.betaProbability * betaLobe, phase: horizontal < .5 ? Math.atan2(this.flavourState().alpha.im, this.flavourState().alpha.re) : Math.atan2(this.flavourState().beta.im, this.flavourState().beta.re), spin: r.compass };
    }
    inject(x = 0, y = 0) { this.injectFlavour(x / this.width < .5 ? 'alpha' : 'beta'); this.baseline = this.read(); }
    rotateGlobal() { /* flavour probabilities are global-phase invariant by construction. */ }
    read() { const r = super.read(), closedFormApplies = this.initialFlavour === 'alpha' && this.pulses.length === 0; return { norm: r.totalProbability, energyProxy: closedFormApplies ? r.expectedTransition : r.betaProbability, current: { x: r.alphaProbability, y: r.betaProbability }, spin: r.compass, closedFormApplies, ...r }; }
  }

  class DiracDisplayEngine extends DiracCore.MassiveDiracEngine {
    constructor(width = 128, height = 128) { super(width, height); this.dimension = 2; this.pulses = []; }
    circularCentroid() {
      let xCos = 0, xSin = 0, yCos = 0, ySin = 0, norm = 0;
      for (let y = 0; y < this.height; y += 1) for (let x = 0; x < this.width; x += 1) { const i = y * this.width + x, density = this.aRe[i] ** 2 + this.aIm[i] ** 2 + this.bRe[i] ** 2 + this.bIm[i] ** 2; norm += density; xCos += density * Math.cos(TAU * x / this.width); xSin += density * Math.sin(TAU * x / this.width); yCos += density * Math.cos(TAU * y / this.height); ySin += density * Math.sin(TAU * y / this.height); }
      const safeNorm = norm || 1;
      const xResultant = Math.hypot(xCos, xSin) / safeNorm;
      const yResultant = Math.hypot(yCos, ySin) / safeNorm;
      if (!Number.isFinite(xResultant) || !Number.isFinite(yResultant) || xResultant < 1e-8 || yResultant < 1e-8) return { x: null, y: null, resolved: false, xResultant, yResultant };
      return { x: mod(Math.atan2(xSin, xCos) / TAU, 1), y: mod(Math.atan2(ySin, yCos) / TAU, 1), resolved: true, xResultant, yResultant };
    }
    read() { const r = super.read(), centroid = this.circularCentroid(); return { ...r, energyProxy: this.mass, current: centroid, centroid }; }
    inject(x = this.width * .5, y = this.height * .5) {
      const spread = Math.min(this.width, this.height) * .055;
      for (let row = 0; row < this.height; row += 1) for (let col = 0; col < this.width; col += 1) {
        const i = row * this.width + col, angle = .72 * Math.exp(-((col - x) ** 2 + (row - y) ** 2) / (2 * spread * spread)), c = Math.cos(angle), s = Math.sin(angle), ar = this.aRe[i], ai = this.aIm[i], br = this.bRe[i], bi = this.bIm[i];
        this.aRe[i] = c * ar - s * br; this.aIm[i] = c * ai - s * bi; this.bRe[i] = s * ar + c * br; this.bIm[i] = s * ai + c * bi;
      }
      this.pulses.push({ x: x / this.width, y: y / this.height, frame: this.frame });
    }
    rotateGlobal(degrees) { const a = degrees * Math.PI / 180, c = Math.cos(a), s = Math.sin(a); for (const [re, im] of [[this.aRe, this.aIm], [this.bRe, this.bIm]]) for (let i = 0; i < this.size; i += 1) { const rr = re[i], ii = im[i]; re[i] = rr * c - ii * s; im[i] = rr * s + ii * c; } }
    audit(m) { return Math.abs(m.norm - this.baseline.norm) < 3e-10 ? 'PASS · spectral norm' : 'WATCH · norm residual'; }
  }

  class FluxRingDisplayEngine extends GaugeCore.U1FluxRingEngine {
    constructor(width = 128, height = 128) { super(width, height); this.dimension = 2; }
  }

  class SU3DisplayEngine extends GaugeCore.SU3ColorTransportEngine {
    constructor(width = 64, height = 64) { super(width === 128 ? 64 : width, height === 128 ? 64 : height); this.dimension = 2; }
  }

  const SPECIES = {
    electron: {
      label: 'Electron', family: 'FERMION −1', spin: '½', charge: '−e',
      equation: 'Pauli spinor: i∂tΨ = [−½∇² + V − ½B·σ]Ψ',
      detail: 'One prepared charged spin-½ state on a finite 2D grid. The scalar aperture potential and Zeeman term are declared effective external fields; orbital coupling to a vector potential is outside this build.',
      read: 'Brightness = probability density · hue = spinor projection phase · ring = spin expectation.',
      hasGlobalPhase: true, filaments: true, tone: 43, readoutLabel: 'SPIN READ', metricLabel: 'NORM', currentLabel: 'NET CURRENT', readAxes: 'σx, σy, σz'
    },
    neutrino: {
      label: 'Neutral spinor', family: 'FERMION −1', spin: '½', charge: '0',
      equation: 'Massless 2D Weyl-type spinor: i∂tΨ = −iσ·∇Ψ',
      detail: 'A finite massless two-component spinor carrier. It is not a three-flavour neutrino-oscillation or weak-interaction calculation.',
      read: 'Brightness = probability density · hue = spinor phase · ring = spin expectation. The current read is the integrated Weyl current ⟨σₓ, σᵧ⟩.',
      hasGlobalPhase: true, filaments: true, tone: 43, readoutLabel: 'SPIN READ', metricLabel: 'NORM', currentLabel: 'WEYL CURRENT ⟨σ⟩', readAxes: 'σx, σy, σz'
    },
    photon: {
      label: 'Photon mode', family: 'BOSON +1', spin: '1', charge: '0',
      equation: '2D transverse Maxwell update: ∂tE = ∇×H, ∂tH = −∇×E',
      detail: 'One finite transverse electromagnetic mode on a periodic 2D grid. It is a classical field mode, not a photon-counting measurement.',
      read: 'Brightness = local electromagnetic amplitude · hue = field quadrature · filaments = Poynting direction.',
      hasGlobalPhase: false, filaments: true, tone: 200, readoutLabel: 'FIELD-QUADRATURE READ', metricLabel: 'FIELD ENERGY', currentLabel: 'POYNTING READ', readAxes: 'E²−Hᵧ², 2EHᵧ, 2EHₓ'
    },
    scalar: {
      label: 'Scalar mode', family: 'BOSON +1', spin: '0', charge: '0',
      equation: '(∂t² − c²∇² + m²)φ = 0',
      detail: 'A complex Klein–Gordon-type scalar carrier with its own finite update law, field magnitude, phase, and current reader.',
      read: 'Brightness = field magnitude · hue = complex phase · filaments = phase-current display.',
      hasGlobalPhase: true, filaments: true, tone: 284, readoutLabel: 'SCALAR FIELD READ', metricLabel: 'CHARGE PROXY', currentLabel: 'CURRENT', readAxes: 'mean Re φ, mean Im φ, scaled charge'
    },
    noether: {
      label: 'Noether–Klein memory field', family: 'COMPLEX SCALAR', spin: '0', charge: 'U(1)',
      equation: '(∂t² − c²∇² + m²)φ = 0  ·  φ → eⁱᵅφ',
      detail: 'The prior Noether–Klein complex scalar carrier: a periodic two-dimensional lattice with declared global U(1) phase, post-pulse charge baseline, and retained visual history. Its memory weave is a finite-grid receipt, not a physical-memory observation.',
      read: 'Brightness = field magnitude · hue = U(1) phase · weave = retained samples from the declared lattice · centroid = circular density read.',
      hasGlobalPhase: true, filaments: true, tone: 284, readoutLabel: 'NOETHER / MEMORY READ', metricLabel: 'CHARGE PROXY', currentLabel: 'CENTROID', historyLimit: 156, readAxes: 'torus x, torus y, probe-phase sine'
    },
    flux: {
      label: 'Aharonov–Bohm flux ring', family: 'U(1) GAUGE · RING', spin: '0', charge: 'U(1)',
      equation: 'Uℓ = eⁱᴬℓ · ∏loop Uℓ = eⁱΦ',
      detail: 'A closed finite U(1) link lattice. The state advances by gauge-covariant unitary bond transport. The independent receipts are norm preservation, local-gauge covariance, 2π large-gauge covariance after the declared seed twist, and a nonzero half-flux response. The centre reads the declared loop phase; it is not itself a verification receipt.',
      read: 'Brightness = transported amplitude around the ring · hue = local wave phase · centre = excluded flux reader.',
      hasGlobalPhase: true, filaments: false, tone: 202, readoutLabel: 'U(1) HOLONOMY READ', metricLabel: 'NORM', energyLabel: 'WRAPPED FLUX', currentLabel: 'CIRCULAR MOMENT', readAxes: 'cos Φ, sin Φ, ring concentration'
    },
    su3: {
      label: 'SU(3) colour-link transport', family: 'QCD KINEMATICS · SU(3)', spin: '½', charge: 'COLOUR TRIPLET',
      equation: 'ψₓ → Gₓψₓ · U₍ₓ,μ₎ → GₓU₍ₓ,μ₎G†₍ₓ+μ₎',
      detail: 'A finite colour-triplet packet transported through non-commuting SU(3) links by an exactly unitary gauge-covariant bond update. Its receipts use general non-diagonal local SU(3) transformations and test covariance, plaquette and 2×1 Wilson-loop trace invariance, and an evolved εₐᵦᶜ singlet determinant. This supplies QCD gauge structure; it is not a path-integral ensemble, continuum extrapolation, or a confinement measurement.',
      read: 'Brightness = triplet density · RGB channels = reader mapping of three colour-basis populations · phase filaments = transport phase.',
      hasGlobalPhase: true, filaments: true, tone: 340, readoutLabel: 'SU(3) COLOUR READ', metricLabel: 'NORM', energyLabel: 'PLAQUETTE CURVATURE', currentLabel: 'R / G POPULATION', readAxes: 'R−G, G−B, colour-phase cosine'
    },
    dirac: {
      label: 'Massive Dirac packet', family: 'FERMION · 2+1D', spin: '½', charge: 'BRANCH READ',
      equation: 'H(k) = kₓσₓ + kᵧσᵧ + mσ_z · E = ±√(k² + m²)',
      detail: 'A finite 2+1D massive Dirac-type packet with exact momentum-space evolution. Its companion checks compare both energy branches, charge conjugation, and the 2E mixed-branch beat; it is not a 3+1D quantum-field calculation.',
      read: 'Brightness = spinor density · hue = combined spinor phase · filaments = phase-gradient display.',
      hasGlobalPhase: true, filaments: true, tone: 26, readoutLabel: 'DIRAC SPIN READ', metricLabel: 'NORM', energyLabel: 'MASS', currentLabel: 'TORUS CENTROID', readAxes: 'σx, σy, σz'
    },
    phi4: {
      label: 'Complex φ⁴ field', family: 'U(1) SCALAR · 2D', spin: '0', charge: 'U(1)',
      equation: '∂t²φ − c²∇²φ + λ(|φ|² − v²)φ = 0',
      detail: 'A periodic complex Mexican-hat field with centered leapfrog update. The visible seed is a vortex–antivortex pair with nonzero discrete charge. Its receipts check post-pulse U(1) density invariance, charge, a seed winding and time-local plaquette vortex count, Goldstone lattice dispersion, and radial mass √(2λ)v. The pair may annihilate under this finite evolution.',
      read: 'Brightness = |φ|² · hue = U(1) phase · filaments = phase-gradient display · two seed cores = opposite winding; their later count is dynamic.',
      hasGlobalPhase: true, filaments: true, tone: 304, readoutLabel: 'U(1) VORTEX READ', metricLabel: 'DISCRETE CHARGE', energyLabel: 'FIELD ENERGY', currentLabel: 'MEAN FIELD', readAxes: 'mean Re φ, mean Im φ, radial departure'
    },
    higgs: {
      label: 'Electroweak Higgs doublet', family: 'HIGGS SECTOR · SU(2)L × U(1)Y', spin: '0', charge: 'Y = 1',
      equation: 'ℒH = (DμΦ)†DμΦ − λ(Φ†Φ − v²/2)² · Φ ∈ ℂ²',
      detail: 'A finite 2+1D electroweak Higgs-sector lattice for a complex hypercharge-one SU(2)L doublet. Its gauge-covariant leapfrog evolves through declared non-commuting SU(2)L × U(1)Y links. The admitted receipts test local gauge covariance, gauge-invariant Φ†Φ, the radial lattice mass, and the tree-level W/Z/photon mass matrix constructed from DμΦ.',
      read: 'Brightness = gauge-invariant Higgs-modulus departure |√(2Φ†Φ) − v| · hue = weak-isospin orientation in the declared gauge · filaments = gauge-covariant Higgs current.',
      hasGlobalPhase: false, filaments: true, tone: 52, scopeLabel: 'HIGGS SECTOR · CLICK TO PULSE', readoutLabel: 'HIGGS / GAUGE READ', metricLabel: '⟨Φ†Φ⟩ / (v²/2)', energyLabel: 'HIGGS-SECTOR ENERGY', currentLabel: 'Jx, Jy', readAxes: 'H/v−1, Jx, Jy'
    },
    oscillation: {
      label: 'Two-flavour neutrino', family: 'TWO-STATE FLAVOUR', spin: '½', charge: '0',
      equation: 'P(α→β) = sin²(2θ) sin²(Δm²L / 4E)',
      detail: 'A declared two-state flavour system propagated in its mass basis. For an unpulsed pure-α preparation the read compares Pβ with the closed form. After a pulse it reports the measured Pβ and normalized state only; it does not represent three-flavour matter effects or weak interactions.',
      read: 'Brightness = declared two-lobe state-reader projection · hue = each flavour amplitude phase · compass = flavour Bloch coordinates.',
      hasGlobalPhase: false, filaments: false, tone: 154, readoutLabel: 'FLAVOUR BLOCH READ', metricLabel: 'TOTAL PROBABILITY', energyLabel: 'Pβ / CLOSED FORM', currentLabel: 'Pα, Pβ', readAxes: 'coherence Re, coherence Im, α−β imbalance'
    },
    higgs1d: {
      label: 'Real scalar domain field · 1D φ⁴', family: 'REAL SCALAR · 1D', spin: '0', charge: '0',
      equation: '∂t²φ − c²∂x²φ + λ(φ² − v²)φ = 0',
      detail: 'A real one-dimensional φ⁴ field with a double-well potential and a domain-pair seed. It remains a visual study with its own real-scalar state space and update law.',
      read: 'Ribbon height = real order parameter · gold/cyan rail = the two effective vacua · weave = finite history.',
      hasGlobalPhase: false, filaments: false, tone: 43, readoutLabel: 'ORDER-PARAMETER READ', metricLabel: 'VACUUM MAGNITUDE', currentLabel: 'FIELD MEAN', pulseLabel: 'Kick field', certification: 'OPEN'
    },
    hydrogen: {
      label: 'Hydrogen · orbital slice', family: 'EFFECTIVE ONE-ELECTRON SLICE', spin: '½', charge: '−e',
      equation: 'ψ(r,θ,t) = cₛφₛe⁻ⁱᴱˢᵗ + cₚφₚe⁻ⁱᴱᵖᵗ',
      detail: 'A normalized two-basis orbital superposition on a two-dimensional effective slice through a hydrogenic one-electron model. It is a readable projection, not a three-dimensional spectrum, measurement, or atom in a trap.',
      read: 'Brightness = normalized orbital density · hue = complex phase · rings = effective radial reference.',
      hasGlobalPhase: true, filaments: true, tone: 198, readoutLabel: 'ORBITAL READ', metricLabel: 'DISPLAY NORMALIZATION', currentLabel: 'DIPOLE', certification: 'OPEN'
    },
    helium: {
      label: 'Helium · configuration slice', family: 'TWO-ELECTRON CONFIGURATION', spin: 'SINGLET SLICE', charge: '−2e',
      equation: 'Ψ(r₁,r₂,t) = Ψ(r₂,r₁,t) · C(|r₁ − r₂|)',
      detail: 'An exchange-symmetric finite configuration-space slice for two radial coordinates. The canvas axes are r₁ and r₂; the diagonal is the exchange seam, not the outline of a square-shaped atom.',
      read: 'Brightness = configuration probability proxy · hue = common phase · diagonal = exchange seam / correlation read.',
      hasGlobalPhase: true, filaments: false, tone: 304, readoutLabel: 'CONFIGURATION READ', metricLabel: 'DISPLAY NORMALIZATION', currentLabel: 'RADIAL-SEPARATION PROXY', certification: 'OPEN'
    },
    water: {
      label: 'Water · H₂O normal mode', family: 'THREE-MASS MOLECULAR MODE', spin: 'CLASSICAL MODE', charge: '0',
      equation: 'M q̈ + Kq = 0',
      detail: 'A dimensionless three-mass H₂O stretch–bend mode near the familiar bent geometry. The circles and bonds read a declared normal coordinate; this does not calculate electronic structure, bond energies, spectroscopy, or chemistry.',
      read: 'Brightness = geometric mode envelope · gold = oxygen reference · cyan = hydrogen positions · bonds = instantaneous normal-mode geometry.',
      hasGlobalPhase: false, filaments: false, tone: 178, readoutLabel: 'MOLECULAR MODE READ', metricLabel: 'MODE AMPLITUDE', energyLabel: 'MODE ENERGY', currentLabel: 'MODE COORDINATE', pulseLabel: 'Kick mode', liveReadouts: true, certification: 'OPEN'
    },
    lithium: {
      label: 'Lithium · valence slice', family: 'EFFECTIVE FROZEN-CORE SLICE', spin: '½', charge: '−e',
      equation: 'H_eff = −½∇² + V_screened(r)',
      detail: 'A normalized two-dimensional effective valence-orbital slice with a declared frozen core and a radial node. It is not a three-electron correlated lithium calculation, spectrum, or chemical model.',
      read: 'Brightness = normalized valence-density proxy · hue = complex phase · central mark = frozen-core reference.',
      hasGlobalPhase: true, filaments: true, tone: 116, readoutLabel: 'VALENCE-ORBITAL READ', metricLabel: 'DISPLAY NORMALIZATION', currentLabel: 'DIPOLE', certification: 'OPEN'
    }
  };

  function makeEngine(type, width = 128, height = 128) {
    if (type === 'electron') return new SpinorEngine('electron', width, height);
    if (type === 'neutrino') return new SpinorEngine('neutrino', width, height);
    if (type === 'photon') return new PhotonEngine(width, height);
    if (type === 'scalar') return new ScalarEngine(width, height);
    if (type === 'noether') return new NoetherKleinEngine(width === 128 && height === 128 ? 160 : width, width === 128 && height === 128 ? 112 : height);
    if (type === 'flux') return new FluxRingDisplayEngine(width, height);
    if (type === 'su3') return new SU3DisplayEngine(width, height);
    if (type === 'dirac') return new DiracDisplayEngine(width, height);
    if (type === 'phi4') return new Phi4DisplayEngine(width, height);
    if (type === 'higgs') return new ElectroweakCore.Engine({ width, height });
    if (type === 'oscillation') return new OscillationDisplayEngine(width, height);
    if (type === 'higgs1d') return new Higgs1DEngine(width === 128 ? 192 : width, height === 128 ? 96 : height);
    if (type === 'hydrogen' || type === 'lithium') return new OrbitalEngine(type, width, height);
    if (type === 'helium') return new HeliumEngine(width, height);
    if (type === 'water') return new WaterEngine(width === 128 && height === 128 ? 160 : width, width === 128 && height === 128 ? 112 : height);
    throw new Error(`Unknown carrier: ${type}`);
  }

  function relative(value, baseline) {
    return baseline ? (value - baseline) / Math.abs(baseline) : 0;
  }

  function hslToRgb(hue, saturation, lightness) {
    const h = mod(hue, 360) / 360;
    const s = clamp(saturation, 0, 1);
    const l = clamp(lightness, 0, 1);
    if (s === 0) { const value = Math.round(l * 255); return [value, value, value]; }
    const q = l < .5 ? l * (1 + s) : l + s - l * s;
    const p = 2 * l - q;
    const channel = (t) => {
      let value = t;
      if (value < 0) value += 1;
      if (value > 1) value -= 1;
      if (value < 1 / 6) return p + (q - p) * 6 * value;
      if (value < 1 / 2) return q;
      if (value < 2 / 3) return p + (q - p) * (2 / 3 - value) * 6;
      return p;
    };
    return [Math.round(channel(h + 1 / 3) * 255), Math.round(channel(h) * 255), Math.round(channel(h - 1 / 3) * 255)];
  }

  return { TAU, SPECIES, SpinorEngine, PhotonEngine, ScalarEngine, NoetherKleinEngine, Higgs1DEngine, OrbitalEngine, HeliumEngine, WaterEngine, DiracDisplayEngine, Phi4DisplayEngine, OscillationDisplayEngine, FluxRingDisplayEngine, SU3DisplayEngine, ElectroweakHiggsEngine: ElectroweakCore.Engine, makeEngine, fft1d, fft2d, spinNorm, spinRead, relative, signed, clamp, mod, hslToRgb };
})();

if (typeof module !== 'undefined') module.exports = ParticleAtlasCore;
