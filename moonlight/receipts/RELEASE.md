# MOONLIGHT receipt implementation release v0.1

This public release carries HARMONIZER-001 and RELAX-RECEIPT-001. The supplied
mathematical records remain byte-preserved draft references under `records/`.
`release.json` binds the active implementations, the preserved upstream bytes,
the browser adapter, and this release record.

## Carried correction

RELAX-RECEIPT-001 supersedes the earlier assistant O-X6 artifact for this release.
The supplied contract uses `phase_step: 2`, `non_expansion`, its exact rule
strings, schedule index 2 through 300, and input offset in [-1/2, 1/2).
Recorded output offsets may include both endpoints. Its check flags assert the
recomputed transition; complete recorded differences are retained in `delta`.

The harmonizer canonical-fraction correction rejects `"-0/1"` in both ports.
Both Python implementations are the exact supplied bytes.

Prepublication review witnessed a reader-label difference: Python `str.strip()`
and JavaScript `trim()` classify some whitespace differently. The two release
JS files now use Python's explicit 29-codepoint whitespace class for the blank
label predicate. Nonblank labels remain unchanged. This is the only change to
the supplied calculation modules. Upstream JS bytes remain under `upstream/`;
the exact change is `verification/label-parity.patch`. Active JS pins are in
`release.json`; the historical records retain their original source pins.

## Verification

The supplied self-checks and independent tests passed. Corrected ports retain
3,000 value matches each, 1,200 harmonizer and 4,000 relax receipt-text matches,
and 8 + 12 lexical forms. The added label regression passes 88 cases.
Exact results and source hashes are retained in `verification.json`.

Portable verification files resolve the adjacent `sources/` directory. The
parity harnesses additionally assert the comparisons that their supplied
versions printed. Original verification scripts remain under `upstream/`.
The browser bundle isolates the two CommonJS modules and carries their exact
release source bodies. Raw text reaches each module's lexical checker before
parsing.

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
and operator-receipt source choices remain outside this release.

`relax.py` was not attached; its `ab419f8f23ef6a6e` prefix is retained as reported
in RELAX-001, rather than presented as a source byte check from this release.
