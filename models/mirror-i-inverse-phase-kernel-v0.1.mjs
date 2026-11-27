/*
 * Mirror I^-1 / phase-adapter kernel v0.1
 *
 * The carrier is a declared local coordinate record. A host supplies
 * (t, L, C, H), and this module returns the same declared coordinate through
 * phase/color/ASCII readers with retained metrics. A reference-phase reading
 * enters only through its separately declared bridge and receipt.
 */

export const SCHEMA = "mirror-i-inverse-phase-adapter/001";
export const TAU = 2 * Math.PI;
export const CONTACT_MODULUS = 548n;
export const MOONLIGHT_MODULUS = 2520n;
export const JOINT_MODULUS = 345240n;
const BAND_FLOAT_TOLERANCE = 1e-12;

function finite(name, value) {
  const number = Number(value);
  if (!Number.isFinite(number)) throw new TypeError(name + " must be finite");
  return number;
}

function bounded(name, value, low, high) {
  const number = finite(name, value);
  if (number < low || number > high) throw new RangeError(name + " must be in [" + low + ", " + high + "]");
  return number;
}

export function normalizeHue(degrees) {
  const value = finite("H", degrees) % 360;
  return value < 0 ? value + 360 : value;
}

function integer(name, value) {
  if (typeof value === "bigint") return value;
  if (typeof value === "number") {
    if (!Number.isSafeInteger(value)) {
      throw new TypeError(name + " must be a safe integer Number; use a decimal string or BigInt");
    }
    return BigInt(value);
  }
  if (typeof value === "string" && /^[+-]?\d+$/.test(value)) return BigInt(value);
  throw new TypeError(name + " must be an integer");
}

function modulo(value, modulus) {
  const remainder = value % modulus;
  return remainder < 0n ? remainder + modulus : remainder;
}

function floorDivide(value, divisor) {
  const quotient = value / divisor;
  const remainder = value % divisor;
  return remainder < 0n ? quotient - 1n : quotient;
}

function nearestInteger(value) {
  return value >= 0 ? Math.floor(value + 0.5) : -Math.floor(-value + 0.5);
}

/*
 * Lift-aware companion reader.  The state remains the declared integer
 * carrier (n,s,k); this returns its bounded contact/completion readings and
 * the carried super-lift.  Packet Moonlight phase m_H is kept separate from
 * the state reading m2 until their declared residues coincide.
 */
export function liftAwareRead({ n, s, k = 0 }, H) {
  const liftN = integer("n", n);
  const sector = Number(s);
  const turns = integer("k", k);
  if (!Number.isInteger(sector) || sector < 0 || sector >= 137) {
    throw new RangeError("s must be an integer in [0, 136]");
  }
  const hue = normalizeHue(H);
  const X = 137n * liftN + BigInt(sector);
  const rawBand = 7 * hue;
  const nearestBand = nearestInteger(rawBand);
  const rawResidual = rawBand - nearestBand;
  const epsilonBand = Math.abs(rawResidual) < BAND_FLOAT_TOLERANCE ? 0 : rawResidual;
  const packetBand = Number(modulo(BigInt(nearestBand), MOONLIGHT_MODULUS));
  const m2 = Number(modulo(X, MOONLIGHT_MODULUS));
  const joint = Number(modulo(X, JOINT_MODULUS));
  return Object.freeze({
    n: liftN,
    s: sector,
    k: turns,
    X,
    I0: X - 137n * turns,
    c: floorDivide(liftN, 4n),
    q: Number(modulo(liftN, 4n)),
    u: Number(modulo(X, CONTACT_MODULUS)),
    m2,
    J: joint,
    super_lift: floorDivide(X, JOINT_MODULUS),
    r4: Number(modulo(X, 4n)),
    m_H_raw: rawBand,
    m_H: packetBand,
    epsilon_band: epsilonBand,
    packet_lattice_exact: epsilonBand === 0,
    joined: epsilonBand === 0 && packetBand === m2,
    reconstruct_X: floorDivide(X, JOINT_MODULUS) * JOINT_MODULUS + BigInt(joint)
  });
}

/*
 * Declared color-coordinate bridge:
 *   theta = tau H / 360,
 *   (x,y) = C (cos theta, sin theta),
 *   z = 2L - 1.
 *
 * L/C/H are normalized adapter coordinates, not a claim about perceptual
 * colorimetry or a measurement of a hidden system state.
 */
export function phaseFromColor({ t = 0, L, C, H }) {
  const time = finite("t", t);
  const lightness = bounded("L", L, 0, 1);
  const chroma = bounded("C", C, 0, 1);
  const hue = normalizeHue(H);
  const theta = TAU * hue / 360;
  return Object.freeze({
    t: time,
    x: chroma * Math.cos(theta),
    y: chroma * Math.sin(theta),
    z: 2 * lightness - 1,
    theta
  });
}

export function colorFromPhase(phase) {
  const x = finite("x", phase.x);
  const y = finite("y", phase.y);
  const z = finite("z", phase.z);
  const theta = finite("theta", phase.theta);
  return Object.freeze({
    L: Math.max(0, Math.min(1, (z + 1) / 2)),
    C: Math.max(0, Math.min(1, Math.hypot(x, y))),
    H: normalizeHue(360 * theta / TAU)
  });
}

export function copyPhase(phase) {
  return Object.freeze({
    t: finite("t", phase.t),
    x: finite("x", phase.x),
    y: finite("y", phase.y),
    z: finite("z", phase.z),
    theta: finite("theta", phase.theta)
  });
}

/*
 * Source-adapted Heavy Horizon scalar:
 *   zeta_H = y exp(-3r/2) sin(2 theta) / (4 pi),
 *   r = sqrt(x^2+y^2+z^2).
 *
 * It is a declared scalar reader in this adapter.  The module makes no
 * atomic, astrophysical, or global-model identification from it.
 */
export function heavy_horizon(phase) {
  const { x, y, z, theta } = copyPhase(phase);
  const radius = Math.hypot(x, y, z);
  return y * Math.exp(-1.5 * radius) * Math.sin(2 * theta) / (4 * Math.PI);
}

/*
 * R7 acts on the declared phase frame only.  It reverses theta while holding
 * the stored local coordinate fixed:
 *   R7^2 = I, R7 J7 R7 = -J7.
 */
export function phaseReverse(phase) {
  const read = copyPhase(phase);
  return Object.freeze({ ...read, theta: -read.theta });
}

export function lorentzianRead(current, target) {
  const a = copyPhase(current);
  const b = copyPhase(target);
  const delta = Object.freeze({
    t: a.t - b.t,
    x: a.x - b.x,
    y: a.y - b.y,
    z: a.z - b.z
  });
  const interval = -(delta.t ** 2) + delta.x ** 2 + delta.y ** 2 + delta.z ** 2;
  const residual = Math.hypot(delta.t, delta.x, delta.y, delta.z);
  return Object.freeze({ delta, interval, residual });
}

function clampInteger(value, low, high) {
  return Math.max(low, Math.min(high, Math.round(value)));
}

function projectedPoint(phase, width, height) {
  const p = copyPhase(phase);
  const scale = Math.max(4, Math.floor(Math.min(width, height) * 0.28));
  return {
    col: clampInteger((width - 1) / 2 + (p.x + 0.46 * p.z) * scale, 1, width - 2),
    row: clampInteger((height - 1) / 2 - (p.y - 0.22 * p.z) * scale, 1, height - 2)
  };
}

/*
 * Printable only: C = current local coordinate, M = R7 phase-frame read,
 * T = corrected target.  M shares spatial coordinates with C by definition;
 * it is offset one column so both labels remain legible.
 */
export function asciiField({ current, target, width = 61, height = 21 }) {
  const columns = Math.max(25, Math.floor(finite("width", width)));
  const rows = Math.max(9, Math.floor(finite("height", height)));
  const grid = Array.from({ length: rows }, () => Array.from({ length: columns }, () => "."));
  const midRow = Math.floor((rows - 1) / 2);
  const midCol = Math.floor((columns - 1) / 2);
  for (let row = 0; row < rows; row += 1) grid[row][midCol] = "|";
  for (let col = 0; col < columns; col += 1) grid[midRow][col] = "-";
  grid[midRow][midCol] = "+";
  const c = projectedPoint(current, columns, rows);
  const t = projectedPoint(target, columns, rows);
  if (c.col === t.col && c.row === t.row) {
    grid[c.row][c.col] = "*";
  } else {
    grid[t.row][t.col] = "T";
    grid[c.row][c.col] = "C";
  }
  const mirrorColumns = [
    Math.min(columns - 2, c.col + 1),
    Math.max(1, c.col - 1)
  ];
  for (const mirrorCol of mirrorColumns) {
    if (grid[c.row][mirrorCol] === ".") {
      grid[c.row][mirrorCol] = "M";
      break;
    }
  }
  const top = "+" + "-".repeat(columns) + "+";
  const body = grid.map(row => "|" + row.join("") + "|");
  return [top, ...body, top, "C current  M R7 phase read  T corrected target  * aligned"].join("\n");
}

export function phaseRecord(current, target) {
  const now = copyPhase(current);
  const corrected = copyPhase(target);
  const mirror = phaseReverse(now);
  return Object.freeze({
    schema: SCHEMA,
    current: now,
    target: corrected,
    mirror,
    current_color: colorFromPhase(now),
    target_color: colorFromPhase(corrected),
    heavy_horizon: heavy_horizon(now),
    mirror_heavy_horizon: heavy_horizon(mirror),
    lorentzian: lorentzianRead(now, corrected),
    ascii: asciiField({ current: now, target: corrected })
  });
}

export function verifyKernel() {
  let checks = 0;
  const tolerance = 1e-12;
  for (const L of [0, 0.25, 0.5, 0.75, 1]) {
    for (const C of [0, 0.25, 0.5, 1]) {
      for (const H of [0, 45, 90, 135, 180, 225, 270, 315]) {
        const p = phaseFromColor({ t: 3, L, C, H });
        const color = colorFromPhase(p);
        if (Math.abs(color.L - L) > tolerance || Math.abs(color.C - C) > tolerance || Math.abs(color.H - H) > tolerance) {
          throw new Error("color bridge round trip failed");
        }
        checks += 3;
        const twice = phaseReverse(phaseReverse(p));
        if (Math.abs(twice.theta - p.theta) > tolerance) throw new Error("R7 squared failed");
        checks++;
        const hz = heavy_horizon(p);
        const reflected = heavy_horizon(phaseReverse(p));
        if (Math.abs(hz + reflected) > tolerance) throw new Error("Heavy Horizon R7 sign relation failed");
        checks++;
        const local = lorentzianRead(p, p);
        if (local.residual !== 0 || local.interval !== 0) throw new Error("zero local residual failed");
        checks += 2;
      }
    }
  }
  return Object.freeze({ pass: true, checks });
}
