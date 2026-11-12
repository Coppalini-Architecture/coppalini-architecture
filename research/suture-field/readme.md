# Suture Audit v0.3 (Card 5 Suture Field + Card 5a Suture Field Dynamics)

Single source revision; the two cards advance together. v0.3 incorporates the exact regular-isotropy counterexample and completes the auxiliary Dirac-reduction derivation.

- `source/` — `common.tex`, `05_suture_field.tex`, `05a_suture_field_dynamics.tex`, eight active verifiers plus `verify_all.py`. `verify_suture_field_dynamics_v0_1.py` and `_v0_2.py` are retained as lineage/helpers; `_v0_3.py` is the active Dynamics receipt.
- `pdf/` — compiled cards.
- `receipts/` — captured stdout of each active verifier on 12 Nov 2026.
- `RESIDUAL_LEDGER_v0_3.md` — closed, carried and open edges with equation addresses.
- `SHA256SUMS` — hashes of every released file.

Run: `cd source && python3 verify_all.py` (each verifier runs in its own interpreter; exit 0 only if all print PASS).
Build: `pdflatex 05_suture_field.tex` and `pdflatex 05a_suture_field_dynamics.tex` in `source/` (run twice).

v0.3 repair: Π_iso=(o₁,o₂+o₃,o₄,o₅) is regular (`rank D𝒮=16`) but has stabilizer-orbit rank 9 because `X_iso=0₆⊕C` is nonzero and annihilates Π_iso. This resolves whole-branch freeness negatively while preserving the 16-dimensional regular fiber. The Dynamics theorem now writes the inverse second-class kernel and shows explicitly that physical Dirac brackets equal their Poisson brackets; `{𝒞,H_phys}` fixes the auxiliary multiplier `u_q` and does not create a new constraint.

Boundary: the regular-branch condition rank D𝒮_Π = 16 and the image {b < |χ|} qualify every reduction claim. No empirical comparison is asserted; calibration of χ remains open (ledger R-5, R-6).
