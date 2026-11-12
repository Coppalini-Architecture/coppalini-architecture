# Empirical reference map

**NOP Return-Memory Workbench v0.2.0 · 12 November 2026**

The reference map binds each declared observable to its primary source, source location, assay, unit, compartment, normalization, sampling clock, data-access state, and software destination. The JSON contains the full source and correction registers; the CSV contains the same 68 observable records under the same stable IDs. The retained study audit is included in the JSON.

This correspondence is a traceable assignment of observed quantities. On the positive domain, an admitted assay pair has the invertible coordinate representation proved in `Formal_Note.tex`. A causal interpretation requires an experimentally supported observation law and predictions under specified interventions.

## Direct empirical interface

| Record | Source and location | Measurement identity | Sampling reference | Tool destination |
|---|---|---|---|---|
| `D17_ROS` | Donati 2017, Immunoassays; Table 4; Figure 2a | Serum hydroxyphenyl-fluorescein-reactive oxidant signal, RFU | Before exposure; end of 2 h exposure; 2 h after return | `ros`, with the RFU/serum/HPF assay declaration |
| `D17_GSH` | Donati 2017, Immunoassays; Table 4; Figure 2b | Reported serum glutathione, µM; Arbor K006-H1 | Same nominal redox schedule | `scavenger`, retaining the stated assay and unresolved processing mode |
| `D17_PAO2` | Donati 2017, Measurements; Table 1 | Arterial oxygen partial pressure, mmHg | Same nominal assessment schedule; pair the actual subject and draw | `oxygen`, kind `arterial_po2`, after a recorded conversion to kPa |
| `D17_EPO` | Donati 2017, Measurements; Table 2 | Serum EPO, IU/L | 08:00 baseline and 24/48 h later; exposure occurred within 10:00–14:00 | Separate timed endpoint table, linked by subject/run |
| `F21_GSH` | Fratantonio 2021, §5.3; Figure 4 | Intracellular reduced GSH in PBMC lysate, nmol/mg protein; DTNB assay | Baseline; 0.5, 3, 24 h after 1 h exposure | `scavenger`, retaining protein normalization |
| `F21_HIF1` | Fratantonio 2021, §5.2; Figure 1 | Nuclear PBMC HIF-1α immunoblot, baseline-relative fold | Same nominal post-exposure schedule | Separately declared `endpoint`; raw normalization and sample pairing required |
| `F21_ROS` | Fratantonio 2021, Discussion | Direct ROS assay unmeasured | No observed ROS sample | Remains unmeasured; no empirical `ros` value can be imported |

Sources: [Donati et al.](https://doi.org/10.1186/s12871-017-0342-2), [Fratantonio et al.](https://doi.org/10.3390/ijms22010458). Exact table URLs and additional measured endpoints are in the JSON/CSV.

Donati provides the direct study-level location for both assay channels. Application requires the participant-level pairing, baseline identities, actual draw and oxygen-switch times, and assay records. Table 4 group summaries and Figure 2 aggregate summaries do not supply that pairing. The current release contains no participant-level dataset from these studies.

## Status and binding

| Status | Meaning |
|---|---|
| `measured` | The source reports acquisition of the observable. This does not establish possession of participant-level data. |
| `computed` | A defined calculation or representation of measurements or protocol settings. Its inputs retain their own status. |
| `unmeasured` | The named study reports no direct measurement of the required observable. |
| `unresolved` | A necessary assay identity, value, timing, linkage, or parameter remains unestablished. |

`import_ready=false` records the current release state: no literature-derived participant row is supplied for import. `conditional` identifies an eligible destination once its requirements are met. `extra_field_only` retains auxiliary quantities without assigning them a model role. `endpoint_evidence_only` identifies outcome evidence whose study does not supply the paired assay inputs required by the CSV interface. Model definitions remain distinct from fitted biological parameters.

Each endpoint dataset has one declared assay identity. HIF-1α, NRF2, NF-κB, EPO, reticulocytes, and hemoglobin therefore occupy separate measurement declarations even where the software destination is named `endpoint`. Endpoint-only observations and outcomes collected later remain in a linked source table. An endpoint is attached to an imported redox row only when its time and sample relationship are established.

## Source corrections that affect an import

- **Glutathione identity:** Donati reports GSH in µM and identifies K006-H1. The paper does not specify the laboratory branch needed to establish reduced versus total glutathione independently. Current [manufacturer guidance](https://www.arborassays.com/questions/how-do-i-prepare-my-samples-for-gsh-measurement/) describes distinct processing steps, but the historical processing record is still required. The entered value remains the specified glutathione assay; total scavenging capacity is unmeasured.
- **Normalization:** Donati Table 4 reports absolute GSH with an overall time-test p-value of 0.114; Figure 2 and its discussion use individual-baseline normalization and a later-versus-earlier contrast. These are distinct estimands. Group medians, IQRs, SDs, and SEMs do not become individual readings or measurement bounds.
- **Return condition:** Donati returned patients to their individual baseline inspired oxygen fraction. The import retains that baseline instead of assigning room air.
- **Pressure:** The hyperbaric arm in Fratantonio used pure oxygen. Its gas fraction is 1; pressure has a separate field. The paper uses both bar and ATA labels, so the chamber record is required to settle the numerical pressure. Exposure settings belong to the exposure interval; recovery samples require their contemporaneous gas and pressure record.
- **Fratantonio timing and GSH:** Methods/figures specify 3 h, while one discussion sentence says 4 h. Methods §5.3 and Figure 4 identify intracellular reduced GSH, while the §2.4 heading says plasma total glutathione. Figures 4–5 caption wording and §5.5 also leave a baseline-scale discrepancy. The map retains these flags and requests the raw record.
- **Endpoint compartment:** Nuclear PBMC HIF-1α and circulating EPO have separately identified compartments, clocks, and functions. The source map retains the renal HIF-2 evidence as mechanistic context, with its own species and experimental scope.

The JSON contains all 19 corrections, including review-to-primary protocol discrepancies and distinctions between within-group and between-group outcomes. [The 2023 review](https://doi.org/10.3390/ijms24010082) supplies the target question; primary reports supply the measurement contracts.

## Import requirements

An empirical import needs the original paired observations and baselines; subject/run and sample identities; occurrence order and actual timestamps; the declared oxygen channel; positive assay values and their units, compartments and methods; gas fraction and absolute pressure records; and any justified uncertainty intervals. Raw references and conversion rules travel with the data.

For `dry_inspired_po2`, the tool computes nominal dry-gas partial pressure as `fio2 * pressure_kpa`; an explicitly supplied value must agree. For `arterial_po2` or `tissue_po2`, `oxygen` is the independently supplied measurement in kPa. Inspired gas, arterial blood, tissue oxygen, and tissue saturation retain their separate measurement identities. Participant records from different studies are never combined into a synthetic subject trajectory.

With admitted values, the exact normalized pair is `r=R/R0`, `a=A/A0`; the retained coordinate pair is `q=r/a`, `scale_squared=r*a`. Their positive inverse recovers both normalized assay readings. The raw ordered record retains sample history. Evidence of causal mediation requires prespecified sign, timing, perturbation, and outcome predictions beyond this coordinate identity.
