# Four Dual Forms

This directory retains the four companion preprints from the **Physical
Reality Field v0.3** source package:

| Card | Read copy | Source |
|---|---|---|
| Gravity Light | [PDF](pdf/01_gravity_light.pdf) | [LaTeX](source/01_gravity_light.tex) |
| Memory Motion | [PDF](pdf/02_memory_motion.pdf) | [LaTeX](source/02_memory_motion.tex) |
| Time Scope | [PDF](pdf/03_time_scope.pdf) | [LaTeX](source/03_time_scope.tex) |
| Horizon Silence | [PDF](pdf/04_horizon_silence.pdf) | [LaTeX](source/04_horizon_silence.tex) |

All four cards share `source/common.tex`.  The exact package receipt is
[CLOSURE_REPAIR_RECEIPT_v0_3.md](CLOSURE_REPAIR_RECEIPT_v0_3.md), and the
unchanged package guide is
[SOURCE_PACKAGE_README_v0_3.md](SOURCE_PACKAGE_README_v0_3.md).

## Verification

Run from `source/`:

```bash
python3 verify_z7_lorentz_extension_v0_2.py
python3 verify_four_papers_v0_3.py
```

The checked finite spine includes the root identities, the 28 edges of
`K8`, the seven matching layers, cyclic transport, the rank-21 triangle
system, and potential reconstruction.  The package-level PDF checksums are
retained in [MANIFEST.sha256](MANIFEST.sha256).

## Scope

The four cards develop the baseline matching
`{Gravity–Light, Memory–Motion, Time–Scope, Horizon–Silence}`.  The
remaining 24 `K8` edges retain exact combinatorial addresses and the common
cyclic carrier; their observable, calibration, residual, and
experiment-specific receipts remain individual interface work.
