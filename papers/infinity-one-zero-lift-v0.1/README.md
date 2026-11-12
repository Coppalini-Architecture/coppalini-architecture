# Infinity One Zero Lift
## The Normal Form of Projective Memory

Anthony Vito Coppa · Coppalini Architecture  
Composed working edition 0.1 · 11 November 2026

## Read

`Infinity_One_Zero_Lift.pdf` is the complete 15-page typeset paper, including its source-constrained cover, numbered proofs, computed incidence figure, source-traversal appendix, verification ledger, and references.

`Infinity_One_Zero_Lift.tex` is the authoritative editable manuscript. `Infinity_One_Zero_Lift.md` is a reading/editing export; LaTeX retains theorem formatting, cross-references, and precise layout.

## Result

The paper connects the projective mirror `M=[[1,0],[1,-1]]` to the published root by an explicit real coordinate adapter; its complex central lift is related to the four-phase quarter-turn by a separate complex adapter. The existing axial escapement advances the cycle count. Two cycles supply eight distinct occurrence addresses and the complete `K8` comparison space: `28=6+16+6=7*4`.

For fixed unit reference `m`, the state-and-occurrence normal form is `(p,c,a,D)`, with `n=4c+p`, `a=mᵀr`, and `D=mrᵀ-rmᵀ`. Its inverse, on its image, is `(4c+p, am+Dᵀm)`. General edge coordinates, scalar-potential reads, and decomposable reconstruction records are distinguished in the text.

## Checked in this composition

- The existing 73-check exact geometry audit was rerun.
- 31 supplementary manuscript checks passed, with symbolic identities, exhaustive finite calculations, and illustrative examples labeled separately.
- The original finite Lean file was recovered unchanged; its SHA-256 matches the previously successful source. Its external GitHub execution was rechecked. That existing certificate does not cover the newly composed analytic and `K8` portions of the manuscript.
- The PDF was compiled twice, rendered, and inspected. The final build has no unresolved references or overfull-box warnings.
- The cover uses the measured 800 × 1050 frame, exact rational drawing projection, eight separate vertices, and the complete source-colored set of 28 edges.

## Reproduce

Python 3.10 or later and a TeX distribution with `pdflatex`, `newtx`, `amsmath`, and the listed packages are required.

```sh
python -m pip install -r requirements.txt
python verification/geometry_audit/verify_graph.py
python verification/verify_manuscript.py
python build_cover.py
pdflatex -halt-on-error Infinity_One_Zero_Lift.tex
pdflatex -halt-on-error Infinity_One_Zero_Lift.tex
```

To rerun the finite Lean subcertificate with an existing Elan installation:

```sh
elan toolchain install leanprover/lean4:v4.33.0
lean +leanprover/lean4:v4.33.0 verification/ProjectiveReturn.lean
```

The Lean command above is a reproduction instruction; Lean was not installed or rerun in the composition container. The independently executed source-commit receipt is in `provenance/lean_execution_receipt.json`.

## Source custody and scope

`provenance/geometry_audit_original.zip` is the unchanged supplied geometry-audit archive. `verification/geometry_audit/` is the unpacked working copy, with fresh outputs. Original style-source files are preserved there under `references/`. The top-level `SHA256SUMS` fixes this delivery.

The source conversation record ends at the first R² marker. The subsequent private recognition codex and personal history are excluded. Physical/perceptual references retain their model and evidence conditions; the paper does not assert empirical closure of all physics or biology.

No external repository, website, archive, or email was modified by this composition. No new DOI or publication status is claimed.
