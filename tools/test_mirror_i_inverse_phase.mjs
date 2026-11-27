import assert from "node:assert/strict";
import {
  phaseFromColor,
  phaseReverse,
  heavy_horizon,
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

console.log("PASS:", receipt.checks, "kernel relations");
console.log(read.ascii);
