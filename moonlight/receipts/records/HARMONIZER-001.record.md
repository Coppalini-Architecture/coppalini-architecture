# HARMONIZER-001 — draft record

**Entry:** One parameter-override function H(q, x; h, κ) → (a, y): nearest iris sector from a real phase coordinate, with a band-limited pull toward it
**Status:** DRAFT, local. Not released, not pinned, not gated.
**Depends on:** MOONLIGHT Iris Dome v0.3 address relation, a = s + 137·((q − s) mod 4); NEGATIVE-PHASE-001 (N₂, N_c); RANGE-COMPRESSION-001 (comparison only); AUTOTUNE-001 (receipt pattern)

## Hypothesis
The separate input branches (phase buttons, iris input, pointer click) close into one function whose inputs stay distinct and typed. The phase is fixed, the real coordinate x is read against the 137 iris sectors, and a continuous pull of strength κ within band h moves it toward the nearest sector. Declared decisions (Λ, 25 Nov 2026): the grid is the 137 iris sectors inside a fixed q band; h and κ are fresh scalars; "meantone" is not a claim of this record.

## Definition
Inputs: q ∈ {0,1,2,3}; x a finite decimal literal (exact rational, iris-sector units); h ∈ [0, 1/2], κ ∈ [0, 1] finite decimal literals.
- x₀ = x mod 137 ∈ [0, 137)
- k = ⌊x₀ + 1/2⌋; **tie rule: a half goes to the larger sector.** s = k mod 137
- d = x₀ − k ∈ [−1/2, 1/2); m = |d|
- w = κ for m ≤ h; w = κ·S((1/2 − m)/(1/2 − h)) for h < m < 1/2, with S(u) = 3u² − 2u³
- y = (x₀ − w·d) mod 137, exact rational, off-carrier
- a = s + 137·((q − s) mod 4), on-carrier; q is preserved

## Exact results
- The sector rule agrees with a separate derivation (argmin of ring distance over all 137 sectors, signed ring offset, y = s + (1 − w)·d) on 1,500 cases including forced ties. All 137 half-integers go to the larger sector.
- y ∈ [0, 137), a mod 4 = q and a mod 137 = s on 4,000 random exact cases. κ = 0 gives y = x₀. For |d| ≤ h, y = x₀ − κ·d exactly; at κ = 1 that is y = s.
- h = 1/2, κ = 1: y = s for every x (hard staircase). With h = 1/2 the jump across a tie equals κ (checked at κ = 1, 3/4, 1/10).
- h < 1/2: y is continuous across ties and C¹ there (slope 1, gap 2ε + O(ε²)). The pull is therefore smooth for any steepness short of h = 1/2.
- **Price of continuity.** For h < 1/2, y runs from s + (1 − κ)h at d = h to (s + 1) − (1 − κ)h at the next sector's plateau edge. Its mean slope over that span is exactly (1 − 2(1 − κ)h)/(1 − 2h) ≥ 1, which is 1/(1 − 2h) at κ = 1. Some slope is at least that mean, so exact snapping and continuity exclude each other; the steepness grows without bound as h → 1/2 and becomes the jump of size κ at h = 1/2. Checked exactly on 400 cases; a finite-difference slope reaches the mean in each.
- **Monotone, and lossless for κ < 1.** With w non-increasing in m and 0 ≤ w ≤ κ, y′ = 1 − w + m·|w_m| ≥ 1 − κ wherever y is differentiable. So y is non-decreasing for every (h, κ), and for κ < 1 strictly increasing with every secant slope ≥ 1 − κ: an injective re-parametrization of the ring that a reader can invert. At κ = 1 with h > 0 the plateau collapses to its tone (x = s ± 1/8 both give y = s at h = 1/4), which is the AUTOTUNE-001 exclusion again: exact snapping and zero loss do not coexist. Checked: 3,000 exact secant cases at κ < 1, the five-pair 5,480-point grid, and the collapse case (`relax.py`).
- **Non-expansion.** |y − s| = (1 − w)|d| ≤ |d|, so y never lies farther from the tone than x₀ and never crosses it: 3,000 exact cases.
- **Domain.** κ > 1 is outside the record. The plateau slope 1 − κ turns negative and the map folds: at h = 1/4, κ = 2, x = s + 1/8 and x = s + 0.3441 both give y = s − 1/8. An alternating balance (factor Ψ = 1 − Φ at κ = Φ) is therefore not carried inside one y-map; RELAX-001 carries its sign on the phase factor instead.
- **Canonical fractions.** A recorded fraction is accepted only in canonical text (lowest terms, positive denominator, no sign on zero). "-0/1", "0/2", "00/1", "+0/1", "0/-1" and "0" are INVALID in both implementations; before this fix "-0/1" parsed as 0 and could pass or produce a phantom delta against "0/1". The pins in Source are the post-fix bytes.
- The address output commutes with N₂ and N_c (q → q + 2, q → −q): 2,000 cases.

## Receipt
`CoppaliniArchitecture.MOONLIGHT-Harmonizer-Receipt/v0.1`:
`{schema, rule{id,tie,profile}, input{q,x,h,kappa}, trace{x_mod,d,w}, recomputed{s,a,y}, recorded{s,a,y}, checks{q_preserved,address_relation}, delta, reader{label}}`.
x, h, κ are decimal strings; x_mod, d, w, y are reduced fractions "p/q". Both selections are complete and address-consistent. Delta is empty when recorded equals recomputed, otherwise one entry {recorded, recomputed}. Comparison is type-strict.

Checked (Python): 300 honest receipts pass. 6,000 wrong recorded outputs with their true delta return OK_WITH_DELTA; the same 6,000 with an empty delta, or with a wrong recomputed output in the delta, return INVALID.
Checked (JS port, BigInt): the output fields (s, a, y, d, w, x₀) match Python on 3,000 cases. Verdicts match on 1,200 generated receipt texts and 8 lexical edge forms. The JS checker validates numeric tokens in the raw text before parsing (1.0, 0e0, 00, +0 rejected; −0 accepted as 0, as in Python). The parity claim is scoped to this receipt.

## Boundary
Display-side and one-way. x and y are value coordinates off the carrier; only a is an address. No clock coordinate is read or written, so the pull is a function of distance, not time. No output updates the MOONLIGHT phase mirror. h and κ are new scalars; neither is G_root or a metric. Meantone is not asserted.

## Open
- O-H1: attack in time (a pull that depends on a clock or sequence of inputs) is not typed.
- O-H2: the profile S is a choice. Other profiles, including the Gaussian (Debye–Waller) attenuation, are not rational and are not typed.
- O-H3: composition with C(t,r) (C acts on the integer index, H on the real coordinate) is not typed.
- O-H4: the receipt names no source pin, as in O-O1.
- O-H5: conversion of a pointer angle or other float input to a decimal literal is outside the receipt.

## Source
`harmonizer.py` (stdlib, self-contained; `python3 -I harmonizer.py`), 4f9590d8ac612871
`harmonizer.js` (pure module, no DOM), 4eff82ac5c4010fa
Verification, not shipped: `relax.py` (needs `harmonizer.py` beside it), `test_independent.py` 13c7117507fafb36, `parity.py` dcb27c1f77b08bf7, `harm_cli.js` 92b478c725360556.
