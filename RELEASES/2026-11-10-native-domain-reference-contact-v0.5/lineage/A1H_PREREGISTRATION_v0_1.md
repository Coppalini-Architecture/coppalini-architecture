# A1/H — Hydrogen reference contact · Pre-registration v0.1

**Date (UTC):** 10 November 2026
**Status:** PRE-REGISTERED — NOT RUN. At freeze, no CODATA value, ASD value, model value, or isotope-shift datum has been retrieved or computed for this record.
**Freeze rule:** every field below is frozen at the SHA-256 of this file. A change to any field voids the record and requires a new version (§9).

---

## 0. Entry

| Field | Value |
|---|---|
| Entry | A1/H-PR-0.1 |
| Row addressed | Atlas v0.3 register v0.5, row "Atomic: H, He, Li and descriptors", hydrogen component only |
| Gap addressed | Hydrogen has a declared-model closure and quoted NIST values but no recorded residual and no tolerance |
| Not addressed | Helium, lithium, H–Li descriptors, Clear Onyx A-1 dynamic receipt, spin/Berry/occurrence offices of the hydrogen audit |
| Office | Source-reference contact (Status-label ruling v0.1). Not a prospective novelty gate: no Architecture-derived number is advanced |

## 1. Depends on

| Item | Binding |
|---|---|
| Atlas v0.3 packet | zip SHA-256 `4075a5c57fe36a2977311ea58dad5181ed5b971859df390e797ed23ee6f8d075` |
| Register v0.5 | `23a16e2bb14ddf281642a43e8650220f50ee46eafa71b9c5efeab7469a70a5a7` |
| Status-label ruling v0.1 | `ebdf9ded5a1ad2a65e0112e72aa14b61716ce88f4c900b1de5ba6d5f0c00a426` |
| `MINIMUM_HYDROGEN_DYNAMICS_AUDIT.md` | `89dd3258b16cc571ed12ec8bf401eb2919bc03cd967952a1685fbbe65931c92a` |
| U0 authorities | CODATA 2022 (Web v9.0); NIST ASD v5.12; BIPM SI Brochure 9th ed. v4.01 |
| U0 addition required | CODATA 2022 `m_p/m_e` and `m_d/m_e` (deuteron entry is absent from U0 as of v0.3) |

## 2. Model under test (frozen)

Nonrelativistic, field-free, spin-factored Coulomb problem in the centre-of-mass reduced-mass form, for nucleus X in {p, d}:

- `E_n(X) = −R_X h c / n²`, `R_X = R_∞ / (1 + m_e/m_X)`, `m_e/m_X = 1/(m_X/m_e)`.
- Wavenumber of shell n above 1s: `ν̃_X(n) = R_X (1 − 1/n²)`. Ionization wavenumber from 1s: `ν̃_ion(X) = R_X`.
- Excluded by declaration: fine structure, Lamb shift, hyperfine structure, finite nuclear size, recoil and QED corrections.
- Isotope labels: H = ¹H (protium, X = p); D = ²H (X = d). No other isotope enters.
- Implementation under test: the closed form above, evaluated in exact decimal arithmetic at ≥ 50 digits (no floating point). The Clear Onyx code is not the implementation under test (see S1).

## 3. Observables

| ID | Quantity | Model value | Reference (retrieved after model values are hashed, §7) |
|---|---|---|---|
| P1 | H I ionization wavenumber | `R_p` | ASD v5.12 H I ionization energy, in cm⁻¹ |
| P2–P6 | H I shell centroid for n = 2, 3, 4, 5, 6, relative to the 1s level | `R_p (1 − 1/n²)` | `Σ(2J+1)σ_level / Σ(2J+1)` over all ASD v5.12 H I levels with principal quantum number n, wavenumbers taken relative to the ASD 1s level |
| S1 | Reduced-mass Bohr radius `a_H` and Coulomb beat period `T_21` as reported in the hydrogen audit | recomputed from CODATA 2022 under §2 | the audit's quoted digits |

The centroid rule is frozen so that the choice of fine-structure level (2s vs 2p, J-resolved) cannot be made after seeing the data.

## 4. Held-out observable

| Field | Value |
|---|---|
| ID | HO-1 |
| Quantity | H–D isotope shift of the 1S–2S transition, D minus H |
| Model value | `Δν̃ = (3/4) R_∞ [ 1/(1 + m_e/m_d) − 1/(1 + m_e/m_p) ]`, converted to frequency with the exact value of c |
| Datum | The measured H–D 1S–2S isotope shift with the smallest quoted uncertainty among primary experimental reports, located by logged search after Phase 3 |
| Read order | The datum is not retrieved or opened until the Phase 3 receipt is written and hashed |
| Role | Sole held-out observable. Tests the reduced-mass structure and the deuteron input, which P1–P6 do not exercise |

## 5. Acceptance rules (frozen)

- Residual: `δ = (model − reference) / reference`.
- Tolerances: `τ_P = 1.0e-4` for P1–P6; `τ_H = 1.0e-4` for HO-1. Both are round bounds of order α², the scale at which the omitted terms in §2 enter. Neither is fitted.
- **H-1 PASS** iff `|δ| ≤ τ_P` for all of P1–P6.
- **H-2 PASS** iff `|δ| ≤ τ_H` for HO-1.
- **S1 PASS** iff the recomputed value rounds to the audit's quoted digits (half-unit of the last quoted digit).
- Residuals and signs are reported for every observable regardless of outcome.
- Tolerances are not tightened or loosened after Phase 2.

## 6. Preconditions (record is void, not failed, if any fails)

| ID | Condition |
|---|---|
| V1 | Constants retrieved from CODATA 2022 Web v9.0 with URL, retrieval date, and SHA-256 of the retrieved page |
| V2 | Relative standard uncertainty of each retrieved constant used is ≤ 1e-8, and the propagated uncertainty of HO-1's model value is ≤ 1e-6 of that value |
| V3 | ASD version at retrieval is v5.12; if not, the observed version is logged and the record is re-registered |
| V4 | H and D labels as in §2; any mislabel voids the run |
| V5 | All arithmetic in exact decimal or rational form at ≥ 50 digits |

## 7. Order of operations

| Phase | Action | Output |
|---|---|---|
| 0 | Freeze: SHA-256 of this file; external timestamp by commit to the Coppalini-Architecture repository before Phase 1 | frozen hash |
| 1 | Retrieve CODATA 2022 constants only (R_∞, m_p/m_e, m_d/m_e, and their uncertainties) | constants log, hashed |
| 2 | Compute all model values (P1–P6, S1, HO-1) | model receipt, hashed |
| 3 | Retrieve ASD v5.12 H I data; compute P1–P6 residuals and S1 | comparison receipt, hashed |
| 4 | Retrieve the HO-1 datum; compute its residual | held-out receipt, hashed |
| 5 | Update register row and U0 | register entry |

## 8. Contamination register

| ID | Disclosure |
|---|---|
| C1 | The hydrogen audit already quotes NIST values near 13.598433 eV (ionization) and 10.1988 eV (1s→2p). P1 and P2 are therefore not blind. Blinding applies to P3–P6 and HO-1 |
| C2 | The drafter has not retrieved the HO-1 value. The drafter's recall of its approximate magnitude cannot be excluded |
| C3 | CODATA constants are retrieved at Phase 1, not taken from drafter recall |

## 9. Failure and amendment

| ID | Condition | Consequence |
|---|---|---|
| F1 | H-1 fails | The hydrogen row stays at declared-model realization. Residuals are recorded. No retuning of τ or of the centroid rule |
| F2 | H-2 fails | Check the m_d source and labels before any conclusion about the model. The failure is recorded either way |
| F3 | Any §6 condition fails | Record void. Re-register with changed fields listed; the void record is retained |
| F4 | Any frozen field changed after Phase 0 | Record void. The earlier hash and its results are retained beside the new version |

## 10. Boundary

- A pass establishes numeric source-reference contact for the hydrogen reduced-mass Coulomb carrier at the stated tolerance and no tighter.
- This record tests the carrier the Architecture maps into. It does not test the Architecture, and it advances no new Architecture-derived value, effect, or discriminator.
- Atomic number, isotope, and state labels are received selection.
- The Clear Onyx A-1 dynamic receipt remains a separate gate, unchanged by any outcome here.
- No claim is made for helium, lithium, descriptors, Berry phase, spin lift, or occurrence retention.
