# Suture audit v0.2 — residual ledger (Card 5 + 05a)

One boundary, one revision. Addresses are equation tags in `source/05_suture_field.tex` (SF.n) and
`source/05a_suture_field_dynamics.tex` (SD.n). Verifier paths are relative to `source/`.
Status: CLOSED (computed or proved in v0.2) · CARRIED (cited/assumed, stated in text) · OPEN.

## A. Results carried in v0.2

| ID | Statement | Address | Verifier assertion | Status |
|---|---|---|---|---|
| C-1 | Regular rank D𝒮 = 16 at Π⋆ and Π_vac; dim 𝔨 = 10 | SD.5–SD.11, SD.14a | `verify_suture_field_dynamics_v0_2.py` `verify_stabilizer_orbit` (exact nullspace 10; orbit rank 10; generators tangent to ker D𝒮); v0_1 rank-16 certificate | CLOSED at the two points |
| C-2 | Cap b ≤ \|χ\| (regular branch b < \|χ\|) | SD.11a–b | `verify_magnetic_cap_v0_1.py` (15 544 exact samples, witness b=1 rank 15, Π⋆ b<1) | proof in text; receipt is sampled + witness |
| C-3 | im 𝒮_reg = {h Lorentzian, b(h,f) < \|χ\|}; e unbounded | SD.11c–e | `verify_suture_image_v0_1.py` (family a∈{1,7,41} exact, null witness in Q(√2,√3), F=0, symbolic minor −16√2 s³(1+a²)^{7/2}) | CLOSED modulo R-4 |
| C-4 | Ψ = m·D𝒮 ⇒ m = 0 ⇒ λ=B=0, Δ=0 on the regular constraint surface | SD.12–SD.14b, SD.17 | `verify_delta_and_psi`: Δ(0,0)=0 computed; Δ(λ=1) rank 32; m↦Ψ rank 16 at Π⋆, Π_vac; Ψ equals mᵀJ with SD.17 weights; negative control | CLOSED at the two points; globally by rank of D𝒮 on the branch |
| C-5 | Constraint count 53+37 = 90 = 26 FC + 64 SC; DoF 4 (SD.15 chart 148, SD.1 chart 124) | SD.28–SD.30, Charts ¶ | `verify_counts` (arithmetic from the displayed lists) | CLOSED as arithmetic; the lists themselves are CARRIED from the text |
| C-6 | Lapse/shift bracket: rank 64, kernel 4 = span π̃_a | SD.20e–f | `verify_bracket_matrix` (68×68 exact, ultralocal) | CLOSED pointwise |
| C-7 | Π → (g, F_sol); g(Π^{(r)}) = g, F(Π^{(r)}) = F for all r∈ℤ₇; g(Π̄)=g, F(Π̄)=−F | SF.11–SF.13a, SF.17 | `verify_suture_field_v0_2.py` `verify_pullback_typing` (4 coframes, exact over ℚ(ζ₇,i)) | CLOSED (v0.1 gap was token presence) |
| C-8 | SF.4→SF.6 basis change, fixed e∞,u₀ block, 5 negative controls | SF.4–SF.6 | `verify_suture_basis_change_v0_2.py` | CLOSED |
| C-9 | Ĥ: (E,η̂,Ĉ) → (E^σ,η̂,−Ĉ); commutes with ρ̂(τ^w) iff w=0 | SF.8, SF.10, SF.13 | `verify_eight_dimensional_carrier`; `verify_mirror_bundle_v0_1.py` (float cross-check) | CLOSED |
| C-10 | CHSH over root reflections: S²=4I−[A,A′]⊗[B,B′]; 2√2; local max 2 | (handle, Bell entry) | `verify_chsh_root_v0_1.py` | CLOSED; not placed in a card |

## B. Open edges

| ID | Edge | Address | Witness needed | Status |
|---|---|---|---|---|
| R-1 | Theorem proof is compressed: no explicit solve of 𝒞, m; no Dirac bracket; no ξ-independence of 𝒮_red | SD.21 proof | written derivation; check that 𝒮_red is independent of ξ | OPEN (ε_strength) |
| R-2 | First-class status of π̃_a with respect to ℋ_⊥, ℋ_i | SD.20f, SD.24–27 | bracket {π̃_a, ℋ_⊥}, {π̃_a, ℋ_i} ≈ 0 | OPEN (stated "not re-derived") |
| R-3 | Free action of 𝔨 on the whole regular branch (checked at Π⋆, Π_vac) | SD.10–SD.11 | orbit rank 10 on an open dense set, or a counterexample point | OPEN |
| R-4 | Normal forms of a 2-form on a Lorentzian metric are cited, not proved | SD.11e | proof or reference with theorem number | CARRIED |
| R-5 | χ calibration; the ~10¹¹ T figure; units of b | Remark after SD.11e | calibration record | CARRIED, not rechecked |
| R-6 | A-4 prediction record; literature priority check (constrained-coframe, Born–Infeld) | — | pre-registered record | OPEN; priority check is the author's call |
| R-7 | Bracket check (C-6) and Δ check (C-4) are pointwise/ultralocal finite models with √−g = 1 | SD.13, SD.20e | field-theoretic Dirac bracket | CARRIED scope |
| R-8 | Cap receipt is sampled sign checks plus one attaining witness; the proof is analytic (H_c signature) | SD.11b | symbolic proof check | CARRIED |
| R-9 | Card 5 double-use symbols: A (potential vs 𝒜₈ vs A_J), χ vs κ, Φ_sol vs Φ (Card 3), ℤ₇-holonomy coupling | SF.18–SF.24 | notation table in common.tex | OPEN |
| R-10 | Set-level double-use: λ, κ, S, U, T, 𝓗, G, E, B, 𝒮 across cards | series | notation-table macro | OPEN |
| R-11 | Placement of the Bell/CHSH identity (Card 3 or Paper 6) | — | author's decision | OPEN |
| R-12 | Cards 1–4: Card 4 v0.3 text and verifier rank-21 converse spot-checked only | cards 1–4 | independent rerun | OPEN |

## C. Changes from v0.1 (applied in source)

Card 5: `\Span` backslash (SF.5); first summand labelled Gr–Ū; `\sharedroot` carries HC=−CH, HCH=−C;
single 𝒜₈ (`\sharedmatching`); L_Π separate from L_s; current typed J_em (SF.19); mirror field
Π̄ := ĤΠ ∈ Ω¹(M,E^σ), σ(τ^w)=τ^{−w}, Π̄^{(w)}=ρ̂(τ^{−w})Π̄, used in SF.13, SF.13a and SF.17 (no Π^μ).
05a: SD.11a–e (cap, regular family, null witness, image), SD.14b, SD.17 weights, SD.20f π̃_a, Charts
paragraph (SD.15 vs SD.1), Theorem domain b(g,F) < |χ|, line-56 typo.
