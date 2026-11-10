# Suture Field Dynamics v0.1

This appendix completes the regular Hamiltonian reduction for the Suture
Field action.

## Files

- `pdf/05a_suture_field_dynamics.pdf` — typeset appendix.
- `source/05a_suture_field_dynamics.tex` — LaTeX source.
- `source/common.tex` — shared typography and root notation.
- `source/verify_suture_field_dynamics_v0_1.py` — exact rational verifier.
- `SUTURE_FIELD_DYNAMICS_RECEIPT_v0_1.md` — result, correction, and boundary.

## Verification

From `source/` run:

```bash
python3 verify_suture_field_dynamics_v0_1.py
```

Expected result:

```text
PASS: Suture Field Dynamics v0.1
regular_rank=16; Lorentz_signature=(3,1); stabilizer_dim=10;
vacuum_Delta_rank=0; auxiliary_reduction=64_SC+16_FC; physical_DoF=4
```

The degree count is conditional on the explicitly stated regular branch
\(\operatorname{rank}D\mathscr S=16\).  It does not assert a new local
\(\mathbb Z_7\) gauge connection or an experimental holonomy without an
additional action term and calibrated readout.
