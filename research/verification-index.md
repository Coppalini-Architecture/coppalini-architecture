# Reader verification index

Coppalini Architecture · 12 November 2026

[Registry index](https://eulershiddenl.ink/research/registry-index.json) · [Reader contract v1.2.0](https://eulershiddenl.ink/research/reader-contract.json)

Each source registry retains its own record identifiers, source edition, statements, results, and boundaries. This index supplies their current addresses and the historical snapshot they accompany.

## Source registers

| Source | Version or source date | Coverage | Evidence and reading surface |
| --- | --- | --- | --- |
| [Exact Reader registry](https://eulershiddenl.ink/exact/read-registry.json) | Schema 1.1.0; source updated 11 November 2026 | 3 records: `CA-ALG-001`, `COT-001`, `TBM-001` | [Exact Reader](https://eulershiddenl.ink/exact/); each record links its procedure, output, receipt, and boundary. |
| [Four Dual Forms physical claim register](https://eulershiddenl.ink/research/four-dual-forms-v0.3.json) | v0.3 | 5 claim records covering the shared root and four papers | [Verifier](https://eulershiddenl.ink/papers/four-dual-forms/source/verify_four_papers_v0_3.py) · [recorded result](https://eulershiddenl.ink/verification/four-dual-forms/verify_four_papers_v0_3.out). |
| [Released public registry](https://eulershiddenl.ink/research/public-claim-registry-v0.3.json) | v0.3; released 12 November 2026 | 5 artifact records: `B-2`, `S-5/05a`, `W-0`, `W-1`, `NDA-3` | [Audit Register](https://eulershiddenl.ink/verify) · [verification manifest v0.3](https://eulershiddenl.ink/research/verification-manifest-v0.3.json). |
| [Archived R28 preparation metadata](https://eulershiddenl.ink/research/claims.json) | Schema 1.0.0; source registry dated 5 November 2026 | 7 historical claim records with their source-owned statuses | [Original index snapshot](https://eulershiddenl.ink/research/verification-index-r28-snapshot-2026-11-11.md), preserved on 11 November 2026. |

The source-relative paths in the Four Dual Forms and released public registries resolve against `https://eulershiddenl.ink/`. The machine-readable registry index supplies that canonical base explicitly.

## Read the evidence at its recorded operation

- **Expected output:** the declared target used to check a calculation, available before execution.
- **Recorded result:** a saved execution result or receipt bound to its named source, implementation, inputs, and scope.
- **Current execution:** the result produced by the present run on its identified inputs and loaded implementation, with the observed run status.

A source record can supply expected output and a saved receipt. The current execution supplies its own result. The [reader contract](https://eulershiddenl.ink/research/reader-contract.json) documents the distinct source schemas and preserves each field's meaning.

## Edition and correction records

Each claim remains bound to its named source edition. A successor edition receives its own status after its source, proof location, and verification receipt are inspected. Website release labels, registry schema versions, artifact versions, and manuscript editions identify their own objects.

A correction names the claim or artifact ID, source edition, exact statement, evidence under review, witnessed difference, and correction receipt. Earlier references remain available.

## Historical repair records

- [Condition & Constraint phase repair R1 receipt](https://eulershiddenl.ink/verification/condition-constraint-phase-repair-r1.md) · [historical artifact manifest](https://eulershiddenl.ink/verification/condition-constraint-phase-repair-r1-manifest.json).
- [Condition & Constraint integer-carrier repair R1 receipt](https://eulershiddenl.ink/verification/condition-constraint-integer-carrier-repair-r1.md) · [historical artifact manifest](https://eulershiddenl.ink/verification/condition-constraint-integer-carrier-repair-r1-manifest.json).

These manifests identify the artifacts at their recorded repair editions. Current files and subsequent changes retain their own source and verification records.

## Preserved navigation

- [Reader contract v1.1.0](https://eulershiddenl.ink/research/reader-contract-v1.1.0.json), effective 7 November 2026.
- [R28 preparation index snapshot](https://eulershiddenl.ink/research/verification-index-r28-snapshot-2026-11-11.md), including its original dates, wording, and link addresses. The source-register table above supplies the maintained navigation.
