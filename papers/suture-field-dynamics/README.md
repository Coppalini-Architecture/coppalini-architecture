# Suture Field Dynamics v0.1

This directory retains the constrained-dynamics appendix to *Suture Field*.

| Read copy | Source | Verification |
|---|---|---|
| [PDF](pdf/05a_suture_field_dynamics.pdf) | [LaTeX](source/05a_suture_field_dynamics.tex) | [exact verifier](source/verify_suture_field_dynamics_v0_1.py) |

The unchanged source-package guide and result record are retained as
[SOURCE_PACKAGE_README_v0_1.md](SOURCE_PACKAGE_README_v0_1.md) and
[SUTURE_FIELD_DYNAMICS_RECEIPT_v0_1.md](SUTURE_FIELD_DYNAMICS_RECEIPT_v0_1.md).
Package checksums are retained in
[SUTURE_FIELD_DYNAMICS_v0_1.sha256](SUTURE_FIELD_DYNAMICS_v0_1.sha256).

## Verification

Run from `source/`:

```bash
python3 verify_suture_field_dynamics_v0_1.py
```

The exact rational receipt verifies the stated rank-16 regular branch,
Lorentzian signature, stabilizer dimension, multiplier-vacuum cross-bracket
rank, auxiliary reduction, and four physical degrees of freedom.

## Scope

The reduction is conditional on the stated regular branch.  The Z7 carrier is
an algebraic fiber symmetry of the action; a local connection, holonomy
measurement, or experimental prediction requires an added dynamical coupling,
calibration, and observable.
