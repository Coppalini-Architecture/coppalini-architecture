# MOONLIGHT draft receipt implementation v0.1 — verification pending

The carried HARMONIZER-001, RELAX-001, and RELAX-RECEIPT-001 records remain
`DRAFT, local`: not released, pinned, or gated. This route preserves their
current implementation bytes and test material for inspection. It does not
promote those records or establish a closed receipt endpoint.

`release.json` is the implementation manifest: it binds the active source
bytes, preserved upstream bytes, browser adapter, and this status record.

## Current implementation and known gaps

The current Relax contract uses `phase_step: 2`, `non_expansion`, schedule
index 2 through 300, and input offset in `[-1/2, 1/2)`. The present code has
not yet closed its whole stated literal domain:

- An admitted 200-character Relax input fraction can produce a 324-character
  recomputed fraction. `make_receipt()` then constructs a receipt that its own
  checker returns as `INVALID` because output fractions are capped at 200
  characters.
- An admitted 64-character Harmonizer decimal can similarly produce derived
  fraction fields longer than the 200-character cap, and its own honest
  receipt is rejected.
- The raw-text ports do not yet reject duplicate JSON object members and
  normalize raw numeric `-0` through `JSON.parse`; a future source revision
  must supply canonical raw-text handling.

The source-byte and label-parity work remains useful provenance, but it does
not close those gaps. The missing `relax.py` byte named by RELAX-001 also
remains unavailable and unverified here.

## Narrow checks that passed

The supplied self-checks and independent tests passed at their stated sampled
scope: 3,000 value matches each, 1,200 Harmonizer and 4,000 Relax receipt-text
comparisons, 8 plus 12 listed lexical forms, and 88 label regressions. Those
results are retained in `verification.json`; they are not a complete-domain
promotion.

Portable verification files resolve the adjacent `sources/` directory. The
browser bundle isolates the two CommonJS modules and carries their active
source bodies. Original supplied scripts remain under `upstream/`.

```bash
python3 -I sources/harmonizer.py
python3 -I sources/relax_receipt.py
python3 -I verification/test_independent.py
python3 -I verification/test_relax_receipt.py
python3 -I verification/parity.py
python3 -I verification/parity_relax.py
python3 -I verification/test_reader_label_parity.py
```

## Preserved boundary

Receipt checking is display-side and one-way. It reads no clock coordinate,
captures no reader identity, touches no Ground record, and updates no MOONLIGHT
mirror state. The exact phase-reader and Dome artifacts retain their prior pins.

The O-Q4 callable block is supplied as `sources/reader_ledger_relax.py`, with
`check_relax_receipt(receipt)` returning the existing three verdict strings.
Registration in the owner's unavailable `reader_ledger.py` remains OPEN.
The held `fd020d0` work and the unresolved negative-phase, range-compression,
and operator-receipt source choices remain outside this draft.

`relax.py` was not attached; its `ab419f8f23ef6a6e` prefix is retained as reported
in RELAX-001, rather than presented as a source byte check from this draft.
