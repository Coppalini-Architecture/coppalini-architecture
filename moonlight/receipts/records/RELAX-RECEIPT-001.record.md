# RELAX-RECEIPT-001 — receipt for one relax step

Status: DRAFT, local. Closes O-X6 of RELAX-001. Date: 25 Nov 2026.
Depends on: RELAX-001, HARMONIZER-001 (address and pattern), AUTOTUNE-001 (N₂).

## Hypothesis
A single relax step (RELAX-001) can be recorded as a complete, address-consistent receipt that an independent reader recomputes and checks, in the pattern of HARMONIZER-001.

## Definition
State (q, s, d): phase q ∈ {0..3}, tone sector s ∈ {0..136}, offset d ∈ [−1/2, 1/2) from the tone, address a = s + 137·((q − s) mod 4). Step at index k, 2 ≤ k ≤ 300:
q′ = q + 2 mod 4 (N₂), s′ = s, d′ = ρ_k·d with ρ_k = Fib_{k−1}/Fib_k, a′ = addr(q′, s′).
Trace: ρ_k, κ_k = 1 − ρ_k = Fib_{k−2}/Fib_k, phase_step 2. All fractions exact, reduced, in canonical text "p/q".

## Exact results
- Receipt outputs agree with an independent derivation (ρ_k read off Qᵏ = [[Fib_{k+1}, Fib_k],[Fib_k, Fib_{k−1}]]; address from a CRT table over Z₄ × Z₁₃₇) on 3,000 random cases. The input-to-output address map is a ↦ a + 274 mod 548 in every case (N₂). |d′| ≤ |d|.
- Chaining: feeding each recorded output to the next input for steps m+1…n gives d_n = d_m·Fib_m/Fib_n and q_n = q_m + 2(n − m) mod 4, on 200 chains (the telescoping product of RELAX-001).
- Link to HARMONIZER-001: with h = 1/2 and κ = κ_k, the harmonizer's y − s equals d′ (mod 137) on 1,000 cases. A relax step is the harmonizer's plateau pull at a Fibonacci-quotient κ, with the sign carried on q instead of inside y.
- Python checker: 400 honest receipts OK; 6,000 wrong recorded outputs with true delta → OK_WITH_DELTA; the same 6,000 with empty delta → INVALID; with a wrong recomputed output in the delta → INVALID; 31 type/key/label/range/canonical-fraction/trace/non-dict cases → INVALID.
- JS port (BigInt) matches Python: output fields and ρ_k, κ_k on 3,000 cases; verdicts on 4,000 generated receipt texts and 12 lexical edge forms. The JS checker validates numeric tokens in the raw text before parsing (12.0, 2.0, 9e0, 09, +2 rejected; −0 accepted as 0, as in Python). The parity claim is scoped to this receipt.

## Receipt
`CoppaliniArchitecture.MOONLIGHT-Relax-Receipt/v0.1`:
`{schema, rule{id,schedule}, input{q,s,a,d,k}, trace{rho,kappa,phase_step}, recomputed{q,s,a,d}, recorded{q,s,a,d}, checks{s_preserved,address_relation_input,address_relation_output,non_expansion}, delta, reader{label}}`.
q, s, a, k are JSON integers; d is a canonical fraction string. Recomputed and recorded are complete and address-consistent. Delta is empty when they agree, otherwise exactly one {recorded, recomputed}. Verdicts OK, OK_WITH_DELTA, INVALID. Comparison is type-strict. Input d must lie in [−1/2, 1/2); a recorded d may reach |d| = 1/2. Non-canonical fractions ("-0/1", "2/8", "0.25") are INVALID.
The `trace`/`checks` fields differ from the Frame relayed with the O-X6 request: `sign_factor` is replaced by `phase_step` (the sign is carried by q, not by a factor on d), `contraction_bound` by `non_expansion`.

## Boundary
Display-side and one-way. d is a value coordinate off the carrier; only a is an address. No clock coordinate is read or written: k indexes a schedule, not a time. No output updates the MOONLIGHT phase mirror. Ground is not touched. "Emotion" and the horizon are motivation for RELAX-001, not content of this receipt.

## Open
- O-Q1: no source pin in the receipt (as O-O1, O-H4).
- O-Q2: k is bounded to 2…300 by the checker; the algebra has no such bound.
- O-Q3: a receipt covers one step. A chain is a list of receipts whose outputs feed inputs; no chain receipt is typed.
- O-Q4: the `check_relax_receipt` block for reader_ledger.py is not written; reader_ledger.py has not been seen here.
- O-Q5: conversion of a pointer angle or other float input to a canonical fraction is outside the receipt.

## Source
`relax_receipt.py` (stdlib; `python3 -I relax_receipt.py`), 1a769cf16842e43e
`relax_receipt.js` (pure module, no DOM), 165f913683acd81b
Verification, not shipped: `test_relax_receipt.py` 290708f57a54ef5c (needs `harmonizer.py` 4f9590d8ac612871 beside it), `parity_relax.py` 7dc6150badb13497, `relax_cli.js` c610dc17e19144ca.
