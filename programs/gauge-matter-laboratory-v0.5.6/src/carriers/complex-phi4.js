/*
 * Clear Onyx v0.4.2 — 2D complex phi^4 Mexican-hat carrier.
 *
 * State: phi = x + i y on a periodic square lattice.
 * Potential: V(phi) = lambda/4 (|phi|^2 - v^2)^2.
 * Update: centered leapfrog in time, nearest-neighbour periodic Laplacian.
 *
 * This file is browser and Node compatible. It intentionally contains no DOM.
 */
'use strict';

const ComplexPhi4 = (() => {
  const TAU = Math.PI * 2;
  const mod = (value, divisor) => ((value % divisor) + divisor) % divisor;
  const indexAt = (x, y, width, height) => mod(y, height) * width + mod(x, width);

  class Engine {
    constructor(options = {}) {
      this.width = options.width || 96;
      this.height = options.height || 96;
      this.size = this.width * this.height;
      this.dt = options.dt || .10;
      this.c = options.c || 1;
      this.lambda = options.lambda || .72;
      this.v = options.v || 1;
      this.courant2 = (this.c * this.dt) ** 2;
      this.lambdaDt2 = this.lambda * this.dt ** 2;
      if (this.courant2 > .5) throw new Error('Courant stability requires (c dt)^2 <= 0.5 on this 2D nearest-neighbour lattice.');
      this.reNow = new Float64Array(this.size);
      this.imNow = new Float64Array(this.size);
      this.rePrev = new Float64Array(this.size);
      this.imPrev = new Float64Array(this.size);
      this.reNext = new Float64Array(this.size);
      this.imNext = new Float64Array(this.size);
      this.frame = 0;
      this.pulses = [];
      this.seedVacuum();
    }

    seedVacuum(phase = 0) {
      const re = this.v * Math.cos(phase);
      const im = this.v * Math.sin(phase);
      this.reNow.fill(re); this.imNow.fill(im);
      this.rePrev.fill(re); this.imPrev.fill(im);
      this.reNext.fill(0); this.imNext.fill(0);
      this.frame = 0;
      this.pulses.length = 0;
      this.baselineCharge = this.charge();
    }

    step(count = 1) {
      for (let turn = 0; turn < count; turn += 1) {
        const { width, height, reNow, imNow, rePrev, imPrev, reNext, imNext, courant2, lambdaDt2, v } = this;
        for (let y = 0; y < height; y += 1) {
          for (let x = 0; x < width; x += 1) {
            const index = y * width + x;
            const left = indexAt(x - 1, y, width, height);
            const right = indexAt(x + 1, y, width, height);
            const up = indexAt(x, y - 1, width, height);
            const down = indexAt(x, y + 1, width, height);
            const re = reNow[index];
            const im = imNow[index];
            const lapRe = reNow[left] + reNow[right] + reNow[up] + reNow[down] - 4 * re;
            const lapIm = imNow[left] + imNow[right] + imNow[up] + imNow[down] - 4 * im;
            const radial = re * re + im * im - v * v;
            reNext[index] = 2 * re - rePrev[index] + courant2 * lapRe - lambdaDt2 * radial * re;
            imNext[index] = 2 * im - imPrev[index] + courant2 * lapIm - lambdaDt2 * radial * im;
          }
        }
        const oldPrevRe = this.rePrev, oldPrevIm = this.imPrev;
        this.rePrev = this.reNow; this.imPrev = this.imNow;
        this.reNow = this.reNext; this.imNow = this.imNext;
        this.reNext = oldPrevRe; this.imNext = oldPrevIm;
        this.frame += 1;
      }
    }

    rotateGlobal(degrees) {
      const angle = degrees * Math.PI / 180;
      const cosine = Math.cos(angle);
      const sine = Math.sin(angle);
      for (const [reName, imName] of [['reNow', 'imNow'], ['rePrev', 'imPrev']]) {
        const re = this[reName], im = this[imName];
        for (let index = 0; index < this.size; index += 1) {
          const oldRe = re[index], oldIm = im[index];
          re[index] = oldRe * cosine - oldIm * sine;
          im[index] = oldRe * sine + oldIm * cosine;
        }
      }
    }

    inject(x = this.width * .5, y = this.height * .5, options = {}) {
      const phase = options.phase === undefined ? this.pulses.length * .61803398875 : options.phase;
      const amplitude = options.amplitude || .13;
      const spread = options.spread || Math.min(this.width, this.height) * .065;
      const velocity = options.velocity || 0;
      for (let row = 0; row < this.height; row += 1) {
        for (let col = 0; col < this.width; col += 1) {
          const index = row * this.width + col;
          const envelope = amplitude * Math.exp(-((col - x) ** 2 + (row - y) ** 2) / (2 * spread * spread));
          const re = envelope * Math.cos(phase);
          const im = envelope * Math.sin(phase);
          this.reNow[index] += re;
          this.imNow[index] += im;
          this.rePrev[index] += re * (1 - velocity * this.dt);
          this.imPrev[index] += im * (1 - velocity * this.dt);
        }
      }
      this.pulses.push({ x: x / this.width, y: y / this.height, phase, amplitude, frame: this.frame });
      this.baselineCharge = this.charge();
    }

    densityAt(index) { return this.reNow[index] ** 2 + this.imNow[index] ** 2; }

    visualAt(index) {
      const re = this.reNow[index], im = this.imNow[index];
      return { density: re * re + im * im, phase: Math.atan2(im, re) };
    }

    // Exact discrete Noether charge for the centered update, evaluated on the
    // time link (n-1,n). Periodic summation makes the lattice flux telescope.
    charge() {
      let total = 0;
      for (let index = 0; index < this.size; index += 1) {
        total += this.rePrev[index] * this.imNow[index] - this.imPrev[index] * this.reNow[index];
      }
      return total / this.dt;
    }

    energyProxy() {
      let total = 0;
      const { width, height, reNow, imNow, rePrev, imPrev, c, lambda, v, dt } = this;
      for (let y = 0; y < height; y += 1) {
        for (let x = 0; x < width; x += 1) {
          const index = y * width + x;
          const right = indexAt(x + 1, y, width, height);
          const down = indexAt(x, y + 1, width, height);
          const velocityRe = (reNow[index] - rePrev[index]) / dt;
          const velocityIm = (imNow[index] - imPrev[index]) / dt;
          const gradXRe = reNow[right] - reNow[index];
          const gradXIm = imNow[right] - imNow[index];
          const gradYRe = reNow[down] - reNow[index];
          const gradYIm = imNow[down] - imNow[index];
          const radial = reNow[index] ** 2 + imNow[index] ** 2 - v * v;
          total += .5 * (velocityRe ** 2 + velocityIm ** 2)
            + .5 * c * c * (gradXRe ** 2 + gradXIm ** 2 + gradYRe ** 2 + gradYIm ** 2)
            + lambda * .25 * radial * radial;
        }
      }
      return total;
    }

    relativeChargeDrift() {
      const base = this.baselineCharge;
      return Math.abs(base) > 1e-14 ? (this.charge() - base) / Math.abs(base) : this.charge() - base;
    }

    // Lattice dispersions for the same centered finite-difference equation.
    goldstoneOmega(kx, ky) {
      const sine2 = Math.sin(kx / 2) ** 2 + Math.sin(ky / 2) ** 2;
      return 2 / this.dt * Math.asin(Math.min(1, this.c * this.dt * Math.sqrt(sine2)));
    }

    radialOmega(kx = 0, ky = 0) {
      const m2 = 2 * this.lambda * this.v * this.v;
      const sine2 = Math.sin(kx / 2) ** 2 + Math.sin(ky / 2) ** 2;
      const argument = this.dt * .5 * Math.sqrt(m2 + 4 * this.c * this.c * sine2);
      return 2 / this.dt * Math.asin(Math.min(1, argument));
    }

    radialMass() { return Math.sqrt(2 * this.lambda) * this.v; }

    setGoldstoneMode(kxMode = 1, kyMode = 0, amplitude = 1e-5) {
      const kx = TAU * kxMode / this.width;
      const ky = TAU * kyMode / this.height;
      const omega = this.goldstoneOmega(kx, ky);
      for (let y = 0; y < this.height; y += 1) {
        for (let x = 0; x < this.width; x += 1) {
          const index = y * this.width + x;
          const shape = Math.cos(kx * x + ky * y);
          this.reNow[index] = this.v;
          this.imNow[index] = amplitude * shape;
          this.rePrev[index] = this.v;
          this.imPrev[index] = amplitude * shape * Math.cos(omega * this.dt);
        }
      }
      this.frame = 0;
      this.pulses.length = 0;
      this.baselineCharge = this.charge();
      return { kx, ky, omega };
    }

    setRadialMode(amplitude = 1e-5) {
      const omega = this.radialOmega();
      const now = this.v + amplitude;
      const previous = this.v + amplitude * Math.cos(omega * this.dt);
      this.reNow.fill(now); this.imNow.fill(0);
      this.rePrev.fill(previous); this.imPrev.fill(0);
      this.frame = 0;
      this.pulses.length = 0;
      this.baselineCharge = this.charge();
      return { omega, radialMass: this.radialMass() };
    }

    // Project a selected real or imaginary component on cos(kx x + ky y).
    modeProjection(component, kx, ky) {
      const field = component === 'im' ? this.imNow : this.reNow;
      let sum = 0;
      let norm = 0;
      for (let y = 0; y < this.height; y += 1) {
        for (let x = 0; x < this.width; x += 1) {
          const shape = Math.cos(kx * x + ky * y);
          sum += field[y * this.width + x] * shape;
          norm += shape * shape;
        }
      }
      return sum / norm;
    }
  }

  return { Engine, TAU, indexAt };
})();

if (typeof module !== 'undefined') module.exports = ComplexPhi4;
