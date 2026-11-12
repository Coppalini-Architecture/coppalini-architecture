# Suture audit v0.3 — residual ledger (Card 5 + 05a)

One boundary, one revision. Addresses are equation tags in `source/05_suture_field.tex` (SF.n) and
`source/05a_suture_field_dynamics.tex` (SD.n). Verifier paths are relative to `source/`.
Status: CLOSED (computed or proved in v0.3) · CARRIED (cited/assumed, stated in text) · OPEN.

## A. Closed / carried results in v0.3

| ID | Statement | Address | Verifier / proof | Status |
|---|---|---|---|---|
| C-1 | Regular rank D𝒮 = 16 at Π⋆, Π_vac and Π_iso; dim 𝔨 = 10 | SD.5–SD.11, SD.14a | `verify_suture_field_dynamics_v0_3.py` exact | CLOSED |
| C-2 | Cap b ≤ \|χ\| (regular branch b < \|χ\|) | SD.11a–b | `verify_magnetic_cap_v0_1.py` (15 544 exact samples, witness b=1 rank 15, Π⋆ b<1) | proof in text; receipt sampled + witness |
| C-3 | im 𝒮_reg = {h Lorentzian, b(h,f) < \|χ\|}; e unbounded | SD.11c–e | `verify_suture_image_v0_1.py` (family a∈{1,7,41} exact, null witness in Q(√2,√3), F=0, symbolic minor −16√2 s³(1+a²)^{7/2}) | CLOSED modulo R-4 |
| C-4 | Ψ = m·D𝒮 ⇒ m = 0 ⇒ λ=B=0, Δ=0 on the regular constraint surface | SD.12–SD.14b, SD.17 | `verify_delta_and_psi`: Δ(0,0)=0; Δ(λ=1) rank 32; m↦Ψ rank 16 at Π⋆, Π_vac; Ψ=mᵀJ | CLOSED; global implication uses rank D𝒮=16 |
| C-5 | Constraint count 53+37 = 90 = 26 FC + 64 SC; DoF 4 (SD.15 chart 148, SD.1 chart 124) | SD.28–SD.30, Charts ¶ | `verify_counts` | CLOSED as arithmetic; displayed canonical lists are source statements |
| C-6 | Lapse/shift auxiliary bracket: rank 64, kernel 4 = span π̃_a | SD.20e–f | `verify_bracket_matrix` (68×68 exact, ultralocal) | CLOSED pointwise |
| C-7 | Π → (g, F_sol); g(Π^{(r)}) = g, F(Π^{(r)}) = F for all r∈ℤ₇; g(Π̄)=g, F(Π̄)=−F | SF.11–SF.13a, SF.17 | `verify_suture_field_v0_2.py` exact over ℚ(ζ₇,i) | CLOSED |
| C-8 | SF.4→SF.6 basis change, fixed e∞,u₀ block, 5 negative controls | SF.4–SF.6 | `verify_suture_basis_change_v0_2.py` | CLOSED |
| C-9 | Ĥ: (E,η̂,Ĉ) → (E^σ,η̂,−Ĉ); commutes with ρ̂(τ^w) iff w=0 | SF.8, SF.10, SF.13 | exact carrier verifier; float mirror cross-check | CLOSED |
| C-10 | CHSH over root reflections: S²=4I−[A,A′]⊗[B,B′]; 2√2; local max 2 | (handle, Bell entry) | `verify_chsh_root_v0_1.py` | CLOSED; not placed in a card |
| C-11 | Whole-branch freeness of 𝔨 is false: Π_iso is regular but rank(X↦XΠ_iso)=9; X_iso=0₆⊕C≠0 annihilates Π_iso | SD.10a–b | `verify_suture_field_dynamics_v0_3.py` exact; h(Π_iso)=[[-2,1],[1,3]]⊕I₂, block det −7 | CLOSED negatively; R-3 resolved |
| C-12 | Auxiliary Dirac reduction leaves the physical Poisson algebra unchanged: C^{-1} has zero 𝒞𝒞 block and physical observables commute with P_q,P_m,m | SD.21a–d | analytic field-theoretic proof; exact finite block check in `verify_dirac_reduction_block` | CLOSED; R-1 resolved |
| C-13 | Spatial-derivative terms in {𝒞,H_phys} fix u_q rather than generating a new constraint; π̃_a is first class modulo the second-class surface; P_ξa commutes strongly with the physical Hamiltonian and constraints | SD.20g–h, SD.21b | analytic canonical derivation; source-bound verifier guards | CLOSED; R-2 resolved |

## B. Open / carried edges after v0.3

| ID | Edge | Address | Witness needed | Status |
|---|---|---|---|---|
| R-4 | Normal forms of a 2-form on a Lorentzian metric are cited, not proved | SD.11e | proof or reference with theorem number | CARRIED |
| R-5 | χ calibration; units of b; any apparatus-scale numerical comparison | Remark after SD.11e | calibration record | CARRIED, not rechecked |
| R-6 | A-4 prediction record; literature priority check (constrained-coframe, Born–Infeld) | — | pre-registered record | OPEN; priority check is the author's call |
| R-7 | Δ and the lapse/shift rank receipts are pointwise/ultralocal finite models with √−g=1 | SD.13, SD.20e–f | none needed for SD.21a–d; retain as receipt scope | CARRIED scope |
| R-8 | Cap receipt is sampled sign checks plus one attaining witness; the proof is analytic (H_c signature) | SD.11b | symbolic proof check | CARRIED |
| R-9 | Card 5 double-use symbols: A (potential vs 𝒜₈ vs A_J), χ vs κ, Φ_sol vs Φ (Card 3), ℤ₇-holonomy coupling | SF.18–SF.24 | notation table in common.tex / explicit coupling if introduced | OPEN |
| R-10 | Set-level double-use: λ, κ, S, U, T, 𝓗, G, E, B, 𝒮 across cards | series | notation-table macro | OPEN |
| R-11 | Placement of the Bell/CHSH identity (Card 3 or Paper 6) | — | author's decision | OPEN |
| R-12 | Cards 1–4: Card 4 v0.3 text and verifier rank-21 converse spot-checked only | cards 1–4 | independent rerun | OPEN |

## C. Changes from v0.2

Card 5 source is unchanged except for the shared revision date.

Card 5a: SD.10a–b now records the exact regular isotropy counterexample Π_iso and removes the constant “other six” wording. The full vertical fiber remains dimension 16; the complement to the 𝔨-orbit has dimension 16−rank α_Π. SD.20g–h writes the lapse/shift and vertical first-class brackets. SD.21a–d now gives the inverse second-class kernel, multiplier stabilization, the field-theoretic Dirac bracket, and the exact reason its correction vanishes on physical observables. R-1, R-2 and R-3 are therefore closed in this revision.
