# An exact observation interface for the Normobaric Oxygen Paradox

**NOP Return-Memory Workbench v0.2.0 · Research briefing · 12 November 2026**

## The research question

The Normobaric Oxygen Paradox literature asks how a return from elevated oxygen can be followed by responses associated with hypoxia. Its proposed redox explanation gives oxidant signals and antioxidant responses different recovery times. The 2023 review identifies the resulting questions about ROS, HIF regulation, exposure timing, and downstream erythropoietin. Those questions require a record that distinguishes the present oxygen measurement, the measured assay state, and the preceding exposure. [1]

This release supplies that observation interface. It connects a declared pair of positive oxidant and antioxidant assay readings to Metric Mirror coordinates through an explicit invertible map. It preserves the measured quantities, their baselines, sample identities, occurrence order, uncertainty bounds, and source references. The completed mathematical result makes the question precise: **when the declared oxygen read returns, which measured coordinates remain different, and what later response do they predict?**

## What has been established

Let `R` and `A` denote the two specified assay readings, with positive paired baselines `R0` and `A0`. The workbench computes

\[
r=R/R_0,\qquad a=A/A_0,\qquad q=r/a,\qquad p=ra.
\]

The pair `(q,p)` recovers both positive normalized readings: `r=√(qp)` and `a=√(p/q)`. Contrast and magnitude therefore preserve the full numerical assay pair. The Formal Note proves its explicit transport to the established Metric Mirror operators, including mirror inversion of the ratio and preservation of the product. Independent multiplicative unit changes cancel under the retained baseline normalization. A changed baseline remains a recorded change of reference. [5]

The same note proves an exact return-with-memory theorem for the declared adaptation law `τ da/dt=r−a`. Under a constant drive during each interval, its sampled update is `a_next=λa+(1−λ)r`, with `λ=exp(−Δ/τ)`. A finite elevated pulse leaves a positive retained state after the drive returns. The theorem includes the switch, interval composition, and finite recovery. The assay drive, physical oxygen channel, and biological rate each keep their own assignment. Human kinetic parameters remain to be identified. [5]

The implementation retains exact rational arithmetic for entered decimal or fractional values and propagates supplied positive bounds. Equal entered oxygen readings establish a recorded return at that resolution; overlapping intervals establish compatibility with return. The original ordered data remain part of the receipt. Coordinate recovery recovers the declared pair; the retained record supplies the observed history. [5]

## The measured connection

Donati and colleagues provide the most direct empirical location for the two assay channels. Their 2017 study measured serum HPF-reactive oxidant fluorescence in RFU and reported serum glutathione in µM. Sampling occurred before a two-hour hyperoxic exposure, at its end, and two hours after return to each patient's baseline inspired oxygen fraction. The source reports a transient oxidant rise and a subsequent glutathione change using individual-baseline normalization. Its absolute-value and normalized comparisons retain their separate estimands. [2]

Those two measurements can enter `ros` and `scavenger` once paired participant records, actual times, baselines, and laboratory metadata are available. The glutathione assay retains its concentration identity. Its reduced-versus-total processing needs confirmation from the historical laboratory record. EPO was collected on a separate 08:00 baseline/+24 h/+48 h schedule, so later EPO remains a separately timed outcome. [2]

Fratantonio and colleagues add nuclear PBMC HIF-1α, NRF2, and NF-κB measurements, together with intracellular reduced GSH. Their methods specify baseline and 0.5, 3, and 24-hour recovery samples after one hour of oxygen exposure. They explicitly report that ROS was not directly measured. Their GSH and transcription-factor data therefore identify useful assay and endpoint channels while leaving the paired oxidant input open. [3]

The reference map provides 68 individually identified observable records, 15 sources, and 19 source corrections. It retains gas fraction separately from pressure, source timing discrepancies, compartment assignments, assay normalization, and data access. Each endpoint has one measurement identity. Existing positive and contrary EPO findings remain in the study audit with their protocols and comparison groups. [2–4]

## Testable use

With paired data, the interface can compare samples that share a declared oxygen reading but follow different exposure histories. Both contrast and magnitude are retained, so common movement of the assays remains visible. Prespecified analyses can then ask whether measured state and history improve prediction beyond present oxygen and relevant covariates, using held-out subjects or sequences.

The adaptation hypothesis makes a further commitment: under its stated drive and sampling assumptions, recovery follows its specified lag and trajectory. Systematic departures can reject that model for the chosen assay and domain. Assigning a ROS-to-HIF mechanism requires additional observations or perturbations that discriminate the proposed direction, delay, and mediation. HIF isoform, compartment, and downstream outcome remain explicit in that test.

The release establishes a reproducible mathematical and computational interface for this work. Participant datasets are still to be obtained through the primary studies' stated access routes. The packaged numerical demonstrations are identified as synthetic; this release reports no participant-level fit or newly established physiological mechanism. The source map makes the next empirical calculation concrete, reviewable, and repeatable.

## References

1. Salvagno et al. (2023), *The Normobaric Oxygen Paradox—Hyperoxic Hypoxic Paradox*, §3.2 and Figure 2. https://doi.org/10.3390/ijms24010082
2. Donati et al. (2017), *Effects of short-term hyperoxia on erythropoietin levels and microcirculation in critically ill patients*, Methods, Tables 1–4, Figure 2. https://doi.org/10.1186/s12871-017-0342-2
3. Fratantonio et al. (2021), *Increasing Oxygen Partial Pressures Induce a Distinct Transcriptional Response in Human PBMC*, §§2, 3, 5.1–5.5. https://doi.org/10.3390/ijms22010458
4. `Empirical_Reference_Map.json` and `.csv`, this release: individual primary-source locations, retained study audit, corrections, and access state.
5. Coppa, *An Exact Observation Interface for the Normobaric Oxygen Paradox*, `Formal_Note.tex` / `Formal_Note.pdf`, this release; `nop_audit.py` and `model.py`.
