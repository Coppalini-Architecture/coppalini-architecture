import assert from "node:assert/strict";
import {
  phaseFromColor,
  phaseReverse,
  heavy_horizon,
  liftAwareRead,
  lorentzianRead,
  phaseRecord,
  verifyKernel
} from "../models/mirror-i-inverse-phase-kernel-v0.1.mjs";

const receipt = verifyKernel();
assert.equal(receipt.pass, true);

const current = phaseFromColor({ t: 3, L: 0.58, C: 0.42, H: 73 });
const corrected = phaseFromColor({ t: 3, L: 0.58, C: 0.42, H: 73 });
const mirror = phaseReverse(current);
const read = phaseRecord(current, corrected);

assert.equal(lorentzianRead(current, corrected).residual, 0);
assert.equal(lorentzianRead(current, corrected).interval, 0);
assert.ok(Math.abs(heavy_horizon(current) + heavy_horizon(mirror)) < 1e-12);
assert.match(read.ascii, /C current  M R7 phase read  T corrected target/);

const correctedLift = liftAwareRead({ n: 14, s: 54, k: 0 }, 1972 / 7);
assert.equal(correctedLift.X, 1972n);
assert.equal(correctedLift.u, 328);
assert.equal(correctedLift.m2, 1972);
assert.equal(correctedLift.J, 1972);
assert.equal(correctedLift.m_H, 1972);
assert.equal(correctedLift.epsilon_band, 0);
assert.equal(correctedLift.joined, true);

const negativeLift = liftAwareRead({ n: -5, s: 136, k: -2 }, 0.1);
assert.equal(negativeLift.X, -549n);
assert.equal(negativeLift.c, -2n);
assert.equal(negativeLift.q, 3);
assert.equal(negativeLift.u, 547);
assert.equal(negativeLift.m2, 1971);
assert.equal(negativeLift.r4, 3);
assert.ok(Math.abs(negativeLift.epsilon_band + 0.3) < 1e-12);
assert.equal(negativeLift.joined, false);
assert.equal(negativeLift.reconstruct_X, negativeLift.X);

const subBandPacket = liftAwareRead({ n: 0, s: 0, k: 0 }, 359.99999999996);
assert.equal(subBandPacket.packet_lattice_exact, false);
assert.ok(subBandPacket.epsilon_band < 0);
assert.throws(
  () => liftAwareRead({ n: Number.MAX_SAFE_INTEGER + 2, s: 0, k: 0 }, 0),
  /safe integer Number/
);

for (let x = 0n; x < 345240n; x += 1n) {
  const state = liftAwareRead({ n: x / 137n, s: Number(x % 137n), k: 0 }, 0);
  assert.equal(state.reconstruct_X, x);
  assert.equal(state.u % 4, state.m2 % 4);
}

console.log("PASS:", receipt.checks, "kernel relations");
console.log("PASS: 345240 lift-aware reconstructions");
console.log(read.ascii);
