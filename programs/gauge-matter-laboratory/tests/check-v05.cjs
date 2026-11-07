'use strict';

/* v0.5 electroweak Higgs-sector receipt.
 * Each assertion targets an independently calculable property of the stated
 * finite lattice carrier. The two explicit mutations prove that the mass and
 * link receipts have a failure path. */
const assert = require('node:assert/strict');
const Core = require('../src/core.js');
const Higgs = require('../src/carriers/electroweak-higgs.js');

function measureOmega(engine, sample, steps = 1200) {
  const crossings = [];
  let previous = sample();
  let time = 0;
  for (let step = 0; step < steps; step += 1) {
    engine.step();
    time += engine.dt;
    const next = sample();
    if ((previous <= 0 && next > 0) || (previous >= 0 && next < 0)) {
      crossings.push(time - engine.dt * Math.abs(next) / Math.max(Math.abs(previous) + Math.abs(next), 1e-18));
    }
    previous = next;
  }
  assert.ok(crossings.length >= 5, `radial frequency needs crossings; received ${crossings.length}`);
  const gaps = crossings.slice(1).map((value, index) => value - crossings[index]);
  const halfPeriod = gaps.reduce((sum, value) => sum + value, 0) / gaps.length;
  return Math.PI / halfPeriod;
}

function higgsReceipt() {
  const carrier = Core.makeEngine('higgs', 48, 48);
  assert.equal(carrier.constructor, Higgs.Engine, 'selector resolves to the electroweak doublet engine');
  const initialLinkResidual = carrier.linkUnitarityResidual();
  const densityResidual = carrier.gaugeInvariantDensityResidual(9);
  const covarianceResidual = carrier.gaugeCovarianceResidual(9);
  assert.ok(initialLinkResidual < 3e-12, `electroweak link unitarity residual ${initialLinkResidual}`);
  assert.ok(densityResidual < 4e-12, `gauge-invariant Higgs modulus residual ${densityResidual}`);
  assert.ok(covarianceResidual < 4e-12, `SU(2)L × U(1)Y covariance residual ${covarianceResidual}`);

  const spectrum = carrier.massSpectrumReceipt();
  assert.ok(spectrum.residual < 3e-12, `W/Z/photon mass-matrix residual ${spectrum.residual}`);
  assert.ok(spectrum.ratioResidual < 3e-12, `Weinberg mass relation residual ${spectrum.ratioResidual}`);
  assert.ok(spectrum.eigenvalues[0] < 3e-12 && spectrum.eigenvalues[1] > 1e-4 && spectrum.eigenvalues[3] > spectrum.eigenvalues[1], `electroweak spectrum ${spectrum.eigenvalues}`);

  // Failure witness: the independent diagonalization rejects a corrupted W1
  // coefficient while the expected spectrum remains fixed.
  const corruptedMass = carrier.gaugeMassMatrix().map((row) => row.slice());
  corruptedMass[0][0] += .037;
  const massFailureWitness = carrier.spectrumResidual(corruptedMass, spectrum.spectrum).residual;
  assert.ok(massFailureWitness > 1e-3, `corrupted mass matrix must fail (${massFailureWitness})`);

  // Failure witness: the link check rejects a non-unitary perturbation.
  const brokenLink = carrier.clone();
  brokenLink.baseLinkX.re[0] *= .81;
  brokenLink.linkResidual = brokenLink.linkUnitarityResidual();
  assert.ok(brokenLink.linkResidual > 1e-3, `corrupted gauge link must fail (${brokenLink.linkResidual})`);
  assert.match(brokenLink.audit(), /^WATCH/, 'runtime link receipt exposes the failure');

  const radial = new Higgs.Engine({ width: 48, height: 48, background: 'identity' });
  const radialMode = radial.setRadialMode(1e-4, 1, 0);
  const measured = measureOmega(radial, () => radial.radialProjection(radialMode.kx, radialMode.ky));
  const radialResidual = Math.abs(measured - radialMode.omega);
  assert.ok(radialResidual < 8e-5, `Higgs radial lattice frequency residual ${radialResidual}`);
  return {
    initialLinkResidual,
    densityResidual,
    covarianceResidual,
    massResidual: spectrum.residual,
    ratioResidual: spectrum.ratioResidual,
    massFailureWitness,
    linkFailureWitness: brokenLink.linkResidual,
    radialMass: radialMode.radialMass,
    radialMeasured: measured,
    radialResidual
  };
}

console.log(JSON.stringify({ electroweakHiggs: higgsReceipt() }, null, 2));
