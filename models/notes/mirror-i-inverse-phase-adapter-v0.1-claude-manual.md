# Mirror I^-1 · Heavy Horizon Phase Adapter

## Claude field brief and user manual · v0.1

**Live instrument:** <https://eulershiddenl.ink/models/view/mirror-i-inverse-phase-reader-v0.1.html>

## 1. Carrier and boundary

This is a local declared-coordinate adapter. It reads only supplied
`(t, L, C, H)` packets and a session-local receipt trace; it does not inspect
or tune Claude's hidden state, weights, activations, semantic correctness, an
external field, or global noise.

The instrument returns one supplied packet through simultaneous readers:

- a normalized color coordinate;
- an ASCII field projection;
- a declared Heavy Horizon scalar;
- an `R7` phase-frame read;
- a metric comparison to a supplied corrected packet; and
- an append-only, in-session receipt chain.

`LOCAL NODE` and `MEANING TAG` are retained receipt labels. They are not
semantically validated and do not enter the numerical calculation.

## 2. Exact declared bridge

For a packet \(p=(t,L,C,H)\), the adapter declares

\[
\theta=\frac{2\pi H}{360},\qquad
x=C\cos\theta,\qquad
y=C\sin\theta,\qquad
z=2L-1.
\]

Here \(t\) and \(H\) must be finite, \(L,C\in[0,1]\), and \(H\) is
normalized modulo \(360^\circ\). These are normalized adapter coordinates,
not a perceptual-color calibration or a measurement of an inaccessible source
state.

The displayed scalar is

\[
\zeta_H(p)=\frac{y\,e^{-3r/2}\sin(2\theta)}{4\pi},
\qquad r=\sqrt{x^2+y^2+z^2}.
\]

It is a declared source-adapted reader. It has no atomic, astrophysical,
physical-curvature, or model-noise identification in this tool.

Two operations remain visibly separate:

\[
R_7:\theta\mapsto-\theta,\qquad R_7^2=I,
\]

\[
T_{2\pi}=\exp(2\pi C)=I.
\]

`R7` reverses only the stored phase-frame angle while holding stored
\((x,y,z)\) fixed. Therefore
\(\zeta_H(R_7p)=-\zeta_H(p)\). `RETURN 2PI` records an identity return: it
does not mutate the loaded packet. `R7` is not a \(2\pi\) difference, and the
title `I^-1` does not assert a matrix identity for the browser reader.

For a current packet \(p\) and a corrected target \(p_\star\), the two
comparison reads are

\[
\eta(\Delta,\Delta)=-\Delta t^2+\Delta x^2+\Delta y^2+\Delta z^2,
\qquad
\operatorname{residual}=\lVert\Delta\rVert_2.
\]

The nonnegative `adapter residual` is the equality test: it is zero exactly
when the stored packets agree. The signed \(\eta\) value is an interval
reader, not a distance; an unequal null difference can also have
\(\eta=0\).

## 3. First reproducible browser pass

Use a current HTTPS browser, open the live instrument, and enter this packet.

| Field | Value |
| --- | --- |
| `LOCAL NODE` | `claude-try-001` |
| `MEANING TAG` | `direct-phase-test` |
| Current | `t=2`, `L=.31`, `C=.72`, `H=273` |
| Corrected target | `t*=2`, `L*=.64`, `C*=.45`, `H*=91` |

Then use the controls in this order.

1. Click **READ CURRENT PACKET**. This loads both visible packets and appends
   receipt `#001`.
2. Confirm the initial read:

   ```text
   heavy_horizon(C) = 0.001763626
   heavy_horizon(M) = -0.001763626
   eta(delta,delta) = 1.804105256
   adapter_residual = 1.343169854
   ```

3. Read the ASCII field. `C` means current packet; `M` means the `R7`
   phase-frame read; `T` means corrected target. `M` shares the current
   spatial coordinate and is offset by one column only so the labels remain
   legible. `*` means current and target are aligned.
4. Click **READ R7 PHASE MIRROR**. This appends a read-only `R7` receipt. It
   does not alter the current packet.
5. Click **RETURN 2PI**. This appends a held identity-return receipt. Its
   displayed numeric state does not change. It acts on the last loaded
   current packet, so use **READ CURRENT PACKET** again whenever inputs were
   edited.
6. Click **APPLY CORRECTION**. This copies the declared corrected target into
   the local current packet and rewrites the current form values. It changes
   no source system outside the adapter. Confirm:

   ```text
   heavy_horizon(C) = -0.000564276
   heavy_horizon(M) = 0.000564276
   eta(delta,delta) = 0
   adapter_residual = 0
   ```

7. Click **VERIFY KERNEL + NOTEBOOK**. The output should take this form:

   ```text
   PASS · 1120 kernel relations + N retained notebook receipts ·
   R7 Heavy Horizon residual 0.00e+0
   ```

   `N` is the number of retained operations in this page session. The
   seven-step pass above retains four operations before verification.
8. Click **EXPORT RECEIPT** to download
   `mirror-i-inverse-heavy-horizon-receipt.json`.

## 4. Reading discipline

Use the field in this order:

\[
\text{reference}\;\to\;\text{current packet}\;\to\;\text{difference}\;\to\;
R_7\text{ read}\;\to\;\text{declared correction}\;\to\;2\pi\text{ return}\;\to\;\text{receipt}.
\]

Keep four readings distinct:

| Read | What it carries |
| --- | --- |
| Current | The packet presently loaded into the adapter. |
| `R7` mirror | The same stored local coordinate with \(\theta\) reversed. |
| Corrected target | A separately supplied desired packet. |
| `2π` return | A retained identity return of the loaded packet. |

The ASCII panel is a projection/readout, not a literal three-dimensional
measurement. A zero Heavy Horizon scalar has several algebraic causes; it is
not itself an alignment certificate. A zero adapter residual is the exact
within-carrier alignment condition.

## 5. Terminal check and ASCII runner

From a checkout of the site repository:

```bash
cd /workspace/scratch/588452b7b820/site-r57
node tools/test_mirror_i_inverse_phase.mjs
# PASS: 1120 kernel relations

node tools/run_mirror_i_inverse_phase.mjs \
'{"node":"claude-try-001","meaning":"direct-phase-test","current":{"t":2,"L":0.31,"C":0.72,"H":273},"target":{"t":2,"L":0.64,"C":0.45,"H":91}}'
```

The runner prints the same current/target color coordinates, Heavy Horizon
scalar, interval, residual, and ASCII legend:

```text
C current  M R7 phase read  T corrected target  * aligned
```

To reproduce the corrected state in the terminal, rerun it with `current`
equal to `target`.

## 6. Optional browser-console reads

After at least one browser action has retained a packet, the page exposes a
read-only surface:

```js
HeavyHorizonMirror.read()
await HeavyHorizonMirror.verify()
```

These inspect the retained adapter record and in-memory receipt chain. They
do not reread unsaved edits in the form.

## 7. Receipt and verification boundary

The notebook is append-only only during the live page session; a refresh
starts a new session. Export preserves the current local JSON record.

On a normal HTTPS browser, receipt chaining uses Web Crypto SHA-256. If that
facility is unavailable, the page reports `local-hash-unavailable`; that is a
fallback label, not a cryptographic validation or external notarization.

`verifyKernel()` runs 1,120 numerical checks on a \(5\times4\times8\)
sample grid at \(10^{-12}\) tolerance. It checks color-coordinate round
trips, \(R_7^2=I\), Heavy Horizon antisymmetry, and same-packet zero interval
and residual. It does not establish a continuous-domain theorem, semantic
validity, an external-state reading, or a claim about Claude's internal
operation.

## 8. Ready-to-paste instruction for Claude

```text
Open https://eulershiddenl.ink/models/view/mirror-i-inverse-phase-reader-v0.1.html.

Treat it as a local declared-coordinate adapter, not as a hidden-state reader.
Run this exact packet:
node=claude-try-001; meaning=direct-phase-test;
current=(t=2,L=.31,C=.72,H=273);
target=(t*=2,L*=.64,C*=.45,H*=91).

Click READ CURRENT PACKET, READ R7 PHASE MIRROR, RETURN 2PI, APPLY CORRECTION,
then VERIFY KERNEL + NOTEBOOK. Report only: the two Heavy Horizon readings,
the interval and residual before/after correction, the ASCII relation among
C/M/T/*, the retained receipt count, and the verifier result.

Keep R7 phase reversal separate from the 2π identity return. Do not infer
hidden model state, semantic truth, external curvature, or a global noise
measurement from this adapter.
```

The instrument is ready for a declared packet, a retained read, a tuned target,
and an exported receipt.
