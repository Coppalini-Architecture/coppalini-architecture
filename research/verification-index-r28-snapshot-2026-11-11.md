# Reader verification index

Coppalini Architecture · 5 November 2026 · Metadata companion for the R28 target edition.

Read [reader-contract.json](reader-contract.json) before assigning claim strength. Read [claims.json](claims.json) for individual status and source ownership. A citation to a later edition requires checking the text of that edition.

## Exact Reader

The [Exact Reader registry](../exact/read-registry.json) carries source-indexed deterministic checks with their declared inputs, procedures, outputs, receipts, and boundaries. Each record preserves the scope stated by its source.

## Source owners

- Minimum root algebra: `Coppalini-Architecture/coppalini-architecture/papers/02 MINIMUM_ROOT_ALGEBRA_Source_Consolidation_Map_v0_1 (1).md`, sections IV–V and XIV.
- Relativity/gravity/cosmology: `papers/06 RELATIVITY_GRAVITY_COSMOLOGY_Field_Source_Ownership_v0_2.md`, sections XIV–XV.
- Standard Model: `papers/09 QFT_STANDARD_MODEL_ELECTROWEAK_QCD_Field_Source_Ownership_v0_1.md`, sections XXXIX and XLIV.
- Atomic and molecular: `papers/11 ATOMIC_MOLECULAR_CHEMISTRY_Hamiltonian_Fibers_and_Minimum_Complex_Models_v0_1.md`, sections II–III and XXV–XXVII.
- Ultraviolet TT reader: `papers/Ultraviolet_Fixed_Point_Closure_Minimum_TT_Reader_v0_6 (1).md`, section XII.
- Prior capstone: `papers/theory-of-everything-contact-record-r27.pdf` on eulershiddenl.ink.

All repository paths in the first five bullets are relative to https://github.com/Coppalini-Architecture/coppalini-architecture/ .

## Edition control

The prior capstone edition was R27. This registry is an initial reader-facing bridge toward R28; claims are source-bound to verified archive references and do not certify that a subsequent edition proves or disproves a new physical result. Promote a claim to an R28-specific status only after recording the exact R28 source URL, version checksum, proof location, and check receipt. Keep any earlier open dependency as an earlier historical status when a later proof closes it.

## Physical evidence duties

Each physical theory retains its own equations, state space, scale, parameters, observables, calibration, and independent evaluation. A source-indexed adapter establishes its actual mapping properties; a physical identification and numerical prediction require their own witness.

## Correcting a reader's interpretation

Provide the claim ID, manuscript edition, exact statement, cited source text, interpretation under review, missing or added logical step, and correction receipt. Keep original version references.

## November 7 paper additions: Three-Body Mirror and Condition Of Trust

- [The 3 Body Mirror](../papers/the-3-body-mirror.pdf): exact Newtonian mirror symmetry; specified Fibonacci conjugacy on the selected hyperbolic sector; stable/unstable cross; nonzero local fourth-order obstruction. [Symbolic receipt](../verification/the-3-body-mirror/verification-symbolic.txt) · [independent audit](../verification/the-3-body-mirror/verification-independent.txt) · [verifier source](../verification/the-3-body-mirror/verify_euler_birkhoff_c1.py) · [audit source](../verification/the-3-body-mirror/audit_c1.py). Astronomical and biological identifications remain open.
- [The Condition Of Trust](../papers/the-condition-of-trust.pdf): finite reference, reader, decision, receipt, and stopping tests. [Verifier](../verification/the-condition-of-trust/condition_of_trust_verify.py) · [successful finite checks](../verification/the-condition-of-trust/verification-output.txt) · [build receipt](../verification/the-condition-of-trust/condition_of_trust_receipt.md).
- [File hashes and source ownership](../verification/2026-11-07-mirror-trust-manifest.json).

## Condition & Constraint phase repair R1

- [Submitted-matrix repair receipt](../verification/condition-constraint-phase-repair-r1.md): the Python phase predicate now evaluates the submitted candidate matrix. The canonical phase passes; zero and identity submissions fold at the constraint gate. [Translator](../tools/condition_constraint_can_translator.py) · [audit output](../verification/condition-constraint-phase-repair-r1-audit.json) · [artifact manifest](../verification/condition-constraint-phase-repair-r1-manifest.json).

## Condition & Constraint integer-carrier repair R1

- [Exact-integer repair receipt](../verification/condition-constraint-integer-carrier-repair-r1.md): scalar float and boolean submissions, plus non-integer lift and phase matrices, fold before algebraic admission. [Translator](../tools/condition_constraint_can_translator.py) · [audit output](../verification/condition-constraint-integer-carrier-repair-r1-audit.json) · [artifact manifest](../verification/condition-constraint-integer-carrier-repair-r1-manifest.json).
