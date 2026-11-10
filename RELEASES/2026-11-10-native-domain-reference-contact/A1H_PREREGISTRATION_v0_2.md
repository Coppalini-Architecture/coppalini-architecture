# A1/H — Hydrogen reference contact · Pre-registration v0.2

**Date (UTC):** 10 November 2026
**Status:** PRE-REGISTERED — NOT RUN. This version fixes only the S1 formulas, the ASD parsing rule, and the HO-1 source-selection rule. It preserves the v0.1 model domain, observable set, tolerance, failure path, and claim boundary.
**Predecessor:** `lineage/A1H_PREREGISTRATION_v0_1.md`, SHA-256 `5fdcfd044bf98ee873b305e0e235ce23f4e61607f2f393aa3cf5d1c7576eed1b`.
**Freeze rule:** every field below is frozen at the SHA-256 of this file. A change to any field voids this version and requires a new version (§11).

---

## 0. Entry

| Field | Value |
|---|---|
| Entry | A1/H-PR-0.2 |
| Row addressed | Atlas v0.3 register v0.5, row “Atomic: H, He, Li and descriptors”, hydrogen component only |
| Gap addressed | Hydrogen has a declared-model closure and quoted NIST values but no recorded residual and no tolerance |
| Not addressed | Helium, lithium, H–Li descriptors, Clear Onyx A-1 dynamic receipt, spin/Berry/occurrence offices of the hydrogen audit |
| Office | Source-reference contact (Status-label ruling v0.1). This is not a prospective novelty gate: no Architecture-derived number is advanced |

## 1. Depends on

| Item | Binding |
|---|---|
| Atlas v0.3 packet | zip SHA-256 `4075a5c57fe36a2977311ea58dad5181ed5b971859df390e797ed23ee6f8d075` |
| Register v0.5 | `23a16e2bb14ddf281642a43e8650220f50ee46eafa71b9c5efeab7469a70a5a7` |
| Status-label ruling v0.1 | `ebdf9ded5a1ad2a65e0112e72aa14b61716ce88f4c900b1de5ba6d5f0c00a426` |
| `MINIMUM_HYDROGEN_DYNAMICS_AUDIT.md` | `89dd3258b16cc571ed12ec8bf401eb2919bc03cd967952a1685fbbe65931c92a` |
| U0 authorities | CODATA 2022 (Web v9.0); NIST ASD v5.12; BIPM SI Brochure 9th ed. v4.01 |
| U0 addition required | CODATA 2022 `m_p/m_e` and `m_d/m_e`, with standard uncertainties, source URL, retrieval date, and page SHA-256 |

## 2. Model under test (frozen)

The model is the nonrelativistic, field-free, spin-factored Coulomb problem in centre-of-mass reduced-mass form, for nucleus \(X\in\{p,d\}\). Let \(r_X=m_X/m_e\), and let \(c\) retain its exact SI value.

\[
R_X=R_\infty\frac{r_X}{1+r_X}=\frac{R_\infty}{1+1/r_X},
\qquad
E_n(X)=-R_Xhc/n^2.
\]

\[
\tilde\nu_X(n)=R_X(1-1/n^2),
\qquad
\tilde\nu_{\rm ion}(X)=R_X.
\]

The two S1 replication values are exactly defined here:

\[
a_H=a_0(1+1/r_p),
\qquad
T_{21}=\frac{4}{3cR_p}.
\]

\(a_0\), \(R_\infty\), \(r_p\), and \(r_d\) are CODATA 2022 finite-decimal inputs. All calculations use base-10 arbitrary-precision decimal arithmetic at \(\geq50\) significant decimal digits; no IEEE binary floating-point value is admitted.

- Excluded by declaration: fine structure, Lamb shift, hyperfine structure, finite nuclear size, recoil beyond the reduced-mass factor, and QED corrections.
- Isotope labels: H = \(^{1}\!H\) (protium, \(X=p\)); D = \(^{2}\!H\) (deuterium, \(X=d\)). No other isotope enters.
- Implementation under test: the closed forms above. Clear Onyx is not the implementation under test (see S1).

## 3. Observables and ASD extraction rule

| ID | Quantity | Model value | Reference |
|---|---|---|---|
| P1 | H I ionization wavenumber | \(R_p\) | ASD v5.12 H I ionization energy, in cm\(^{-1}\) |
| P2–P6 | H I shell centroid for \(n=2,3,4,5,6\), relative to 1s | \(R_p(1-1/n^2)\) | §3.1 centroid from ASD v5.12 level data |
| S1 | Reduced-mass Bohr radius \(a_H\) and Coulomb beat period \(T_{21}\) | §2 | Hydrogen audit’s quoted digits |

### 3.1 ASD centroid parser

Phase 3 retrieves the NIST ASD **Energy Levels Data** table for spectrum `H I`, version `5.12`, with energies in cm\(^{-1}\). Its raw response is retained and hashed before parsing. The parser is frozen as follows:

1. Require the headers `Configuration`, `J`, and `Level (cm-1)` (or an ASD-documented unambiguous spelling of those same fields). Any schema change voids the run.
2. Retain a row only when its one-electron `Configuration` field begins with a principal-integer/orbital token matching `^([2-6])[spdfghiklmno]` and its `J` field parses as a nonnegative integer or half-integer. The captured integer is the row’s \(n\).
3. Require one finite numeric `Level (cm-1)` value. Exclude and log every row with a missing, blended, continuum, uncertain, or unparsable field; any excluded candidate row with a parsable \(n\in\{2,3,4,5,6\}\) voids the run rather than silently changing a centroid.
4. Let \(\sigma_{n,j}\) be the retained level energy after subtraction of the ASD 1s level. The fixed centroid is
   \[
   \bar\sigma_n=\frac{\sum_j(2J_j+1)\sigma_{n,j}}{\sum_j(2J_j+1)}.
   \]

The rule fixes the fine-structure aggregation before the ASD values are used.

## 4. Held-out observable and selector

| Field | Value |
|---|---|
| ID | HO-1 |
| Quantity | H–D isotope shift of the 1S–2S transition, D minus H, as a frequency in Hz |
| Model value | \(\Delta\nu_{D-H}=\frac34cR_\infty[1/(1+1/r_d)-1/(1+1/r_p)]\) |
| Candidate type | A primary experimental report that states an absolute H–D 1S–2S isotope-shift frequency and a one-standard-deviation uncertainty |
| Corpus cutoff | Publications publicly available on or before 2026-11-10 23:59:59 UTC |
| Selector | Lowest stated total one-standard-deviation uncertainty among eligible candidate reports. A report that separately states independent statistical and systematic one-standard-deviation terms uses their quadrature. A report with an untyped, incompatible, or non-\(1\sigma\) uncertainty is ineligible and logged. A tie resolves by earlier publication date, then lexicographic DOI. |
| Read order | Candidate metadata and uncertainty may be logged only after the Phase 3 receipt is hashed. The selected datum and residual are then opened once, in the Phase 4 receipt. |
| Role | Sole held-out observable. It exercises the deuteron input, which P1–P6 do not exercise. |

The Phase 4 receipt must retain the discovery query, consulted index pages, candidate list, eligibility decisions, selected report, DOI or stable URL, publication date, source hash, frequency datum, uncertainty treatment, model value, residual, and PASS/FAIL result. If it cannot produce that complete selector record, the run is VOID rather than selectively completed.

## 5. Acceptance rules (frozen)

- Residual: \(\delta=(\text{model}-\text{reference})/\text{reference}\).
- Tolerances: \(\tau_P=1.0\times10^{-4}\) for P1–P6; \(\tau_H=1.0\times10^{-4}\) for HO-1. Both are round bounds of order \(\alpha^2\), the scale at which the excluded terms in §2 enter. Neither is fitted.
- **H-1 PASS** iff \(|\delta|\leq\tau_P\) for all P1–P6.
- **H-2 PASS** iff \(|\delta|\leq\tau_H\) for HO-1.
- **S1 PASS** iff each recomputed value rounds to the audit’s quoted digits (half-unit of the last quoted digit).
- Residuals and signs are reported for every observable regardless of outcome.
- Tolerances are not tightened or loosened after Phase 2.

## 6. Preconditions (record is void, not failed, if any fails)

| ID | Condition |
|---|---|
| V1 | Constants retrieved from CODATA 2022 Web v9.0 with URL, retrieval date, and SHA-256 of each retrieved page |
| V2 | Relative standard uncertainty of each retrieved constant used is \(\leq10^{-8}\), and propagated uncertainty of HO-1’s model value is \(\leq10^{-6}\) of that value |
| V3 | ASD version at retrieval is v5.12; a different version is logged and this record is re-registered |
| V4 | H and D labels are exactly those of §2 |
| V5 | All arithmetic conforms to §2 |
| V6 | The retained ASD response satisfies the §3.1 schema and inclusion rule |
| V7 | The Phase 4 selector receipt satisfies every field in §4 |

## 7. Order of operations

| Phase | Action | Output |
|---|---|---|
| 0 | Freeze this v0.2 file and timestamp it by commit to the Coppalini-Architecture repository before Phase 1 | frozen hash and commit URL |
| 1 | Retrieve only CODATA 2022 \(R_\infty,a_0,m_p/m_e,m_d/m_e\) and uncertainties | constants log, hashed |
| 2 | Compute P1–P6, S1, and HO-1 model values | model receipt, hashed |
| 3 | Retrieve ASD v5.12 H I data; apply §3.1; compute P1–P6 residuals and S1 | primary comparison receipt, hashed |
| 4 | Build the §4 selector record; retrieve the selected HO-1 datum; compute its residual | held-out receipt, hashed |
| 5 | Update U0 and the Atlas register row | append-only register entry |

## 8. Contamination register

| ID | Disclosure |
|---|---|
| C1 | The hydrogen audit already quotes NIST values near 13.598433 eV (ionization) and 10.1988 eV (1s→2p). P1 and P2 are therefore not blind. Blinding applies to P3–P6 and HO-1 at the original v0.1 freeze. |
| C2 | The v0.1 drafter did not retrieve HO-1. Recall of its approximate magnitude could not be excluded. |
| C3 | The v0.2 editor inspected the existing U0 source register before this freeze. That register contains prior CODATA 2022 values for \(m_e,m_p,a_0,hcR_\infty,\alpha^{-1}\), but no ASD level rows, H–D 1S–2S datum, or P1–P6/HO-1 model computation. S1 is therefore expressly a replication check, not a blind comparison. |
| C4 | CODATA values used for this run are retrieved anew in Phase 1 from the authoritative pages and bound there; no value is imported from memory or from C3. |

## 9. Failure and amendment

| ID | Condition | Consequence |
|---|---|---|
| F1 | H-1 fails | Hydrogen remains at declared-model realization. All residuals remain recorded. No retuning of \(\tau\) or centroid rule. |
| F2 | H-2 fails | Check the deuteron source and labels before any conclusion about the model. The failure is recorded either way. |
| F3 | Any §6 condition fails | Record VOID. Re-register with changed fields listed; retain this record and its outputs. |
| F4 | Any frozen field changes after Phase 0 | Record VOID. Retain the earlier hash and results beside the new version. |

## 10. Boundary

- A pass establishes numeric source-reference contact for the hydrogen reduced-mass Coulomb carrier at the stated tolerance and no tighter.
- The record tests the carrier that the Architecture maps into. It does not test the Architecture and advances no new Architecture-derived value, effect, or discriminator.
- Atomic number, isotope, and state labels are received selection.
- The Clear Onyx A-1 dynamic receipt remains a separate gate, unchanged by any outcome here.
- No claim is made for helium, lithium, descriptors, Berry phase, spin lift, or occurrence retention.

## 11. v0.2 delta

v0.1 remains retained. v0.2 adds no result and changes no acceptance threshold. It types (i) the S1 formulas, (ii) the ASD extraction map, (iii) the HO-1 candidate/uncertainty selector, and (iv) the disclosed U0 contamination visible before this freeze.
