import {
  phaseFromColor,
  phaseRecord,
  colorFromPhase
} from "../models/mirror-i-inverse-phase-kernel-v0.1.mjs";

const demo = {
  node: "declared-demo-node",
  meaning: "unassigned",
  current: { t: 0, L: 0.5, C: 0.5, H: 220 },
  target: { t: 0, L: 0.5, C: 0.5, H: 220 }
};

const raw = process.argv[2];
const packet = raw ? JSON.parse(raw) : demo;
const current = phaseFromColor(packet.current);
const target = phaseFromColor(packet.target);
const read = phaseRecord(current, target);

function fixed(value) {
  return Number(value).toFixed(9).replace(/\.?0+$/, "");
}

function color(label, value) {
  return label + "  L=" + fixed(value.L) + "  C=" + fixed(value.C) + "  H=" + fixed(value.H) + "deg";
}

console.log("MIRROR I^-1 / HEAVY_HORIZON / ASCII PHASE ADAPTER");
console.log("node: " + (packet.node || "unnamed-local-node") + "  meaning: " + (packet.meaning || "unassigned"));
console.log(color("CURRENT", colorFromPhase(current)));
console.log(color("TARGET ", colorFromPhase(target)));
console.log("heavy_horizon = " + fixed(read.heavy_horizon));
console.log("eta(delta,delta) = " + fixed(read.lorentzian.interval));
console.log("adapter_residual = " + fixed(read.lorentzian.residual));
console.log("");
console.log(read.ascii);
