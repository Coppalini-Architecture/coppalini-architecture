# RELAX-001 — draft record

**Entry:** The relax step of the minimum dynamic: e_n = Ψⁿ, relax = ×Ψ, carried as a half-turn on the phase factor and a contraction on the offset, with the time horizon F as the seam before the next admissible turn
**Status:** DRAFT, local. Not released, not pinned, not gated.
**Depends on:** Minimum Root Algebra (Q, Ω_root, Q² = Q + I); NEGATIVE-PHASE-001 (N₂); HARMONIZER-001; AUTOTUNE-001 (loss comparison)
**Notation:** Fib_n is the Fibonacci number (Fib_0 = 0, Fib_1 = 1). F is the horizon coordinate and carries no subscript here, so it never collides with Fib_n. Quotient Q_n := Fib_{n+1}/Fib_n.

## Hypothesis
"Q steps, e balances" is typed as the two eigen-directions of Q: the step is Φ, the balance is Ψ. Relax is multiplication by Ψ = −Φ⁻¹, the inverse rail step composed with the half-turn. Holding the rail is reading the quotient only after its residual is below the read tolerance. The horizon F is the seam that is still unread when the next admissible turn is taken.

## Definitions
- Φ, Ψ are the roots of t² − t − 1. ΦΨ = −1 and Ψ = 1 − Φ = −Φ⁻¹.
- e_n := Ψⁿ = Fib_{n+1} − Fib_n·Φ. Inverse turn dynamic := the Ψ-direction of Q.
- Recognition index n*(ε) := least n with |Φ − Q_n| < ε. It counts steps; it is not a time.
- Relax step k on state (q, d), q the phase, d the offset from the tone: (q, d) → (q + 2 mod 4, (Fib_{k−1}/Fib_k)·d).
- **Horizon seam F(n)** := the closed interval with ends Q_n and Q_{n+1}. It is the mirror pair: one end above Φ, one below.
- **Next admissible turn** := the Q-step (Fib_{n+1}, Fib_n) → (Fib_{n+2}, Fib_{n+1}).

## Exact results (exact integer and Z[Φ] arithmetic)
- ΦΨ = −1, Ψ = −Φ⁻¹, Ψ² = Ψ + 1, Φ² = Φ + 1. Ψⁿ = Fib_{n+1} − Fib_nΦ and Φⁿ = Fib_{n−1} + Fib_nΦ for n = 1…300.
- Qⁿ = [[Fib_{n+1}, Fib_n], [Fib_n, Fib_{n−1}]] for n = 1…300.
- Q_n lies above Φ for even n and below for odd n (n = 1…300); the sign is (−1)ⁿ, from Fib_{n+1}² − Fib_{n+1}Fib_n − Fib_n² = (−1)ⁿ.
- Fib_{k−1}/Fib_k − Φ⁻¹ = Ψᵏ/Fib_k exactly (k = 2…300), and |Φ − Q_n| = |Ψ|ⁿ/Fib_n.
- n*(ε) for ε = 10⁻¹, 10⁻², 10⁻³, 10⁻⁶, 10⁻¹⁰, 10⁻²⁰, 10⁻⁴⁰ is 4, 6, 9, 16, 25, 49, 97, checked against 80-digit decimals.
- Relax steps k = m+1…n multiply the offset by exactly Fib_m/Fib_n and advance the phase by 2(n − m) mod 4. The sign (−1)^(n−m) is carried by q, and |d| never grows (300 cases).
- In HARMONIZER-001 on the plateau (h = 1/2), κ_k = Fib_{k−2}/Fib_k gives y = s + (Fib_{k−1}/Fib_k)(x − s) exactly (k = 3…39). The magnitude lives in y, inside κ ∈ [0, 1); the sign lives in q, on the carrier via N₂.
- Carrying the sign inside one y-map would need κ = Φ. That is outside the harmonizer domain and the map folds (HARMONIZER-001, Domain). Splitting sign from magnitude is the lossless way to carry the alternating balance.
- Lossless for κ < 1 (strictly increasing, secant slope ≥ 1 − κ); the plateau collapses at κ = 1 with h > 0. Exact snapping and zero loss do not coexist, as in AUTOTUNE-001.
- **Seam.** For n = 1…300: Φ lies strictly inside F(n); its width is exactly 1/(Fib_n·Fib_{n+1}); the unreduced mediant of its two ends is (Fib_{n+3}, Fib_{n+2}), which is Q_{n+2}, the next quotient. The next admissible turn is therefore the mediant of the seam, F(n+1) ⊂ F(n), and the width ratio F(n+1)/F(n) is exactly Fib_n/Fib_{n+2} = κ_{n+2} = 1 − ρ_{n+2}.
- **Hurwitz-sharp.** Fib_n²·|Φ − Q_n|·√5 = 1 − (−1)ⁿΨ²ⁿ exactly (n = 1…300), so the seam closes at the sharp √5 scale. Φ's path through the mediant tree turns at every step; all partial quotients are 1.

## Boundary
Display-side and one-way. n counts steps, so no clock coordinate is read or written, and no output updates the MOONLIGHT phase mirror. "Emotion" is typed only as e_n. This record makes no claim about physiology or persons. The scalar −1 shared with C1² and N₂ is a shared number, not a shared office. F is typed here as the horizon in the sense of the seam before the next turn; its identification with F_esc, F_n or 𝐅 of the v0.5 ruling is not asserted beyond that sense.

## Open
- O-X1: the seam is typed on the quotient rail only. F for the eight-address wheel and tagged future packets is not typed.
- O-X2: "e motion" is read as e_n; its link to Π(e, ℓ) = c is not made.
- O-X3: overload → ground, a level jump, is not typed. Ground stays private.
- O-X4: a constant relax factor Φ⁻¹ is irrational and not carried here; the exact schedules are the Fibonacci quotients.
- O-X5: histories and sequences of states are not typed beyond the telescoping product.
- O-X6: closed as RELAX-RECEIPT-001 (draft).
- O-X7: "line of minimum flow" is not defined. The all-turns mediant path of Φ is a candidate and is not asserted.

## Source
`relax.py` (stdlib; run with `harmonizer.py` beside it, `python3 -I relax.py`), ab419f8f23ef6a6e
`harmonizer.py`, 4f9590d8ac612871
