'use strict';

/* v0.4.2 admission receipt. Every assertion targets a declared update law,
 * symmetry action, or explicitly transient seed property. Open studies are
 * intentionally excluded. */
const assert = require('node:assert/strict');
const Core = require('../src/core.js');
const Phi4 = require('../src/carriers/complex-phi4.js');
const Dirac = require('../src/carriers/massive-dirac.js');
const Gauge = require('../src/carriers/gauge.js');

const max = (values) => Math.max(...values);
const relative = (value, base) => Math.abs(value - base) / Math.max(Math.abs(base), 1e-14);

function measuredOmega(engine, sample, steps = 720) {
  const crossings = [];
  let previous = sample(), time = 0;
  for (let i = 0; i < steps; i += 1) {
    engine.step(); time += engine.dt;
    const next = sample();
    if ((previous <= 0 && next > 0) || (previous >= 0 && next < 0)) crossings.push(time - engine.dt * Math.abs(next) / (Math.abs(previous) + Math.abs(next)));
    previous = next;
  }
  assert.ok(crossings.length >= 3, `frequency read requires crossings; received ${crossings.length}`);
  const gaps = crossings.slice(1).map((value, i) => value - crossings[i]);
  const halfPeriod = gaps.reduce((sum, value) => sum + value, 0) / gaps.length;
  return Math.PI / halfPeriod;
}

function phi4Receipt() {
  const vortex = Core.makeEngine('phi4', 64, 64);
  const seedWinding = vortex.windingNumbers();
  const seedCount = vortex.vortexCount();
  assert.ok(Math.abs(seedWinding[0] - 1) < 2e-12 && Math.abs(seedWinding[1] + 1) < 2e-12, `vortex seed winding ${seedWinding}`);
  assert.deepEqual(seedCount, { positive: 1, negative: 1, total: 2 }, `seed plaquette count ${JSON.stringify(seedCount)}`);
  vortex.step(150);
  const transientCount = vortex.vortexCount();
  assert.deepEqual(transientCount, { positive: 1, negative: 1, total: 2 }, `transient plaquette count ${JSON.stringify(transientCount)}`);

  // Identically prepared branches isolate the U(1) action after a finite pulse.
  const branch = Core.makeEngine('phi4', 64, 64); branch.inject(20, 28, { phase: .37 }); branch.step(200);
  const phaseBranch = Core.makeEngine('phi4', 64, 64); phaseBranch.inject(20, 28, { phase: .37 }); phaseBranch.rotateGlobal(37); phaseBranch.step(200);
  const u1Residual = max(Array.from({ length: branch.size }, (_, i) => Math.abs(branch.densityAt(i) - phaseBranch.densityAt(i))));
  assert.ok(u1Residual < 3e-11, `phi4 post-pulse U(1) residual ${u1Residual}`);
  const charge0 = branch.charge(); branch.step(500);
  const chargeDrift = relative(branch.charge(), charge0);
  assert.ok(chargeDrift < 3e-10, `phi4 charge drift ${chargeDrift}`);

  const radial = new Phi4.Engine({ width: 48, height: 48 });
  const radialMode = radial.setRadialMode(1e-4); const radialMeasured = measuredOmega(radial, () => radial.modeProjection('re', 0, 0) - radial.v);
  const radialResidual = Math.abs(radialMeasured - radialMode.omega);
  assert.ok(radialResidual < 2e-3, `radial dispersion residual ${radialResidual}`);
  const goldstone = new Phi4.Engine({ width: 48, height: 48 });
  const goldstoneMode = goldstone.setGoldstoneMode(1, 0, 1e-4); const goldstoneMeasured = measuredOmega(goldstone, () => goldstone.modeProjection('im', goldstoneMode.kx, goldstoneMode.ky));
  const goldstoneResidual = Math.abs(goldstoneMeasured - goldstoneMode.omega);
  assert.ok(goldstoneResidual < 2e-3, `Goldstone dispersion residual ${goldstoneResidual}`);
  return { seedWinding, seedCount, transientCount, u1Residual, chargeDrift, radialMeasured, radialResidual, goldstoneMeasured, goldstoneResidual };
}

function spinorReceipt() {
  const weyl = Core.makeEngine('neutrino', 64, 64);
  const read = weyl.read();
  const relationResidual = Math.max(Math.abs(read.current.x - read.spin.x), Math.abs(read.current.y - read.spin.y));
  const currentMagnitude = Math.hypot(read.current.x, read.current.y);
  assert.ok(relationResidual < 2e-12, `Weyl current / spin residual ${relationResidual}`);
  assert.ok(currentMagnitude > .98, `Weyl current magnitude ${currentMagnitude}`);
  return { relationResidual, currentMagnitude };
}

function noetherReceipt() {
  const uniform = Core.makeEngine('noether', 64, 64);
  uniform.reNow.fill(1); uniform.imNow.fill(0); uniform.rePrev.fill(1); uniform.imPrev.fill(0);
  const unresolved = uniform.read().centroid;
  assert.equal(unresolved.resolved, false, 'uniform Noether–Klein field has no circular centroid');
  assert.equal(unresolved.x, null, 'unresolved Noether–Klein x is null');
  assert.equal(unresolved.y, null, 'unresolved Noether–Klein y is null');

  const field = Core.makeEngine('noether');
  const seedCharge = field.read().charge;
  field.inject();
  const pulseBaseline = field.baseline.charge;
  const pulseChange = relative(pulseBaseline, seedCharge);
  assert.ok(pulseChange > .1, `Noether–Klein pulse changes the declared charge state ${pulseChange}`);
  assert.ok(Math.abs(field.read().charge - pulseBaseline) < 2e-12, 'Noether–Klein baseline resets after pulse');
  for (let i = 0; i < 3000; i += 1) field.step();
  const postPulseDrift = relative(field.read().charge, pulseBaseline);
  assert.ok(postPulseDrift < 1e-10, `Noether–Klein post-pulse charge drift ${postPulseDrift}`);
  assert.equal(field.audit(field.read()), 'PASS · U(1) charge proxy', 'Noether–Klein audit compares with the post-pulse baseline');
  return { centroidResolved: unresolved.resolved, pulseChange, postPulseDrift };
}

function diracReceipt() {
  const packet = Core.makeEngine('dirac', 64, 64); const norm0 = packet.read().norm; packet.inject(29, 31); const normPulse = packet.read().norm;
  assert.ok(Math.abs(normPulse - norm0) < 3e-12, `Dirac unitary pulse residual ${Math.abs(normPulse - norm0)}`);
  for (let i = 0; i < 120; i += 1) packet.step(); const normResidual = Math.abs(packet.read().norm - norm0);
  assert.ok(normResidual < 3e-11, `Dirac norm residual ${normResidual}`);
  const uniform = Core.makeEngine('dirac', 64, 64), amplitude = 1 / Math.sqrt(uniform.size);
  uniform.aRe.fill(amplitude); uniform.aIm.fill(0); uniform.bRe.fill(0); uniform.bIm.fill(0);
  const unresolved = uniform.read().current;
  assert.equal(unresolved.resolved, false, 'uniform torus state has no circular centroid');
  assert.equal(unresolved.x, null, 'unresolved torus x is null');
  assert.equal(unresolved.y, null, 'unresolved torus y is null');
  const positive = Dirac.phaseEnergyMeasurement(.51, .23, .74, 1), negative = Dirac.phaseEnergyMeasurement(.51, .23, .74, -1), zitter = Dirac.zitterbewegungMeasurement(.51, .23, .74);
  assert.ok(Math.abs(positive.residual) < 2e-12 && Math.abs(negative.residual) < 2e-12, 'Dirac ± dispersion');
  assert.ok(Math.abs(zitter.residual) < 2e-12 && Math.abs(zitter.velocityChange) > 1e-5, 'Dirac 2E beat');
  return { normResidual, centroidResolved: unresolved.resolved, positiveResidual: positive.residual, negativeResidual: negative.residual, zitterResidual: zitter.residual };
}

function oscillationReceipt() {
  const pure = Core.makeEngine('oscillation', 64, 64); for (let i = 0; i < 181; i += 1) pure.step(.125); const closed = pure.read();
  const closedResidual = Math.abs(closed.betaProbability - closed.expectedTransition);
  assert.ok(closed.closedFormApplies && closedResidual < 2e-12 && Math.abs(closed.totalProbability - 1) < 2e-12, `oscillation residual ${closedResidual}`);
  pure.inject(60, 32); const pulsed = pure.read();
  assert.ok(!pulsed.closedFormApplies && Math.abs(pulsed.energyProxy - pulsed.betaProbability) < 2e-12, 'pulsed oscillation reads measured Pβ');
  return { closedResidual, probabilityResidual: Math.abs(closed.totalProbability - 1) };
}

function unitaryResidual(matrix) {
  const product = Gauge.matrixMultiply(matrix, Gauge.matrixDagger(matrix));
  let residual = 0;
  for (let row = 0; row < 3; row += 1) for (let col = 0; col < 3; col += 1) {
    const i = row * 3 + col;
    residual = Math.max(residual, Math.abs(product.re[i] - (row === col ? 1 : 0)), Math.abs(product.im[i]));
  }
  return residual;
}

function gaugeReceipt() {
  const flux = new Gauge.U1FluxRingEngine(96, 96, 96); const fluxNorm0 = flux.read().norm; flux.step(500);
  const fluxNormResidual = Math.abs(flux.read().norm - fluxNorm0), fluxCovariance = flux.gaugeCovarianceResidual(17);
  const largeGaugeResidual = new Gauge.U1FluxRingEngine(96, 96, 96).largeGaugeResidual(400);
  const halfFluxResponse = new Gauge.U1FluxRingEngine(96, 96, 96).halfFluxResponse(400);
  assert.ok(fluxNormResidual < 3e-12, `U(1) norm residual ${fluxNormResidual}`);
  assert.ok(fluxCovariance < 2e-12, `U(1) local covariance residual ${fluxCovariance}`);
  assert.ok(largeGaugeResidual < 3e-12, `U(1) large-gauge residual ${largeGaugeResidual}`);
  assert.ok(halfFluxResponse > 1e-4, `U(1) half-flux response ${halfFluxResponse}`);

  const colour = new Gauge.SU3ColorTransportEngine(48, 48); const colourNorm0 = colour.read().norm; colour.step(180);
  const colourNormResidual = Math.abs(colour.read().norm - colourNorm0), colourCovariance = colour.gaugeCovarianceResidual(9);
  const gauges = colour.gaugeMatrices(), probeGauge = gauges[colour.index(7, 9)];
  const gaugeUnitaryResidual = unitaryResidual(probeGauge);
  const gaugeDeterminant = Gauge.matrixDet(probeGauge);
  const gaugeDeterminantResidual = Math.hypot(gaugeDeterminant.re - 1, gaugeDeterminant.im);
  const nonDiagonalMagnitude = Math.max(...[1, 2, 3, 5, 6, 7].map((i) => Math.hypot(probeGauge.re[i], probeGauge.im[i])));
  const singlet = colour.colourSingletResidual(9), plaquetteResidual = colour.plaquetteGaugeResidual(), wilsonResidual = colour.wilsonLoopGaugeResidual();
  const plaquette = colour.plaquetteTrace(), wilson = colour.wilsonLoopTrace(2, 1), curvature = 1 - plaquette.re / 3;
  assert.ok(colourNormResidual < 4e-11, `SU(3) norm residual ${colourNormResidual}`);
  assert.ok(gaugeUnitaryResidual < 3e-12 && gaugeDeterminantResidual < 3e-12 && nonDiagonalMagnitude > 1e-3, `general SU(3) gauge transform ${gaugeUnitaryResidual}, ${gaugeDeterminantResidual}, ${nonDiagonalMagnitude}`);
  assert.ok(colourCovariance < 3e-12, `SU(3) general covariance residual ${colourCovariance}`);
  assert.ok(singlet.magnitude > 1e-7 && singlet.residual < 3e-12, `SU(3) evolved singlet ${JSON.stringify(singlet)}`);
  assert.ok(plaquetteResidual < 3e-12 && wilsonResidual < 3e-12, `SU(3) loop residuals ${plaquetteResidual}, ${wilsonResidual}`);
  assert.ok(curvature > 1e-4 && Math.hypot(wilson.re, wilson.im) > 1e-3, `SU(3) nontrivial loops ${curvature}, ${JSON.stringify(wilson)}`);
  return { fluxNormResidual, fluxCovariance, largeGaugeResidual, halfFluxResponse, colourNormResidual, gaugeUnitaryResidual, gaugeDeterminantResidual, nonDiagonalMagnitude, colourCovariance, singlet, plaquetteResidual, wilsonResidual, curvature, plaquette, wilson };
}

console.log(JSON.stringify({ phi4: phi4Receipt(), spinor: spinorReceipt(), noether: noetherReceipt(), dirac: diracReceipt(), oscillation: oscillationReceipt(), gauge: gaugeReceipt() }, null, 2));
