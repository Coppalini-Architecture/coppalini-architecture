/* Clear Onyx Gauge Laboratory v0.5.5 — canvas reader and declared controls. */
(() => {
  'use strict';
  if (typeof location !== 'undefined' && new URLSearchParams(location.search).has('embed')) {
    document.body.classList.add('lab-embed');
  }
  const Core = ParticleAtlasCore;
  const STUDY_REGISTRY = Object.freeze(globalThis.ClearOnyxStudyRegistry || {});
  const requestedStudy = () => typeof location === 'undefined' ? null : new URLSearchParams(location.search).get('study');
  const { SPECIES, makeEngine, hslToRgb, clamp, mod, relative, signed, TAU } = Core;
  const $ = (selector) => document.querySelector(selector);
  const canvas = $('#scope');
  const ctx = canvas.getContext('2d', { alpha: false });
  const fieldCanvas = document.createElement('canvas');
  const fieldCtx = fieldCanvas.getContext('2d', { alpha: false });
  const spinCanvas = $('#spin-read');
  const spinCtx = spinCanvas.getContext('2d');
  const state = {
    type: 'electron', engine: null, running: true, rate: 2, lastTime: performance.now(),
    frame: 0, phaseInput: 0, maxDensity: 0, history: [], pulseCount: 0, study: null
  };
  const elements = {
    selector: $('#carrier'), pause: $('#pause'), reset: $('#reset'), rate: $('#rate'), phase: $('#phase'), phaseValue: $('#phase-value'),
    pulse: $('#pulse'), status: $('#status'), title: $('#carrier-title'), family: $('#family'), charge: $('#charge'), spin: $('#spin'),
    equation: $('#equation'), boundary: $('#boundary'), caption: $('#caption'), norm: $('#norm'), energy: $('#energy'),
    current: $('#current'), audit: $('#audit'), history: $('#history'), particle: $('#particle-label'), scope: canvas,
    metricLabel: $('#metric-label'), energyLabel: $('#energy-label'), currentLabel: $('#current-label'), readHeading: $('#read-heading'),
    phaseLabel: $('#phase-label'), scopeType: $('#scope-type'), studyReader: $('#study-reader'), studyFrame: $('#study-frame'),
    studyName: $('#study-name'), studyScope: $('#study-scope'), returnCarrier: $('#return-to-carrier'), skip: $('.skip')
  };

  function setStatus(text) { elements.status.textContent = text; }

  function resize() {
    const rect = canvas.getBoundingClientRect();
    const ratio = Math.min(window.devicePixelRatio || 1, 2);
    const width = Math.max(1, Math.round(rect.width * ratio));
    const height = Math.max(1, Math.round(rect.height * ratio));
    if (canvas.width !== width || canvas.height !== height) { canvas.width = width; canvas.height = height; }
  }

  function setStudyMode(active) {
    if (document.body && document.body.classList) document.body.classList.toggle('study-mode', active);
  }

  function switchStudy(studyId) {
    const study = STUDY_REGISTRY[studyId];
    if (!study) throw new Error(`Unknown study reader: ${studyId}`);
    state.study = studyId;
    setStudyMode(true);
    elements.selector.value = `study:${studyId}`;
    elements.studyReader.hidden = false;
    elements.studyFrame.srcdoc = study.srcdoc;
    elements.studyFrame.title = study.title;
    elements.studyName.textContent = study.title;
    elements.studyScope.textContent = 'OPEN visual study · declared finite reader · no admitted main-carrier PASS';
    const liveLabel = SPECIES[state.type]?.label || 'live carrier';
    elements.returnCarrier.textContent = `Return to ${liveLabel}`;
    elements.skip.setAttribute('href', '#study-reader');
    setStatus(`${study.title} opened as its own declared study reader. Its controls and receipts remain inside that study.`);
  }

  function switchCarrier(type) {
    if (type.startsWith('study:')) return switchStudy(type.slice('study:'.length));
    state.study = null;
    setStudyMode(false);
    elements.studyReader.hidden = true;
    elements.studyFrame.srcdoc = '';
    elements.skip.setAttribute('href', '#field');
    state.type = type;
    state.engine = makeEngine(type);
    elements.selector.value = type;
    state.phaseInput = 0;
    state.pulseCount = 0;
    state.history = [];
    state.maxDensity = 0;
    elements.phase.value = '0'; elements.phaseValue.value = '0°';
    const meta = SPECIES[type];
    elements.title.textContent = meta.label;
    elements.particle.textContent = meta.label.toUpperCase();
    elements.family.textContent = meta.family;
    elements.charge.textContent = `charge ${meta.charge}`;
    elements.spin.textContent = `spin ${meta.spin}`;
    elements.equation.textContent = meta.equation;
    elements.boundary.textContent = meta.detail;
    elements.caption.textContent = meta.read;
    elements.readHeading.textContent = meta.readoutLabel || 'SPIN / POLARIZATION READ';
    elements.metricLabel.textContent = meta.metricLabel || 'NORM';
    elements.energyLabel.textContent = meta.energyLabel || 'ENERGY PROXY';
    elements.currentLabel.textContent = meta.currentLabel || 'NET CURRENT';
    elements.phaseLabel.textContent = meta.hasGlobalPhase ? 'Global U(1) phase' : 'Phase control';
    elements.phase.disabled = !meta.hasGlobalPhase;
    elements.phaseValue.value = meta.hasGlobalPhase ? '0°' : 'N/A';
    elements.pulse.textContent = meta.pulseLabel || 'Pulse aperture';
    elements.scopeType.textContent = meta.scopeLabel || (meta.family.includes('FIELD') || meta.family.includes('SCALAR') ? 'FINITE FIELD · CLICK TO PULSE' : 'DECLARED MODEL · CLICK TO PULSE');
    setStatus(`${meta.label} carrier prepared from its declared initial condition.`);
  }

  function record() {
    if (state.study) return;
    const m = state.engine.read();
    state.history.push({ frame: state.engine.frame, norm: m.norm, energy: m.energyProxy, spin: m.spin });
    const limit = SPECIES[state.type].historyLimit || 72;
    if (state.history.length > limit) state.history.shift();
  }

  function drawField() {
    const engine = state.engine;
    if (engine.dimension === 1) {
      drawOneDimensionalField();
      return;
    }
    const { width, height, size } = engine;
    if (fieldCanvas.width !== width || fieldCanvas.height !== height) { fieldCanvas.width = width; fieldCanvas.height = height; }
    const image = fieldCtx.createImageData(width, height);
    let peak = 0;
    for (let i = 0; i < size; i += 1) peak = Math.max(peak, engine.visualAt(i).density);
    state.maxDensity = state.maxDensity ? state.maxDensity * .94 + Math.max(peak, 1e-8) * .06 : Math.max(peak, 1e-8);
    for (let i = 0; i < size; i += 1) {
      const value = engine.visualAt(i);
      const normalized = Math.tanh(Math.sqrt(value.density / Math.max(state.maxDensity, 1e-9)) * 1.36);
      const visible = clamp((normalized - .042) / .958, 0, 1);
      const hue = 198 + value.phase / TAU * 360;
      const spinTint = state.type === 'electron' || state.type === 'neutrino' ? value.spin.z * 14 : 0;
      let r, g, b;
      if (value.rgb) {
        const sum = value.rgb[0] + value.rgb[1] + value.rgb[2] || 1;
        const scale = .04 + visible * .96;
        r = Math.round(255 * scale * Math.sqrt(value.rgb[0] / sum));
        g = Math.round(255 * scale * Math.sqrt(value.rgb[1] / sum));
        b = Math.round(255 * scale * Math.sqrt(value.rgb[2] / sum));
      } else [r, g, b] = hslToRgb(hue + spinTint, .28 + visible * .52, (.006 + visible * .61));
      const offset = i * 4;
      image.data[offset] = r; image.data[offset + 1] = g; image.data[offset + 2] = b; image.data[offset + 3] = 255;
    }
    fieldCtx.putImageData(image, 0, 0);
    resize();
    const widthPx = canvas.width;
    const heightPx = canvas.height;
    const gradient = ctx.createRadialGradient(widthPx * .5, heightPx * .5, 0, widthPx * .5, heightPx * .5, Math.max(widthPx, heightPx) * .75);
    gradient.addColorStop(0, '#122731'); gradient.addColorStop(.55, '#071219'); gradient.addColorStop(1, '#030609');
    ctx.fillStyle = gradient; ctx.fillRect(0, 0, widthPx, heightPx);
    ctx.imageSmoothingEnabled = true;
    ctx.drawImage(fieldCanvas, 0, 0, widthPx, heightPx);
    drawSceneGeometry(widthPx, heightPx);
    if (SPECIES[state.type].filaments !== false) drawCurrentFilaments(widthPx, heightPx);
    drawHistoryWeave(widthPx, heightPx);
    if (state.type !== 'flux' && state.type !== 'su3') drawAperture(widthPx, heightPx);
  }

  function drawSceneGeometry(widthPx, heightPx) {
    if (state.type === 'flux') { drawFluxGeometry(widthPx, heightPx); return; }
    if (state.type === 'su3') { drawSU3Geometry(widthPx, heightPx); return; }
    if (state.type === 'electron') { drawElectronAperture(widthPx, heightPx); return; }
    if (state.type === 'hydrogen' || state.type === 'lithium') { drawAtomicReference(widthPx, heightPx); return; }
    if (state.type === 'helium') { drawHeliumConfiguration(widthPx, heightPx); return; }
    if (state.type === 'water') { drawWaterGeometry(widthPx, heightPx); }
  }

  function drawFluxGeometry(widthPx, heightPx) {
    const min = Math.min(widthPx, heightPx), cx = widthPx * .5, cy = heightPx * .5, radius = min * .30;
    ctx.save();
    ctx.strokeStyle = 'rgba(152,220,231,.38)'; ctx.lineWidth = Math.max(1, min * .0017); ctx.setLineDash([min * .012, min * .012]);
    ctx.beginPath(); ctx.arc(cx, cy, radius, 0, TAU); ctx.stroke(); ctx.setLineDash([]);
    const glow = ctx.createRadialGradient(cx, cy, 0, cx, cy, radius * .72); glow.addColorStop(0, 'rgba(216,190,100,.34)'); glow.addColorStop(1, 'rgba(216,190,100,0)'); ctx.fillStyle = glow; ctx.beginPath(); ctx.arc(cx, cy, radius * .72, 0, TAU); ctx.fill();
    ctx.restore();
  }

  function drawSU3Geometry(widthPx, heightPx) {
    const min = Math.min(widthPx, heightPx), cx = widthPx * .86, cy = heightPx * .14, radius = min * .042;
    ctx.save();
    const points = [[cx, cy - radius], [cx - radius * .87, cy + radius * .5], [cx + radius * .87, cy + radius * .5]];
    ctx.strokeStyle = 'rgba(224,235,232,.33)'; ctx.lineWidth = Math.max(1, min * .0012); ctx.beginPath(); ctx.moveTo(points[0][0], points[0][1]); ctx.lineTo(points[1][0], points[1][1]); ctx.lineTo(points[2][0], points[2][1]); ctx.closePath(); ctx.stroke();
    for (const [[x, y], color] of [[points[0], '#ff6b72'], [points[1], '#7ee4a0'], [points[2], '#7cb5ff']]) { ctx.fillStyle = color; ctx.beginPath(); ctx.arc(x, y, Math.max(3, min * .007), 0, TAU); ctx.fill(); }
    ctx.restore();
  }

  function drawElectronAperture(widthPx, heightPx) {
    const x = widthPx * .565;
    const upperA = heightPx * .305, upperB = heightPx * .415;
    const lowerA = heightPx * .585, lowerB = heightPx * .695;
    ctx.save();
    ctx.strokeStyle = 'rgba(169,214,218,.36)';
    ctx.lineWidth = Math.max(1, Math.min(widthPx, heightPx) * .002);
    for (const [from, to] of [[0, upperA], [upperB, lowerA], [lowerB, heightPx]]) {
      ctx.beginPath(); ctx.moveTo(x, from); ctx.lineTo(x, to); ctx.stroke();
    }
    ctx.restore();
  }

  function drawAtomicReference(widthPx, heightPx) {
    const min = Math.min(widthPx, heightPx);
    const cx = widthPx * .5, cy = heightPx * .5;
    const lithium = state.type === 'lithium';
    ctx.save();
    ctx.strokeStyle = lithium ? 'rgba(174,224,159,.28)' : 'rgba(165,218,239,.28)';
    ctx.lineWidth = Math.max(1, min * .0012);
    for (const q of lithium ? [.12, .24, .39] : [.16, .31, .46]) {
      ctx.beginPath(); ctx.ellipse(cx, cy, min * q, min * q, 0, 0, TAU); ctx.stroke();
    }
    ctx.fillStyle = lithium ? 'rgba(196,236,165,.75)' : 'rgba(184,228,245,.75)';
    ctx.beginPath(); ctx.arc(cx, cy, Math.max(4, min * .024), 0, TAU); ctx.fill();
    ctx.restore();
  }

  function drawHeliumConfiguration(widthPx, heightPx) {
    const min = Math.min(widthPx, heightPx);
    ctx.save();
    ctx.strokeStyle = 'rgba(213,178,242,.47)';
    ctx.lineWidth = Math.max(1, min * .002);
    ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(widthPx, heightPx); ctx.stroke();
    ctx.strokeStyle = 'rgba(156,206,216,.22)';
    ctx.beginPath(); ctx.moveTo(0, heightPx); ctx.lineTo(widthPx, heightPx); ctx.lineTo(widthPx, 0); ctx.stroke();
    ctx.restore();
  }

  function drawWaterGeometry(widthPx, heightPx) {
    const g = state.engine.geometry;
    if (!g) return;
    const min = Math.min(widthPx, heightPx);
    const point = (p) => ({ x: p.x * widthPx, y: p.y * heightPx });
    const o = point(g.oxygen), h1 = point(g.h1), h2 = point(g.h2);
    ctx.save();
    ctx.lineCap = 'round';
    ctx.lineWidth = Math.max(2, min * .009);
    ctx.strokeStyle = 'rgba(176,229,233,.48)';
    ctx.beginPath(); ctx.moveTo(o.x, o.y); ctx.lineTo(h1.x, h1.y); ctx.moveTo(o.x, o.y); ctx.lineTo(h2.x, h2.y); ctx.stroke();
    const atom = (p, r, fill) => {
      const glow = ctx.createRadialGradient(p.x, p.y, r * .1, p.x, p.y, r * 1.8);
      glow.addColorStop(0, fill); glow.addColorStop(.42, fill.replace('1)', '.70)')); glow.addColorStop(1, 'rgba(0,0,0,0)');
      ctx.fillStyle = glow; ctx.beginPath(); ctx.arc(p.x, p.y, r * 1.8, 0, TAU); ctx.fill();
      ctx.fillStyle = fill; ctx.beginPath(); ctx.arc(p.x, p.y, r, 0, TAU); ctx.fill();
    };
    atom(o, Math.max(7, min * .042), 'rgba(231,191,111,1)');
    atom(h1, Math.max(5, min * .027), 'rgba(162,226,232,1)');
    atom(h2, Math.max(5, min * .027), 'rgba(162,226,232,1)');
    ctx.restore();
  }

  function drawOneDimensionalField() {
    const engine = state.engine;
    resize();
    const widthPx = canvas.width, heightPx = canvas.height;
    const min = Math.min(widthPx, heightPx);
    const centerY = heightPx * .5;
    const scale = heightPx * .27 / Math.max(engine.v, 1e-9);
    const gradient = ctx.createRadialGradient(widthPx * .5, centerY, 0, widthPx * .5, centerY, Math.max(widthPx, heightPx) * .72);
    gradient.addColorStop(0, '#1b2c31'); gradient.addColorStop(.54, '#08161b'); gradient.addColorStop(1, '#030609');
    ctx.fillStyle = gradient; ctx.fillRect(0, 0, widthPx, heightPx);
    ctx.save();
    ctx.setLineDash([min * .010, min * .014]);
    for (const sign of [-1, 1]) {
      ctx.beginPath(); ctx.moveTo(0, centerY - sign * engine.v * scale); ctx.lineTo(widthPx, centerY - sign * engine.v * scale);
      ctx.strokeStyle = sign > 0 ? 'rgba(226,196,107,.30)' : 'rgba(151,222,229,.27)';
      ctx.lineWidth = Math.max(1, min * .0012); ctx.stroke();
    }
    ctx.setLineDash([]);
    ctx.beginPath();
    for (let x = 0; x < engine.width; x += 1) {
      const sample = engine.profileAt(x);
      const px = x / Math.max(1, engine.width - 1) * widthPx;
      const py = centerY - sample.value * scale;
      if (x === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py);
    }
    ctx.lineTo(widthPx, centerY); ctx.lineTo(0, centerY); ctx.closePath();
    const fill = ctx.createLinearGradient(0, 0, widthPx, heightPx);
    fill.addColorStop(0, 'rgba(224,194,99,.36)'); fill.addColorStop(.48, 'rgba(171,223,225,.12)'); fill.addColorStop(1, 'rgba(162,219,181,.30)');
    ctx.fillStyle = fill; ctx.fill();
    ctx.beginPath();
    for (let x = 0; x < engine.width; x += 1) {
      const sample = engine.profileAt(x);
      const px = x / Math.max(1, engine.width - 1) * widthPx;
      const py = centerY - sample.value * scale;
      if (x === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py);
    }
    ctx.strokeStyle = 'rgba(232,240,224,.89)'; ctx.lineWidth = Math.max(2, min * .004); ctx.stroke();
    ctx.restore();
    drawHistoryWeave(widthPx, heightPx);
    drawAperture(widthPx, heightPx);
  }

  function localCurrent(x, y) {
    const e = state.engine;
    if (typeof e.currentAt === 'function') return e.currentAt(x, y);
    const sample = (sx, sy) => e.visualAt(((sy + e.height) % e.height) * e.width + ((sx + e.width) % e.width));
    const left = sample(x - 1, y), right = sample(x + 1, y), up = sample(x, y - 1), down = sample(x, y + 1);
    const center = sample(x, y);
    if (center.density < state.maxDensity * .0018) return { x: 0, y: 0, magnitude: 0 };
    const dx = Math.sin(right.phase - left.phase) * Math.sqrt(center.density);
    const dy = Math.sin(down.phase - up.phase) * Math.sqrt(center.density);
    return { x: dx, y: dy, magnitude: Math.hypot(dx, dy) };
  }

  function drawCurrentFilaments(widthPx, heightPx) {
    const e = state.engine;
    ctx.save(); ctx.lineWidth = Math.max(1, Math.min(widthPx, heightPx) * .00115);
    for (let seed = 0; seed < 36; seed += 1) {
      let x = Math.floor((seed % 9 + .55) / 9 * e.width);
      let y = Math.floor((Math.floor(seed / 9) + .6) / 4 * e.height);
      ctx.beginPath();
      ctx.moveTo(x / (e.width - 1) * widthPx, y / (e.height - 1) * heightPx);
      let drawn = false;
      for (let step = 0; step < 12; step += 1) {
        const current = localCurrent(x, y);
        if (current.magnitude < 1e-5) break;
        x = mod(Math.round(x + current.x / current.magnitude * 2), e.width);
        y = mod(Math.round(y + current.y / current.magnitude * 2), e.height);
        ctx.lineTo(x / (e.width - 1) * widthPx, y / (e.height - 1) * heightPx);
        drawn = true;
      }
      if (drawn) {
        const phase = e.visualAt(y * e.width + x).phase;
        ctx.strokeStyle = `hsla(${mod(198 + phase / TAU * 360, 360)}, 74%, 76%, .18)`;
        ctx.stroke();
      }
    }
    ctx.restore();
  }

  function drawHistoryWeave(widthPx, heightPx) {
    if (state.history.length < 2) return;
    const min = Math.min(widthPx, heightPx);
    const cx = widthPx * .5, cy = heightPx * .5;
    ctx.save();
    for (let i = 0; i < state.history.length - 1; i += 1) {
      const a = state.history[i], b = state.history[i + 1];
      const t = i / Math.max(1, state.history.length - 1);
      const ta = (a.spin.z || 0) * .5 + .5;
      const radius = min * (.12 + .29 * t);
      const nextRadius = min * (.12 + .29 * (i + 1) / Math.max(1, state.history.length - 1));
      const ax = cx + Math.cos(a.frame * .035 + ta * 2.4) * radius;
      const ay = cy + Math.sin(a.frame * .035 + ta * 2.4) * radius * .72;
      const bx = cx + Math.cos(b.frame * .035 + ((b.spin.z || 0) * .5 + .5) * 2.4) * nextRadius;
      const by = cy + Math.sin(b.frame * .035 + ((b.spin.z || 0) * .5 + .5) * 2.4) * nextRadius * .72;
      ctx.beginPath(); ctx.moveTo(ax, ay); ctx.lineTo(bx, by);
      ctx.strokeStyle = `hsla(${205 + 95 * t}, 68%, 68%, ${.025 + .14 * t})`;
      ctx.lineWidth = Math.max(1, min * (.0008 + .0012 * t)); ctx.stroke();
    }
    ctx.restore();
  }

  function drawAperture(widthPx, heightPx) {
    const min = Math.min(widthPx, heightPx);
    const cx = widthPx * .5, cy = heightPx * .5, r = min * .085;
    ctx.save();
    const glow = ctx.createRadialGradient(cx, cy, r * .1, cx, cy, r * 1.5);
    glow.addColorStop(0, 'rgba(1,5,8,.75)'); glow.addColorStop(.72, 'rgba(1,5,8,.30)'); glow.addColorStop(1, 'rgba(1,5,8,0)');
    ctx.fillStyle = glow; ctx.beginPath(); ctx.arc(cx, cy, r * 1.5, 0, TAU); ctx.fill();
    for (let ring = 0; ring < 3; ring += 1) {
      ctx.beginPath(); ctx.ellipse(cx, cy, r * (1 + ring * .25), r * (.72 + ring * .20), state.engine.frame * .0038, 0, TAU);
      ctx.strokeStyle = `hsla(${42 + ring * 68}, 70%, ${67 - ring * 8}%, ${.48 - ring * .10})`;
      ctx.lineWidth = Math.max(1, min * (.0014 - ring * .00022)); ctx.stroke();
    }
    ctx.restore();
  }

  function drawSpin() {
    const rect = spinCanvas.getBoundingClientRect();
    const ratio = Math.min(window.devicePixelRatio || 1, 2);
    const width = Math.max(1, Math.round(rect.width * ratio));
    const height = Math.max(1, Math.round(rect.height * ratio));
    if (spinCanvas.width !== width || spinCanvas.height !== height) { spinCanvas.width = width; spinCanvas.height = height; }
    const m = state.engine.read();
    const s = m.spin;
    spinCtx.clearRect(0, 0, width, height);
    const cx = width * .5, cy = height * .52, radius = Math.min(width, height) * .34;
    spinCtx.strokeStyle = 'rgba(156,205,214,.40)'; spinCtx.lineWidth = Math.max(1, radius * .016);
    spinCtx.beginPath(); spinCtx.ellipse(cx, cy, radius, radius * .45, 0, 0, TAU); spinCtx.stroke();
    spinCtx.beginPath(); spinCtx.moveTo(cx - radius, cy); spinCtx.lineTo(cx + radius, cy); spinCtx.stroke();
    spinCtx.beginPath(); spinCtx.moveTo(cx, cy - radius); spinCtx.lineTo(cx, cy + radius); spinCtx.stroke();
    const x = cx + s.x * radius;
    const y = cy - s.z * radius;
    const tone = SPECIES[state.type].tone || (state.type === 'photon' ? 200 : state.type === 'scalar' ? 284 : 43);
    spinCtx.strokeStyle = `hsl(${tone} 72% 70%)`; spinCtx.lineWidth = Math.max(2, radius * .045);
    spinCtx.beginPath(); spinCtx.moveTo(cx, cy); spinCtx.lineTo(x, y); spinCtx.stroke();
    spinCtx.fillStyle = `hsl(${tone} 76% 72%)`; spinCtx.beginPath(); spinCtx.arc(x, y, Math.max(3, radius * .07), 0, TAU); spinCtx.fill();
    spinCtx.fillStyle = 'rgba(223,235,230,.70)'; spinCtx.font = `${Math.max(10, radius * .15)}px ui-monospace, monospace`;
    const axes = SPECIES[state.type].readAxes || 'x, y, z';
    spinCtx.textAlign = 'center'; spinCtx.fillText(`${axes} = (${signed(s.x, 2)}, ${signed(s.y, 2)}, ${signed(s.z, 2)})`, cx, height * .91);
  }

  function updateReadout() {
    const m = state.engine.read();
    const baseline = state.engine.baseline;
    const drift = baseline ? relative(m.norm, baseline.norm) : 0;
    const energyDrift = baseline ? relative(m.energyProxy, baseline.energyProxy) : 0;
    const meta = SPECIES[state.type];
    const primaryLabel = meta.metricLabel || (state.type === 'scalar' ? 'charge proxy' : state.type === 'photon' ? 'field energy' : 'norm');
    elements.metricLabel.textContent = primaryLabel.toUpperCase();
    elements.energyLabel.textContent = (state.type === 'oscillation' && !m.closedFormApplies ? 'Pβ (MEASURED)' : (meta.energyLabel || 'energy proxy')).toUpperCase();
    elements.currentLabel.textContent = (meta.currentLabel || 'net current').toUpperCase();
    elements.norm.textContent = meta.liveReadouts ? `${m.norm.toFixed(5)} · LIVE` : `${m.norm.toFixed(5)} · Δ ${signed(drift * 100, 2)}%`;
    elements.energy.textContent = meta.liveReadouts ? `${m.energyProxy.toFixed(5)} · LIVE` : `${m.energyProxy.toFixed(5)} · Δ ${signed(energyDrift * 100, 2)}%`;
    elements.current.textContent = Number.isFinite(m.current?.x) && Number.isFinite(m.current?.y) ? `${signed(m.current.x, 3)}, ${signed(m.current.y, 3)}` : 'UNRESOLVED';
    let audit = 'PASS';
    if (meta.certification === 'OPEN') audit = 'OPEN · check not admitted';
    else if (state.engine.pulses.length && typeof state.engine.audit === 'function') audit = `${state.engine.audit(m)} · pulse ${state.engine.pulses.length}`;
    else if (state.engine.pulses.length) audit = `PULSE · ${state.engine.pulses.length} admitted`;
    else if (typeof state.engine.audit === 'function') audit = state.engine.audit(m);
    else if (state.type === 'electron' || state.type === 'neutrino') audit = Math.abs(drift) < 2e-7 ? 'PASS · unitary carrier' : 'WATCH · numerical drift';
    else if (state.type === 'photon') audit = Math.abs(energyDrift) < .14 ? 'PASS · bounded FDTD' : 'WATCH · energy drift';
    else if (state.type === 'scalar') audit = Math.abs(drift) < .08 ? 'PASS · charge proxy' : 'WATCH · proxy drift';
    elements.audit.textContent = audit;
    elements.history.textContent = `${state.history.length} retained / ${meta.historyLimit || 72}`;
  }

  function frame(now) {
    const elapsed = Math.min(.08, Math.max(0, (now - state.lastTime) / 1000));
    state.lastTime = now;
    if (!state.study) {
      if (state.running) {
        const steps = elapsed > .05 ? Math.max(1, Math.round(state.rate * 1.25)) : state.rate;
        for (let i = 0; i < steps; i += 1) state.engine.step();
        if (state.engine.frame % 5 === 0) record();
      }
      drawField(); drawSpin(); updateReadout();
    }
    requestAnimationFrame(frame);
  }

  elements.selector.addEventListener('change', () => switchCarrier(elements.selector.value));
  elements.returnCarrier.addEventListener('click', () => {
    if (!state.study) return;
    const restored = state.type;
    switchCarrier(restored);
    setStatus(`${SPECIES[restored].label} restored as the live carrier.`);
  });
  elements.pause.addEventListener('click', () => {
    if (state.study) { setStatus('Study controls live inside the selected study reader.'); return; }
    state.running = !state.running;
    elements.pause.textContent = state.running ? 'Pause' : 'Resume';
    elements.pause.setAttribute('aria-pressed', String(!state.running));
    setStatus(state.running ? 'Carrier resumed.' : 'Carrier held at its current finite state.');
  });
  elements.reset.addEventListener('click', () => {
    if (state.study) { switchStudy(state.study); setStatus('Selected study returned to its declared initial reader state.'); return; }
    switchCarrier(state.type); setStatus('Returned to the declared seed condition.');
  });
  elements.rate.addEventListener('input', () => { state.rate = Number(elements.rate.value); $('#rate-value').value = `${state.rate} steps/f`; });
  elements.phase.addEventListener('input', () => {
    if (state.study) { setStatus('Study controls live inside the selected study reader.'); return; }
    const next = Number(elements.phase.value);
    let delta = next - state.phaseInput;
    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;
    if (typeof state.engine.rotateGlobal === 'function' && SPECIES[state.type].hasGlobalPhase) {
      state.engine.rotateGlobal(delta);
      setStatus(`Global U(1) phase rotated by ${delta >= 0 ? '+' : ''}${delta}°. The selected carrier remains otherwise unchanged.`);
    } else {
      setStatus('The selected model has no declared global matter-field phase control.');
    }
    state.phaseInput = next; elements.phaseValue.value = `${next}°`;
  });
  elements.pulse.addEventListener('click', () => {
    if (state.study) { setStatus('Study controls live inside the selected study reader.'); return; }
    state.engine.inject(); state.pulseCount += 1; setStatus(`Declared local condition admitted at the aperture. Receipt count: ${state.pulseCount}.`);
  });
  canvas.addEventListener('pointerdown', (event) => {
    if (state.study) return;
    const rect = canvas.getBoundingClientRect();
    const x = clamp((event.clientX - rect.left) / rect.width * state.engine.width, 0, state.engine.width - 1);
    const y = clamp((event.clientY - rect.top) / rect.height * state.engine.height, 0, state.engine.height - 1);
    state.engine.inject(x, y); state.pulseCount += 1;
    setStatus(`Local condition admitted at normalized address (${(x / state.engine.width).toFixed(2)}, ${(y / state.engine.height).toFixed(2)}).`);
  });
  new ResizeObserver(resize).observe(canvas);
  const initialStudy = requestedStudy();
  switchCarrier(initialStudy && STUDY_REGISTRY[initialStudy] ? `study:${initialStudy}` : 'su3');
  if (!state.study) record();
  requestAnimationFrame(frame);
})();
