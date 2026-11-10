# Physical Reality Inside Constraint — v0.3

## Contents

- `pdf/01_gravity_light.pdf`
- `pdf/02_memory_motion.pdf`
- `pdf/03_time_scope.pdf`
- `pdf/04_horizon_silence.pdf`
- `source/` — LaTeX source and executable receipts
- `CLOSURE_REPAIR_RECEIPT_v0_3.md` — exact closure and boundary ledger

## Verification

Run from `source/`:

```bash
python3 verify_z7_lorentz_extension_v0_2.py
python3 verify_four_papers_v0_3.py
```

The expected receipts are:

```text
PASS: Z7 Lorentz extension v0.2
K8=28 edges; tau^7=I; zeta_7^7=1; orthogonal_block=exact; metric_phase_mirror=exact
PASS: physical-field source v0.3
root=exact; K8_edges=28; M0=four_cards; tau^7=I; triangle_rank=21; potential_reconstruction=exact; source_guards=pass
```

## Build

Run from `source/`:

```bash
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=../pdf 01_gravity_light.tex
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=../pdf 02_memory_motion.tex
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=../pdf 03_time_scope.tex
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=../pdf 04_horizon_silence.tex
```

The common root, occurrence type, K8 ledger, potential reconstruction theorem,
and sevenfold Lorentzian carrier are defined directly in the source.
