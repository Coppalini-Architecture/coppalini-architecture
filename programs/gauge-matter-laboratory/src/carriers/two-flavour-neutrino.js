/* Clear Onyx v0.4.2 two-flavour neutrino oscillation carrier.
 * Exact two-state flavour propagation in declared natural units.
 * Browser and Node compatible; no external dependencies.
 */
'use strict';

const TwoFlavourNeutrino = (() => {
  const clamp = (value, low, high) => Math.min(high, Math.max(low, value));
  const sq = (value) => value * value;

  function multiplyPhase(re, im, phase) {
    const c = Math.cos(phase);
    const s = Math.sin(phase);
    return [re * c - im * s, re * s + im * c];
  }

  function probability(re, im) { return re * re + im * im; }

  class OscillationEngine {
    constructor({ theta = .61, m1sq = .72, m2sq = 1.48, energy = 2.3 } = {}) {
      this.theta = theta;
      this.m1sq = m1sq;
      this.m2sq = m2sq;
      this.energy = energy;
      this.massRe = new Float64Array(2);
      this.massIm = new Float64Array(2);
      this.distance = 0;
      this.frame = 0;
      this.pulses = [];
      this.prepare('alpha');
    }

    get deltaMSq() { return this.m2sq - this.m1sq; }

    normalize() {
      const norm = probability(this.massRe[0], this.massIm[0]) + probability(this.massRe[1], this.massIm[1]);
      const scale = 1 / Math.sqrt(norm || 1);
      for (let i = 0; i < 2; i += 1) { this.massRe[i] *= scale; this.massIm[i] *= scale; }
      return norm;
    }

    flavourState() {
      const c = Math.cos(this.theta);
      const s = Math.sin(this.theta);
      return {
        alpha: { re: c * this.massRe[0] + s * this.massRe[1], im: c * this.massIm[0] + s * this.massIm[1] },
        beta: { re: -s * this.massRe[0] + c * this.massRe[1], im: -s * this.massIm[0] + c * this.massIm[1] }
      };
    }

    setFlavourState(alpha, beta) {
      const c = Math.cos(this.theta);
      const s = Math.sin(this.theta);
      this.massRe[0] = c * alpha.re - s * beta.re;
      this.massIm[0] = c * alpha.im - s * beta.im;
      this.massRe[1] = s * alpha.re + c * beta.re;
      this.massIm[1] = s * alpha.im + c * beta.im;
      this.normalize();
    }

    prepare(flavour = 'alpha') {
      const alpha = flavour === 'beta' ? { re: 0, im: 0 } : { re: 1, im: 0 };
      const beta = flavour === 'beta' ? { re: 1, im: 0 } : { re: 0, im: 0 };
      this.setFlavourState(alpha, beta);
      this.distance = 0;
      this.frame = 0;
      this.pulses.length = 0;
      this.initialFlavour = flavour;
      this.baseline = this.read();
    }

    step(deltaL = .125) {
      const phases = [-this.m1sq * deltaL / (2 * this.energy), -this.m2sq * deltaL / (2 * this.energy)];
      for (let i = 0; i < 2; i += 1) {
        const next = multiplyPhase(this.massRe[i], this.massIm[i], phases[i]);
        this.massRe[i] = next[0];
        this.massIm[i] = next[1];
      }
      this.distance += deltaL;
      this.frame += 1;
    }

    injectFlavour(flavour = 'beta', amplitude = .14, phase = this.frame * .61803398875) {
      const state = this.flavourState();
      const target = flavour === 'alpha' ? state.alpha : state.beta;
      target.re += amplitude * Math.cos(phase);
      target.im += amplitude * Math.sin(phase);
      this.setFlavourState(state.alpha, state.beta);
      this.pulses.push({ flavour, amplitude, phase, distance: this.distance, frame: this.frame });
    }

    expectedTransition(distance = this.distance) {
      const mixing = sq(Math.sin(2 * this.theta));
      const phase = this.deltaMSq * distance / (4 * this.energy);
      return mixing * sq(Math.sin(phase));
    }

    read() {
      const state = this.flavourState();
      const pa = probability(state.alpha.re, state.alpha.im);
      const pb = probability(state.beta.re, state.beta.im);
      const coherenceRe = state.alpha.re * state.beta.re + state.alpha.im * state.beta.im;
      const coherenceIm = state.alpha.re * state.beta.im - state.alpha.im * state.beta.re;
      return {
        alphaProbability: pa,
        betaProbability: pb,
        totalProbability: pa + pb,
        distance: this.distance,
        expectedTransition: this.initialFlavour === 'alpha' ? this.expectedTransition() : this.expectedTransition(),
        // A declared flavour-Bloch readout: x/y are coherence, z is flavour imbalance.
        compass: { x: 2 * coherenceRe, y: 2 * coherenceIm, z: pa - pb }
      };
    }

    audit() {
      const read = this.read();
      const normalizationResidual = Math.abs(read.totalProbability - 1);
      if (normalizationResidual > 2e-12) return 'WATCH · probability residual';
      if (this.initialFlavour === 'alpha' && this.pulses.length === 0) {
        const residual = Math.abs(read.betaProbability - read.expectedTransition);
        return residual < 2e-12 ? 'PASS · closed-form oscillation' : 'WATCH · transition residual';
      }
      return 'PASS · normalized flavour state';
    }
  }

  return { OscillationEngine, multiplyPhase, probability, clamp };
})();

if (typeof module !== 'undefined') module.exports = TwoFlavourNeutrino;
if (typeof window !== 'undefined') window.TwoFlavourNeutrino = TwoFlavourNeutrino;
