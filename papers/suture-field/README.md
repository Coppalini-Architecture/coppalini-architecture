# Suture Field v0.1

This directory retains the fifth physical field card from the **Suture Field
v0.1** source package.

| Read copy | Source | Verification |
|---|---|---|
| [PDF](pdf/05_suture_field.pdf) | [LaTeX](source/05_suture_field.tex) | [exact verifier](source/verify_suture_field_v0_1.py) |

The card types a rank-four internal coframe inside the eight-address carrier.
Its exact contractions are `g = Pi* eta-hat` and `F_sol = Pi* C-hat`.  The
unchanged source-package guide and package receipt are retained as
[SOURCE_PACKAGE_README_v0_1.md](SOURCE_PACKAGE_README_v0_1.md) and
[SUTURE_FIELD_RECEIPT_v0_1.md](SUTURE_FIELD_RECEIPT_v0_1.md).  Package
checksums are retained in [SUTURE_FIELD_v0_1.sha256](SUTURE_FIELD_v0_1.sha256).

## Verification

Run from `source/`:

```bash
python3 verify_suture_field_v0_1.py
```

The verifier uses exact cyclotomic arithmetic to check the real Fourier
realization of the Z7 address action and its metric, phase, and mirror
relations.

## Scope

The field equations specify a realization condition.  A material coupling,
calibration value, and measured observable remain part of each individual
realization record.
