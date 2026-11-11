# A1/H — Hydrogen reference contact · Pre-registration v0.4

**Date (UTC):** 10 November 2026
**Status:** PRE-REGISTERED — NOT RUN. This version changes only the T2 formula-wrapper admission: quoted tab-delimited cells remain admissible; CSV-style formula cells are refused. It preserves the v0.3 retrieval, parsing, completeness, custody, and version-evidence rules, and the v0.2 model, observable set, tolerances, HO-1 selector, failure path, and claim boundary.
**Predecessors:** `lineage/A1H_PREREGISTRATION_v0_3.md`, SHA-256 `228c8348870f6362f2621c42282f1535601941b0e96bd62c7f99c7114ea123de`; `lineage/A1H_PREREGISTRATION_v0_2.md`, SHA-256 `1ac1308b9127a921dfe435420970e51f3c90a2dd1c5b883460e989e16be06dcc`; `lineage/A1H_PREREGISTRATION_v0_1.md`, SHA-256 `5fdcfd044bf98ee873b305e0e235ce23f4e61607f2f393aa3cf5d1c7576eed1b`.
**Supersession:** v0.1, v0.2, and v0.3 are retained and unrun. No Phase 1–4 receipt exists under any earlier version. v0.4 is the only version under which Phases 1–4 run.
**Freeze rule:** every field below is frozen at the SHA-256 of this file. A change to any field voids this version and requires a new version (§11).

---

## 0. Entry

| Field | Value |
|---|---|
| Entry | A1/H-PR-0.4 |
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
| P1 | H I ionization wavenumber | \(R_p\) | §3.5: the LIMIT row of the §3.1 response, relative to the 1s level |
| P2–P6 | H I shell centroid for \(n=2,3,4,5,6\), relative to 1s | \(R_p(1-1/n^2)\) | §3.5 centroid from the §3.1 response |
| S1 | Reduced-mass Bohr radius \(a_H\) and Coulomb beat period \(T_{21}\) | §2 | Hydrogen audit’s quoted digits |

### 3.1 Retrieval (frozen)

| Field | Value |
|---|---|
| Source | NIST ASD Energy Levels Form |
| Spectrum | `H I` |
| Level units | cm\(^{-1}\) |
| Format output | Tab-delimited ASCII |
| Extent | All levels in one response; no pagination |
| Ordering | Energy ordered |
| Level information requested | Principal configuration, Principal term, Level, Uncertainty, J |
| Request record | The exact request URL, or the complete form-parameter set, is logged with the UTC retrieval time |
| Retained bytes | The unmodified response bytes, saved as received and hashed with SHA-256 before any parsing |
| Additional columns | Permitted when present; logged and ignored, except Prefix/Suffix columns (§3.2 T8) |
| Version evidence | The unmodified bytes of the ASD Version History page (`https://physics.nist.gov/PhysRefData/ASD/Html/verhist.shtml`), retrieved within 24 hours of the levels response, hashed with SHA-256. The highest version number matched by the regular expression `Version\s+([0-9]+)\.([0-9]+)` must be 5.12 |

### 3.2 Transport and token grammar (frozen)

| ID | Rule |
|---|---|
| T1 | Split the retained bytes on LF and strip one trailing CR from each line. The bytes must decode as UTF-8 or the run is VOID. Split each line into cells on TAB |
| T2 | Cell normalization, in this order and nothing else: (i) strip leading and trailing ASCII spaces; (ii) if the cell matches `^"(.*)"$`, replace it by group 1; a cell matching `^=".*"$` is REFUSED as a CSV-style formula wrapper outside the frozen tab-delimited format; (iii) strip leading and trailing ASCII spaces. Every cell changed by the permitted wrapper step, and every formula-wrapper refusal, is logged |
| T3 | The header is the first line whose normalized cells include `Configuration`, `Term`, `J`, a cell matching `^Level \(cm(\^)?-1\)$`, and a cell matching `^Uncertainty \(cm(\^)?-1\)$`. Columns are located by header, not position. Lines before the header, blank lines, comment lines, and repeated headers are non-data lines: logged, never parsed as rows. A missing header, or a header whose Level or Uncertainty unit is not cm\(^{-1}\), makes the run VOID |
| T4 | Level token. A bare token matches `^[0-9]+(\.[0-9]+)?$`. A digit-grouped token matches `^[0-9]{1,3}( [0-9]{3})+(\.[0-9]+)?$`; its single ASCII spaces are removed and the raw and normalized forms are both logged. Every other token is refused: brackets, parentheses, `?`, `†`, `+x`, trailing letters such as `a`, signs, exponents, commas, and blank cells |
| T5 | J token. It matches `^[0-9]+$` (then \(2J=2m\)) or `^[0-9]*[13579]/2$` (then \(2J\) is the numerator). Every other token is refused, including lists such as `3/2,5/2` and blank cells |
| T6 | Configuration token, after fill (§3.3). It must match `^([1-9][0-9]*)([spdfghiklmno])$`. The captured integer is \(n\). The letter gives \(l\) by s=0, p=1, d=2, f=3, g=4, h=5, i=6, k=7, l=8, m=9, n=10, o=11. A configuration token that fails the pattern, including one carrying `?`, marks the row NONSHELL |
| T7 | Term cell. It is retained verbatim. A Term cell exactly equal to `Limit` marks the row LIMIT. Term and Uncertainty cells are never used in any computation; blank values are logged and permitted |
| T8 | Any column whose header contains `Prefix` or `Suffix` (case-insensitive), nonblank on a row with \(n\in\{1,\dots,6\}\) or on the LIMIT row, makes that row refused |

### 3.3 Row classification and Configuration fill (frozen)

Rows are processed in file order with a context \(\mathrm{ctx}\) that is empty or holds a Configuration cell.

1. A non-data line (§3.2 T3) sets \(\mathrm{ctx}\) to empty.
2. A row with Term exactly `Limit` is class LIMIT. It sets \(\mathrm{ctx}\) to empty. Its Level cell is parsed by T4; a refused token makes the run VOID.
3. A row with a nonblank Configuration cell sets \(\mathrm{ctx}\) to that cell. If the cell satisfies T6 the row is a shell candidate; otherwise it is NONSHELL, logged and excluded, and its continuation rows inherit NONSHELL.
4. A row with a blank Configuration cell and \(\mathrm{ctx}\) empty is an unmatched blank: the run is VOID.
5. A row with a blank Configuration cell and a nonblank Term cell is a Term without Configuration: the run is VOID.
6. Any other row with a blank Configuration cell inherits \(\mathrm{ctx}\) and is class CONTINUATION. It takes that Configuration for T6.
7. A shell candidate or continuation row is refused if its J or Level token fails T5 or T4 or if T8 applies. A refused row with \(n\leq6\) makes the run VOID. A refused row with \(n\geq7\) is logged and excluded.
8. Rows with \(n\geq7\) are logged and excluded from every computation.

### 3.4 Completeness witnesses (frozen; failure makes the run VOID)

Let \(R_n\) be the retained rows with T6 principal number \(n\), for \(n=1,\dots,6\).

- (a) Every row satisfies \(l\leq n-1\).
- (b) Every row satisfies \(2J\in\{2l-1,\,2l+1\}\) and \(2J\geq1\).
- (c) The triples \((n,l,2J)\) are pairwise distinct.
- (d) \(|R_n|=2n-1\).
- (e) \(\sum_{R_n}(2J+1)=2n^2\).
- (f) Exactly one row is class LIMIT.

These conditions hold for the complete one-electron fine-structure shells and are independent of ASD data. They detect any omitted, merged, duplicated, or wrongly inherited row.

### 3.5 Reference quantities (frozen)

Let \(L_{1s}\) be the Level of the unique \(n=1\) row, \(L_{\rm lim}\) the Level of the LIMIT row, and \(L_{n,j}\) the Level of each retained row with \(n\in\{2,\dots,6\}\). All values are parsed as exact decimals.

\[
\text{P1 reference}=L_{\rm lim}-L_{1s},
\qquad
\sigma_{n,j}=L_{n,j}-L_{1s},
\qquad
\bar\sigma_n=\frac{\sum_j(2J_j+1)\sigma_{n,j}}{\sum_j(2J_j+1)}.
\]

The P2–P6 reference values are \(\bar\sigma_n\) for \(n=2,\dots,6\). Reference values are in cm\(^{-1}\); model values in m\(^{-1}\) are converted by the exact factor \(10^{-2}\).

### 3.6 Receipts, parser identity, and fixtures (frozen)

- The Phase 3 receipt retains the raw-byte SHA-256 of the levels response and of the Version History page, the request record, the normalized parsed table, and the parsed-table SHA-256.
- The parsed table has one record per input line, with line number, class (non-data, LIMIT, NONSHELL, shell, CONTINUATION), raw and normalized cells, inherited Configuration source line, \(n\), \(l\), \(2J\), and decision (INCLUDED, INHERITED, EXCLUDED, REFUSED) with its reason.
- The parser source file is hashed in the Phase 2 receipt, before the levels response exists on the computing side. The Phase 3 parse uses that exact file.
- Before Phase 3 the parser is run on synthetic fixtures built by the drafter with invented numbers, not ASD data. The fixtures exercise every §3.2–§3.4 branch: bare and grouped Level tokens, the permitted quoted T2 wrapper and the refused formula wrapper, Configuration fill, each refused-token class, each VOID condition, and a complete and an incomplete shell. Fixture outcomes are recorded in the Phase 2 receipt.

### 3.7 Custody (frozen)

Raw source files may be supplied by the registrant. Each supplied file carries its source URL or request record and UTC retrieval time, and is hashed on receipt. The raw levels response and the HO-1 source are not released to the computing party until the preceding phase receipt hash is issued. The computing party writes the custody statement into each receipt.

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
| V3 | The Version History page retained under §3.1 shows the highest version 5.12; a different version is logged and this record is re-registered |
| V4 | H and D labels are exactly those of §2 |
| V5 | All arithmetic conforms to §2 |
| V6 | The retained ASD response satisfies §3.1 through §3.4 |
| V7 | The Phase 4 selector receipt satisfies every field in §4 |
| V8 | The Phase 2 receipt carries the parser source hash and passing fixture outcomes (§3.6), and precedes the release of the raw levels response (§3.7) |

## 7. Order of operations

| Phase | Action | Output |
|---|---|---|
| 0 | Freeze this v0.3 file and timestamp it by commit to the Coppalini-Architecture repository before Phase 1 | frozen hash and commit URL |
| 1 | Bind raw CODATA 2022 pages for \(R_\infty,a_0,m_p/m_e,m_d/m_e\) and their uncertainties | constants log, hashed |
| 2 | Compute P1–P6, S1, and HO-1 model values; hash the parser source; run the §3.6 fixtures | model receipt, hashed |
| 3 | Release the raw ASD levels response and Version History page (§3.7); apply §3.2–§3.5; compute P1–P6 residuals and S1 | primary comparison receipt, hashed |
| 4 | Build the §4 selector record; retrieve the selected HO-1 datum; compute its residual | held-out receipt, hashed |
| 5 | Update U0 and the Atlas register row | append-only register entry |

## 8. Contamination register

| ID | Disclosure |
|---|---|
| C1 | The hydrogen audit already quotes NIST values near 13.598433 eV (ionization) and 10.1988 eV (1s→2p). P1 and P2 are therefore not blind. Blinding applies to P3–P6 and HO-1 at the original v0.1 freeze. |
| C2 | The v0.1 drafter did not retrieve HO-1. Recall of its approximate magnitude could not be excluded. |
| C3 | The v0.2 editor inspected the existing U0 source register before that freeze. That register contains prior CODATA 2022 values for \(m_e,m_p,a_0,hcR_\infty,\alpha^{-1}\), but no ASD level rows, H–D 1S–2S datum, or P1–P6/HO-1 model computation. S1 is therefore expressly a replication check, not a blind comparison. |
| C4 | CODATA values used for this run are retrieved anew in Phase 1 from the authoritative pages and bound there; no value is imported from memory or from C3. |
| C5 | The v0.3 parser rules were set from NIST ASD format documentation: grouping of levels with the Configuration and Term printed once per group; a Limit row marked in the Term column; blank Level cells for unlisted levels; digit-grouped integers in Level output as shown in a non-hydrogen spectrum; and tab-delimited output. No H I level row, ionization-limit value, or P1–P6 value was inspected in drafting v0.3. |

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

## 11. v0.4 delta

v0.1, v0.2, and v0.3 remain retained. v0.4 adds no result and changes no model, observable, tolerance, selector, or failure rule. It preserves the v0.3 ASD rules except for T2: an `="…"` formula wrapper is now a format-mismatch refusal rather than an accepted cell wrapper. This prevents a CSV-formula representation from entering a tab-delimited raw-response run.
