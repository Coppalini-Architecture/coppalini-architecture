/*
 * Clear Onyx v0.5 — finite electroweak Higgs-doublet carrier.
 *
 * Field: Phi_x in C^2 with hypercharge Y = 1.
 * Gauge links: L_(x,mu) = exp(i g' B_(x,mu) / 2) U_(x,mu), U in SU(2).
 * Potential: V(Phi) = lambda (Phi^dagger Phi - v^2 / 2)^2.
 * Update: centered leapfrog with the gauge-covariant nearest-neighbour
 * lattice Laplacian in two spatial dimensions.
 *
 * This module is browser and Node compatible. It models the electroweak
 * Higgs sector on a declared finite 2+1D lattice; the background links are
 * fixed during a run so that the doublet's covariant dynamics are readable.
 */
'use strict';

const ElectroweakHiggs = (() => {
  const TAU = Math.PI * 2;
  const SQRT2 = Math.SQRT2;
  const mod = (value, divisor) => ((value % divisor) + divisor) % divisor;
  const clamp = (value, low, high) => Math.min(high, Math.max(low, value));

  const cmul = (ar, ai, br, bi) => [ar * br - ai * bi, ar * bi + ai * br];

  function matrixIdentity() {
    const re = new Float64Array(4), im = new Float64Array(4);
    re[0] = re[3] = 1;
    return { re, im };
  }

  function matrixClone(matrix) {
    return { re: new Float64Array(matrix.re), im: new Float64Array(matrix.im) };
  }

  function matrixDagger(matrix) {
    const re = new Float64Array(4), im = new Float64Array(4);
    re[0] = matrix.re[0]; im[0] = -matrix.im[0];
    re[1] = matrix.re[2]; im[1] = -matrix.im[2];
    re[2] = matrix.re[1]; im[2] = -matrix.im[1];
    re[3] = matrix.re[3]; im[3] = -matrix.im[3];
    return { re, im };
  }

  function matrixMultiply(left, right) {
    const re = new Float64Array(4), im = new Float64Array(4);
    for (let row = 0; row < 2; row += 1) for (let column = 0; column < 2; column += 1) {
      const index = row * 2 + column;
      for (let k = 0; k < 2; k += 1) {
        const [rr, ii] = cmul(left.re[row * 2 + k], left.im[row * 2 + k], right.re[k * 2 + column], right.im[k * 2 + column]);
        re[index] += rr; im[index] += ii;
      }
    }
    return { re, im };
  }

  function matrixPhase(matrix, phase) {
    const cosine = Math.cos(phase), sine = Math.sin(phase), re = new Float64Array(4), im = new Float64Array(4);
    for (let i = 0; i < 4; i += 1) {
      re[i] = cosine * matrix.re[i] - sine * matrix.im[i];
      im[i] = sine * matrix.re[i] + cosine * matrix.im[i];
    }
    return { re, im };
  }

  // exp(i angle n.sigma), with a normalized real axis n.
  function su2Exponential(nx, ny, nz, angle) {
    const length = Math.hypot(nx, ny, nz) || 1;
    const x = nx / length, y = ny / length, z = nz / length;
    const cosine = Math.cos(angle), sine = Math.sin(angle);
    const re = new Float64Array(4), im = new Float64Array(4);
    re[0] = re[3] = cosine;
    im[0] = sine * z; im[3] = -sine * z;
    re[1] = sine * y; im[1] = sine * x;
    re[2] = -sine * y; im[2] = sine * x;
    return { re, im };
  }

  function multiplyInto(matrix, ar, ai, br, bi, out) {
    const re = matrix.re, im = matrix.im;
    out[0] = re[0] * ar - im[0] * ai + re[1] * br - im[1] * bi;
    out[1] = im[0] * ar + re[0] * ai + im[1] * br + re[1] * bi;
    out[2] = re[2] * ar - im[2] * ai + re[3] * br - im[3] * bi;
    out[3] = im[2] * ar + re[2] * ai + im[3] * br + re[3] * bi;
    return out;
  }

  function daggerMultiplyInto(matrix, ar, ai, br, bi, out) {
    const re = matrix.re, im = matrix.im;
    out[0] = re[0] * ar + im[0] * ai + re[2] * br + im[2] * bi;
    out[1] = -im[0] * ar + re[0] * ai - im[2] * br + re[2] * bi;
    out[2] = re[1] * ar + im[1] * ai + re[3] * br + im[3] * bi;
    out[3] = -im[1] * ar + re[1] * ai - im[3] * br + re[3] * bi;
    return out;
  }

  function phaseVectorInto(phase, ar, ai, br, bi, out) {
    const cosine = Math.cos(phase), sine = Math.sin(phase);
    out[0] = cosine * ar - sine * ai; out[1] = sine * ar + cosine * ai;
    out[2] = cosine * br - sine * bi; out[3] = sine * br + cosine * bi;
    return out;
  }

  function matrixUnitarityResidual(matrix) {
    const product = matrixMultiply(matrixDagger(matrix), matrix);
    let residual = 0;
    for (let row = 0; row < 2; row += 1) for (let column = 0; column < 2; column += 1) {
      const index = row * 2 + column;
      residual = Math.max(residual, Math.abs(product.re[index] - (row === column ? 1 : 0)), Math.abs(product.im[index]));
    }
    return residual;
  }

  function hermitianEigenvalues(matrix) {
    // Jacobi rotations for a real symmetric matrix. The Higgs mass matrix is
    // constructed from the covariant derivative, before this diagonalization.
    const a = matrix.map((row) => row.slice());
    const n = a.length;
    for (let iteration = 0; iteration < 96; iteration += 1) {
      let p = 0, q = 1, largest = 0;
      for (let row = 0; row < n; row += 1) for (let column = row + 1; column < n; column += 1) {
        const magnitude = Math.abs(a[row][column]);
        if (magnitude > largest) { largest = magnitude; p = row; q = column; }
      }
      if (largest < 1e-15) break;
      const angle = .5 * Math.atan2(2 * a[p][q], a[q][q] - a[p][p]);
      const cosine = Math.cos(angle), sine = Math.sin(angle);
      const app = a[p][p], aqq = a[q][q], apq = a[p][q];
      for (let k = 0; k < n; k += 1) {
        if (k === p || k === q) continue;
        const akp = a[k][p], akq = a[k][q];
        a[k][p] = a[p][k] = cosine * akp - sine * akq;
        a[k][q] = a[q][k] = sine * akp + cosine * akq;
      }
      a[p][p] = cosine * cosine * app - 2 * sine * cosine * apq + sine * sine * aqq;
      a[q][q] = sine * sine * app + 2 * sine * cosine * apq + cosine * cosine * aqq;
      a[p][q] = a[q][p] = 0;
    }
    return a.map((row, index) => row[index]).sort((left, right) => left - right);
  }

  class Engine {
    constructor(options = {}) {
      this.width = options.width || 96;
      this.height = options.height || 96;
      this.size = this.width * this.height;
      this.dt = options.dt || .052;
      this.c = options.c || 1;
      this.lambda = options.lambda || .34;
      this.v = options.v || 1;
      this.g = options.g || .653;
      this.gPrime = options.gPrime || .358;
      this.background = options.background || 'curved';
      this.courant2 = (this.c * this.dt) ** 2;
      this.potentialDt2 = this.dt ** 2;
      if (this.courant2 > .5) throw new Error('Electroweak Higgs lattice requires (c dt)^2 <= 0.5.');
      this.aReNow = new Float64Array(this.size); this.aImNow = new Float64Array(this.size);
      this.bReNow = new Float64Array(this.size); this.bImNow = new Float64Array(this.size);
      this.aRePrev = new Float64Array(this.size); this.aImPrev = new Float64Array(this.size);
      this.bRePrev = new Float64Array(this.size); this.bImPrev = new Float64Array(this.size);
      this.aReNext = new Float64Array(this.size); this.aImNext = new Float64Array(this.size);
      this.bReNext = new Float64Array(this.size); this.bImNext = new Float64Array(this.size);
      this.scratch = new Float64Array(4);
      this.frame = 0;
      this.pulses = [];
      this.baseLinkX = this.makeBaseLink('x');
      this.baseLinkY = this.makeBaseLink('y');
      this.localX = null;
      this.localY = null;
      this.linkResidual = this.linkUnitarityResidual();
      this.seed();
    }

    index(x, y) { return mod(y, this.height) * this.width + mod(x, this.width); }

    makeBaseLink(direction) {
      if (this.background === 'identity') return matrixIdentity();
      if (direction === 'x') return matrixPhase(su2Exponential(.71, .31, .63, .188), .127);
      return matrixPhase(su2Exponential(-.22, .91, .35, .151), -.093);
    }

    link(direction, index) {
      const local = direction === 'x' ? this.localX : this.localY;
      if (local) return local[index];
      return direction === 'x' ? this.baseLinkX : this.baseLinkY;
    }

    densityAt(index) {
      return this.aReNow[index] ** 2 + this.aImNow[index] ** 2 + this.bReNow[index] ** 2 + this.bImNow[index] ** 2;
    }

    radialAt(index) { return Math.sqrt(2 * this.densityAt(index)); }

    setDoublet(index, target, ar, ai, br, bi) {
      target.aRe[index] = ar; target.aIm[index] = ai;
      target.bRe[index] = br; target.bIm[index] = bi;
    }

    seed() {
      const centreX = this.width * .33, centreY = this.height * .50;
      const spread = Math.min(this.width, this.height) * .145;
      const kx = .23, ky = .09, amplitude = .25;
      const previousPhase = this.radialOmega(kx, ky) * this.dt;
      const now = { aRe: this.aReNow, aIm: this.aImNow, bRe: this.bReNow, bIm: this.bImNow };
      const previous = { aRe: this.aRePrev, aIm: this.aImPrev, bRe: this.bRePrev, bIm: this.bImPrev };
      for (let y = 0; y < this.height; y += 1) for (let x = 0; x < this.width; x += 1) {
        const index = this.index(x, y), dx = x - centreX, dy = y - centreY;
        const envelope = Math.exp(-(dx * dx + dy * dy) / (2 * spread * spread));
        const argument = kx * dx + ky * dy;
        const radialNow = this.v + amplitude * envelope * Math.cos(argument);
        const radialPrevious = this.v + amplitude * envelope * Math.cos(argument + previousPhase);
        const twist = .44 * envelope * Math.sin(.16 * dx - .10 * dy);
        const rotation = su2Exponential(.46, .78, .42, twist);
        multiplyInto(rotation, 0, 0, radialNow / SQRT2, 0, this.scratch);
        this.setDoublet(index, now, this.scratch[0], this.scratch[1], this.scratch[2], this.scratch[3]);
        multiplyInto(rotation, 0, 0, radialPrevious / SQRT2, 0, this.scratch);
        this.setDoublet(index, previous, this.scratch[0], this.scratch[1], this.scratch[2], this.scratch[3]);
      }
      this.aReNext.fill(0); this.aImNext.fill(0); this.bReNext.fill(0); this.bImNext.fill(0);
      this.frame = 0;
      this.pulses.length = 0;
      this.baseline = this.read();
    }

    step(count = 1) {
      for (let turn = 0; turn < count; turn += 1) {
        const { width, height, aReNow, aImNow, bReNow, bImNow, aRePrev, aImPrev, bRePrev, bImPrev, aReNext, aImNext, bReNext, bImNext } = this;
        const halfV2 = this.v * this.v * .5;
        for (let y = 0; y < height; y += 1) for (let x = 0; x < width; x += 1) {
          const index = y * width + x;
          const left = this.index(x - 1, y), right = this.index(x + 1, y), up = this.index(x, y - 1), down = this.index(x, y + 1);
          const ar = aReNow[index], ai = aImNow[index], br = bReNow[index], bi = bImNow[index];
          let lapAr = -4 * ar, lapAi = -4 * ai, lapBr = -4 * br, lapBi = -4 * bi;
          multiplyInto(this.link('x', index), aReNow[right], aImNow[right], bReNow[right], bImNow[right], this.scratch);
          lapAr += this.scratch[0]; lapAi += this.scratch[1]; lapBr += this.scratch[2]; lapBi += this.scratch[3];
          daggerMultiplyInto(this.link('x', left), aReNow[left], aImNow[left], bReNow[left], bImNow[left], this.scratch);
          lapAr += this.scratch[0]; lapAi += this.scratch[1]; lapBr += this.scratch[2]; lapBi += this.scratch[3];
          multiplyInto(this.link('y', index), aReNow[down], aImNow[down], bReNow[down], bImNow[down], this.scratch);
          lapAr += this.scratch[0]; lapAi += this.scratch[1]; lapBr += this.scratch[2]; lapBi += this.scratch[3];
          daggerMultiplyInto(this.link('y', up), aReNow[up], aImNow[up], bReNow[up], bImNow[up], this.scratch);
          lapAr += this.scratch[0]; lapAi += this.scratch[1]; lapBr += this.scratch[2]; lapBi += this.scratch[3];
          const radialForce = 2 * this.lambda * (ar * ar + ai * ai + br * br + bi * bi - halfV2);
          aReNext[index] = 2 * ar - aRePrev[index] + this.courant2 * lapAr - this.potentialDt2 * radialForce * ar;
          aImNext[index] = 2 * ai - aImPrev[index] + this.courant2 * lapAi - this.potentialDt2 * radialForce * ai;
          bReNext[index] = 2 * br - bRePrev[index] + this.courant2 * lapBr - this.potentialDt2 * radialForce * br;
          bImNext[index] = 2 * bi - bImPrev[index] + this.courant2 * lapBi - this.potentialDt2 * radialForce * bi;
        }
        [this.aRePrev, this.aReNow, this.aReNext] = [this.aReNow, this.aReNext, this.aRePrev];
        [this.aImPrev, this.aImNow, this.aImNext] = [this.aImNow, this.aImNext, this.aImPrev];
        [this.bRePrev, this.bReNow, this.bReNext] = [this.bReNow, this.bReNext, this.bRePrev];
        [this.bImPrev, this.bImNow, this.bImNext] = [this.bImNow, this.bImNext, this.bImPrev];
        this.frame += 1;
      }
    }

    inject(x = this.width * .5, y = this.height * .5) {
      const spread = Math.max(3, Math.min(this.width, this.height) * .075);
      for (let row = 0; row < this.height; row += 1) for (let column = 0; column < this.width; column += 1) {
        const index = this.index(column, row);
        const envelope = .18 * Math.exp(-((column - x) ** 2 + (row - y) ** 2) / (2 * spread * spread));
        // A radial kick plus a local weak-isospin rotation is a declared local
        // condition. Both time slices are updated, preserving the leapfrog state.
        this.bReNow[index] += envelope / SQRT2;
        this.bRePrev[index] += envelope * .38 / SQRT2;
        const rotation = su2Exponential(.62, -.51, .59, envelope * 1.7);
        multiplyInto(rotation, this.aReNow[index], this.aImNow[index], this.bReNow[index], this.bImNow[index], this.scratch);
        this.aReNow[index] = this.scratch[0]; this.aImNow[index] = this.scratch[1]; this.bReNow[index] = this.scratch[2]; this.bImNow[index] = this.scratch[3];
        multiplyInto(rotation, this.aRePrev[index], this.aImPrev[index], this.bRePrev[index], this.bImPrev[index], this.scratch);
        this.aRePrev[index] = this.scratch[0]; this.aImPrev[index] = this.scratch[1]; this.bRePrev[index] = this.scratch[2]; this.bImPrev[index] = this.scratch[3];
      }
      this.pulses.push({ x: x / this.width, y: y / this.height, frame: this.frame });
    }

    rotateGlobal(degrees) {
      const phase = degrees * Math.PI / 180 / 2;
      for (const names of [['aReNow', 'aImNow', 'bReNow', 'bImNow'], ['aRePrev', 'aImPrev', 'bRePrev', 'bImPrev']]) {
        const [arName, aiName, brName, biName] = names;
        for (let index = 0; index < this.size; index += 1) {
          phaseVectorInto(phase, this[arName][index], this[aiName][index], this[brName][index], this[biName][index], this.scratch);
          this[arName][index] = this.scratch[0]; this[aiName][index] = this.scratch[1]; this[brName][index] = this.scratch[2]; this[biName][index] = this.scratch[3];
        }
      }
    }

    visualAt(index) {
      const ar = this.aReNow[index], ai = this.aImNow[index], br = this.bReNow[index], bi = this.bImNow[index];
      const rho = ar * ar + ai * ai + br * br + bi * bi;
      const modulus = Math.sqrt(2 * rho);
      // This weak-isospin longitude belongs to the displayed gauge choice.
      const nx = 2 * (ar * br + ai * bi) / Math.max(rho, 1e-14);
      const ny = 2 * (ar * bi - ai * br) / Math.max(rho, 1e-14);
      const nz = (ar * ar + ai * ai - br * br - bi * bi) / Math.max(rho, 1e-14);
      return {
        density: Math.abs(modulus - this.v) / Math.max(this.v, 1e-12),
        phase: Math.atan2(ny, nx),
        spin: { x: nx, y: ny, z: nz }
      };
    }

    currentAt(x, y) {
      const index = this.index(x, y), right = this.index(x + 1, y), down = this.index(x, y + 1);
      const ar = this.aReNow[index], ai = this.aImNow[index], br = this.bReNow[index], bi = this.bImNow[index];
      multiplyInto(this.link('x', index), this.aReNow[right], this.aImNow[right], this.bReNow[right], this.bImNow[right], this.scratch);
      const jx = 2 * (ar * this.scratch[1] - ai * this.scratch[0] + br * this.scratch[3] - bi * this.scratch[2]);
      multiplyInto(this.link('y', index), this.aReNow[down], this.aImNow[down], this.bReNow[down], this.bImNow[down], this.scratch);
      const jy = 2 * (ar * this.scratch[1] - ai * this.scratch[0] + br * this.scratch[3] - bi * this.scratch[2]);
      return { x: jx, y: jy, magnitude: Math.hypot(jx, jy) };
    }

    read() {
      let magnitude = 0, energy = 0, radial = 0, jx = 0, jy = 0;
      for (let y = 0; y < this.height; y += 1) for (let x = 0; x < this.width; x += 1) {
        const index = this.index(x, y), right = this.index(x + 1, y), down = this.index(x, y + 1);
        const ar = this.aReNow[index], ai = this.aImNow[index], br = this.bReNow[index], bi = this.bImNow[index];
        const rho = ar * ar + ai * ai + br * br + bi * bi;
        const h = Math.sqrt(2 * rho);
        const velocity2 = ((ar - this.aRePrev[index]) / this.dt) ** 2 + ((ai - this.aImPrev[index]) / this.dt) ** 2 + ((br - this.bRePrev[index]) / this.dt) ** 2 + ((bi - this.bImPrev[index]) / this.dt) ** 2;
        multiplyInto(this.link('x', index), this.aReNow[right], this.aImNow[right], this.bReNow[right], this.bImNow[right], this.scratch);
        const gradientX2 = (this.scratch[0] - ar) ** 2 + (this.scratch[1] - ai) ** 2 + (this.scratch[2] - br) ** 2 + (this.scratch[3] - bi) ** 2;
        const currentX = 2 * (ar * this.scratch[1] - ai * this.scratch[0] + br * this.scratch[3] - bi * this.scratch[2]);
        multiplyInto(this.link('y', index), this.aReNow[down], this.aImNow[down], this.bReNow[down], this.bImNow[down], this.scratch);
        const gradientY2 = (this.scratch[0] - ar) ** 2 + (this.scratch[1] - ai) ** 2 + (this.scratch[2] - br) ** 2 + (this.scratch[3] - bi) ** 2;
        const currentY = 2 * (ar * this.scratch[1] - ai * this.scratch[0] + br * this.scratch[3] - bi * this.scratch[2]);
        magnitude += rho;
        radial += h / this.v - 1;
        jx += currentX; jy += currentY;
        energy += .5 * velocity2 + .5 * this.c * this.c * (gradientX2 + gradientY2) + this.lambda * (rho - this.v * this.v * .5) ** 2;
      }
      const radialMean = radial / this.size, currentX = jx / this.size, currentY = jy / this.size;
      return {
        norm: magnitude / Math.max(this.size * this.v * this.v * .5, 1e-14),
        energyProxy: energy / this.size,
        current: { x: currentX, y: currentY },
        spin: { x: clamp(radialMean * 2.5, -1, 1), y: clamp(currentX * 5, -1, 1), z: clamp(currentY * 5, -1, 1) },
        radialMean,
        linkResidual: this.linkResidual
      };
    }

    audit() {
      return this.linkResidual < 3e-12 ? 'PASS · SU(2)×U(1) link action' : 'WATCH · link unitarity residual';
    }

    radialMass() { return Math.sqrt(2 * this.lambda) * this.v; }

    radialOmega(kx = 0, ky = 0) {
      const latticeK2 = 4 * (Math.sin(kx / 2) ** 2 + Math.sin(ky / 2) ** 2);
      const continuum = this.radialMass() ** 2 + this.c * this.c * latticeK2;
      return 2 / this.dt * Math.asin(Math.min(1, this.dt * Math.sqrt(continuum) / 2));
    }

    setRadialMode(amplitude = 1e-5, kxMode = 0, kyMode = 0) {
      const kx = TAU * kxMode / this.width, ky = TAU * kyMode / this.height, omega = this.radialOmega(kx, ky);
      this.localX = null; this.localY = null;
      this.baseLinkX = matrixIdentity(); this.baseLinkY = matrixIdentity(); this.linkResidual = this.linkUnitarityResidual();
      for (let y = 0; y < this.height; y += 1) for (let x = 0; x < this.width; x += 1) {
        const index = this.index(x, y), shape = Math.cos(kx * x + ky * y);
        const now = (this.v + amplitude * shape) / SQRT2;
        const previous = (this.v + amplitude * shape * Math.cos(omega * this.dt)) / SQRT2;
        this.aReNow[index] = this.aImNow[index] = this.aRePrev[index] = this.aImPrev[index] = 0;
        this.bReNow[index] = now; this.bImNow[index] = 0;
        this.bRePrev[index] = previous; this.bImPrev[index] = 0;
      }
      this.frame = 0; this.pulses.length = 0; this.baseline = this.read();
      return { kx, ky, omega, radialMass: this.radialMass() };
    }

    radialProjection(kx = 0, ky = 0) {
      let sum = 0, norm = 0;
      for (let y = 0; y < this.height; y += 1) for (let x = 0; x < this.width; x += 1) {
        const shape = Math.cos(kx * x + ky * y);
        sum += (this.radialAt(this.index(x, y)) - this.v) * shape;
        norm += shape * shape;
      }
      return sum / Math.max(norm, 1e-14);
    }

    localGauge() {
      const su2 = new Array(this.size), hypercharge = new Float64Array(this.size);
      for (let y = 0; y < this.height; y += 1) for (let x = 0; x < this.width; x += 1) {
        const index = this.index(x, y), qx = TAU * x / this.width, qy = TAU * y / this.height;
        hypercharge[index] = .31 * Math.sin(qx + .37 * qy) + .17 * Math.cos(2 * qy - .21 * qx);
        su2[index] = su2Exponential(.61 + .12 * Math.cos(qy), .44 * Math.sin(qx), .65 + .10 * Math.cos(qx - qy), .29 * Math.sin(qx) + .18 * Math.cos(qy));
      }
      return { su2, hypercharge };
    }

    clone() {
      const copy = new Engine({ width: this.width, height: this.height, dt: this.dt, c: this.c, lambda: this.lambda, v: this.v, g: this.g, gPrime: this.gPrime, background: this.background });
      for (const key of ['aReNow', 'aImNow', 'bReNow', 'bImNow', 'aRePrev', 'aImPrev', 'bRePrev', 'bImPrev', 'aReNext', 'aImNext', 'bReNext', 'bImNext']) copy[key].set(this[key]);
      copy.baseLinkX = matrixClone(this.baseLinkX); copy.baseLinkY = matrixClone(this.baseLinkY);
      copy.localX = this.localX && this.localX.map(matrixClone); copy.localY = this.localY && this.localY.map(matrixClone);
      copy.linkResidual = this.linkResidual; copy.frame = this.frame; copy.pulses = this.pulses.map((pulse) => ({ ...pulse })); copy.baseline = copy.read();
      return copy;
    }

    gaugeTransform() {
      const copy = this.clone(), gauge = this.localGauge();
      const transformSlice = (reA, imA, reB, imB) => {
        for (let index = 0; index < this.size; index += 1) {
          multiplyInto(gauge.su2[index], reA[index], imA[index], reB[index], imB[index], this.scratch);
          phaseVectorInto(gauge.hypercharge[index] / 2, this.scratch[0], this.scratch[1], this.scratch[2], this.scratch[3], this.scratch);
          reA[index] = this.scratch[0]; imA[index] = this.scratch[1]; reB[index] = this.scratch[2]; imB[index] = this.scratch[3];
        }
      };
      transformSlice(copy.aReNow, copy.aImNow, copy.bReNow, copy.bImNow);
      transformSlice(copy.aRePrev, copy.aImPrev, copy.bRePrev, copy.bImPrev);
      copy.localX = new Array(this.size); copy.localY = new Array(this.size);
      for (let y = 0; y < this.height; y += 1) for (let x = 0; x < this.width; x += 1) {
        const index = this.index(x, y), right = this.index(x + 1, y), down = this.index(x, y + 1);
        const transformLink = (direction, neighbour) => matrixPhase(matrixMultiply(matrixMultiply(gauge.su2[index], this.link(direction, index)), matrixDagger(gauge.su2[neighbour])), (gauge.hypercharge[index] - gauge.hypercharge[neighbour]) / 2);
        copy.localX[index] = transformLink('x', right);
        copy.localY[index] = transformLink('y', down);
      }
      copy.linkResidual = copy.linkUnitarityResidual();
      return copy;
    }

    gaugeCovarianceResidual(steps = 11) {
      const base = this.clone(), transformed = this.gaugeTransform();
      base.step(steps); transformed.step(steps);
      const expected = base.gaugeTransform();
      let residual = 0;
      for (const key of ['aReNow', 'aImNow', 'bReNow', 'bImNow']) for (let index = 0; index < this.size; index += 1) residual = Math.max(residual, Math.abs(expected[key][index] - transformed[key][index]));
      return residual;
    }

    gaugeInvariantDensityResidual(steps = 0) {
      const base = this.clone(), transformed = this.gaugeTransform();
      if (steps) { base.step(steps); transformed.step(steps); }
      let residual = 0;
      for (let index = 0; index < this.size; index += 1) residual = Math.max(residual, Math.abs(base.densityAt(index) - transformed.densityAt(index)));
      return residual;
    }

    linkUnitarityResidual() {
      let residual = 0;
      if (this.localX) {
        for (let index = 0; index < this.size; index += 1) residual = Math.max(residual, matrixUnitarityResidual(this.localX[index]), matrixUnitarityResidual(this.localY[index]));
      } else residual = Math.max(matrixUnitarityResidual(this.baseLinkX), matrixUnitarityResidual(this.baseLinkY));
      return residual;
    }

    gaugeMassQuadratic(fields) {
      const [w1, w2, w3, b] = fields;
      const lower = this.v / SQRT2;
      const upperRe = this.g * w1 * lower / 2;
      const upperIm = -this.g * w2 * lower / 2;
      const lowerRe = (-this.g * w3 + this.gPrime * b) * lower / 2;
      return 2 * (upperRe * upperRe + upperIm * upperIm + lowerRe * lowerRe);
    }

    gaugeMassMatrix() {
      const matrix = Array.from({ length: 4 }, () => Array(4).fill(0));
      const unit = (index) => { const out = [0, 0, 0, 0]; out[index] = 1; return out; };
      for (let row = 0; row < 4; row += 1) {
        matrix[row][row] = this.gaugeMassQuadratic(unit(row));
        for (let column = row + 1; column < 4; column += 1) {
          const sum = unit(row); sum[column] = 1;
          const value = (this.gaugeMassQuadratic(sum) - matrix[row][row] - this.gaugeMassQuadratic(unit(column))) / 2;
          matrix[row][column] = matrix[column][row] = value;
        }
      }
      return matrix;
    }

    massSpectrum() {
      const mW = this.g * this.v / 2;
      const mZ = Math.hypot(this.g, this.gPrime) * this.v / 2;
      const thetaW = Math.atan2(this.gPrime, this.g);
      return { mW, mZ, mPhoton: 0, thetaW };
    }

    spectrumResidual(matrix = this.gaugeMassMatrix(), spectrum = this.massSpectrum()) {
      const eigenvalues = hermitianEigenvalues(matrix);
      const expected = [spectrum.mPhoton ** 2, spectrum.mW ** 2, spectrum.mW ** 2, spectrum.mZ ** 2].sort((left, right) => left - right);
      let residual = 0;
      for (let index = 0; index < expected.length; index += 1) residual = Math.max(residual, Math.abs(eigenvalues[index] - expected[index]));
      return { eigenvalues, expected, residual };
    }

    massSpectrumReceipt() {
      const spectrum = this.massSpectrum(), matrix = this.gaugeMassMatrix(), diagonal = this.spectrumResidual(matrix, spectrum);
      const ratioResidual = Math.abs(spectrum.mW / spectrum.mZ - Math.cos(spectrum.thetaW));
      return { ...diagonal, ratioResidual, massMatrix: matrix, spectrum };
    }
  }

  return { Engine, TAU, matrixIdentity, matrixClone, matrixDagger, matrixMultiply, matrixPhase, su2Exponential, matrixUnitarityResidual, hermitianEigenvalues };
})();

if (typeof module !== 'undefined') module.exports = ElectroweakHiggs;
