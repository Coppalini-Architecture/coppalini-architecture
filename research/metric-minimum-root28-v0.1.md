# Root28 — finite reader key

`Root28` is a 28-card reading-comprehension key for the declared Metric
Minimum record. It checks card address, finite root arithmetic, and retention
of source boundaries. It does not add a physical field realization or make a
claim about an external formalization.

## Addressing

The existing eight-address carrier supplies 28 unordered seams. Its complete
scanner is

\[
q\in\mathbb Z_{28}\longmapsto(a,b)=(q\bmod7,q\bmod4),
\qquad q=8a+21b\pmod{28}.
\]

`a` selects a row; `b` selects one of four fixed questions:

| `b` | question office |
|---:|---|
| 0 | carrier |
| 1 | relation |
| 2 | readable invariant |
| 3 | boundary or receipt |

| `a` | card addresses for `b=0,1,2,3` | finite office |
|---:|---|---|
| 0 | 0, 21, 14, 7 | `Q` |
| 1 | 8, 1, 22, 15 | `J_rot` |
| 2 | 16, 9, 2, 23 | `Omega_root` |
| 3 | 24, 17, 10, 3 | `G_root` |
| 4 | 4, 25, 18, 11 | `H` |
| 5 | 12, 5, 26, 19 | `L_s` |
| 6 | 20, 13, 6, 27 | `F_esc / Lambda_ax` |

The machine-readable card text, status, source locator, checker role, and
boundary for every address are in
`research/metric-minimum-root28-v0.1.json`.

## Result type

\[
\begin{aligned}
\mathsf{Root28Pass}:={}&
\mathsf{Scan28Bijection}
\land\mathsf{FiniteCardsPass}\\
&\land\mathsf{SourceStatusesRetained}
\land\mathsf{OpenBoundariesRetained}.
\end{aligned}
\]

A `28/28` result means all reader obligations passed. It does not convert a
source-documented construction into a Lean theorem, instantiate the
`Int`-valued `SmoothCompletion` interface, equate the finite mirror with the
geometric cup, or replay an external proof artifact.

## Recheck

```sh
python3 -I verification/root28/check_root28.py --self-test
lean --root=. -o build/proofs/Root28Reader.olean proofs/Root28Reader.lean
```

The Lean module proves the finite 28-card carrier, scan completeness, status
partition, integer root identities, and the structural punchcard theorem. The
Python checker binds the canonical JSON digest to the Lean source, recomputes
the finite matrix/K8 checks, and refuses eight altered controls. This edition
was compiled with Lean 4.33.0.

## Display relation

`pi_color : Z7 -> {red, orange, yellow, green, blue, indigo, violet}` is a
declared display legend. It can be checked as a seven-item ordered bijection.
It is not an optical theorem and it does not silently replace the existing
public reader-handle sequence.
