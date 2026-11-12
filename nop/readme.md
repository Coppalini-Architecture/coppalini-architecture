# NOP Return / Memory Workbench — browser edition

Coppalini Architecture · version **0.2.0** · input schema **0.1**.

Open `index.html` directly in a modern browser with BigInt support, or serve this
directory as static files. The demo is embedded in `demo.js`: opening the page
from a local ZIP extraction requires no fetch request or local server.

## Workflow

1. Select **Load synthetic demo**, or choose **Metadata JSON** and **Paired
   observations CSV**. The expandable text boxes also accept pasted input.
2. Select **Validate & audit**.
3. Review the origin declaration, counts, qualifications, and exact result
   table. Filter by **Run** and select a sample to inspect its complete record.
4. Export **Audit JSON**, **Derived CSV**, and **Receipt JSON**.

All input processing takes place in the browser. The application contains no
upload, analytics, remote computation, or persistent browser-storage operation.
Hosted copies load their static assets normally; the Home, Architecture, and
document links navigate only when selected.

The source page links to `../docs/User_Manual.pdf`,
`../docs/Research_Briefing.pdf`, and `../docs/Formal_Note.pdf` for the ZIP layout.
A deployed copy at `/nop/` may retarget those links to `docs/` without changing
the arithmetic kernel. The Architecture navigation target is
`https://eulershiddenl.ink/architecture`.

## Cross-language acceptance checks

Requirements: Python 3.10 or newer and Node.js with BigInt support, both on PATH.
From the release root, which contains `nop_audit.py` and the `web/` directory:

```bash
PYTHONDONTWRITEBYTECODE=1 python -m unittest discover -s tests -p test_web_parity.py -v
```

The Python test runner invokes Node directly against the UMD `web/kernel.js`
module and compares it with `nop_audit.py`. It checks every exact row value,
interval bound, classification, endpoint normalization, and extra field, along
with metadata, warnings, counts, interpretation fields, and derived CSV.
Approximate eta values are compared with a numerical tolerance. The fixtures
include the current embedded synthetic example, randomized positive rational
intervals, interleaved runs, tied timestamps, all declared oxygen kinds,
multiline quoted CSV fields, duplicate JSON keys, and invalid metadata, numbers,
bounds, identities, ordering, headers, and CSV syntax.

The browser has explicit resource and metadata-number limits below. Admission
under those additional limits is browser-specific; the parity fixtures compare
the shared accepted input range and shared validation rules.

## Exact arithmetic and measurement scope

`kernel.js` uses normalized BigInt fractions for all CSV numerical inputs,
normalized quantities, interval calculations, and verdicts. Decimal notation,
scientific decimal notation, and integer fractions are accepted. NaN, infinity,
zero denominators, and nonpositive assay values are rejected.

Each run has one first baseline. Occurrence strictly increases; recorded time
is nondecreasing. Tied timestamps retain their separate occurrences and receive
an explicit warning. Submitted order is preserved, including interleaved runs.
Extra CSV columns are retained without becoming inference inputs.

Missing bounds mean a point as entered, without a biological certainty claim.
Baseline self-ratios cancel exactly. Other intervals use conservative positive
interval arithmetic. Oxygen comparison uses only the declared oxygen read.
The dry-inspired calculation is the nominal gas proxy `fio2 * pressure_kpa`.
An optional endpoint retains its declared assay, compartment, and same-run
baseline. HIF transfer is unassigned; no isoform, tissue equivalence, causal
mechanism, fitted biological parameter, or medical recommendation is inferred.

## Browser limits

- Each input file or entered UTF-8 text: at most **2 MiB**.
- Dataset: at most **5,000 data records**. The table pages 50 records at a time;
  exports include every audited record.
- Numeric CSV fields: at most **4,096 characters** after trimming.
- Scientific exponent magnitude: at most **10,000**.
- Metadata JSON integers: JavaScript's safe integer range,
  **−9,007,199,254,740,991 to 9,007,199,254,740,991**. Quote exact larger
  parameters as decimal or rational strings. Nonzero metadata numbers that
  would underflow to zero are rejected; quoted strings retain such values.
- FiO₂: fraction in **[0, 1]**. Absolute pressure: strictly positive **kPa**,
  with no upper pressure threshold. Zero dry-inspired oxygen is allowed when
  FiO₂ is zero; arterial/tissue oxygen and the assay quantities are positive.

These resource limits do not round the accepted CSV arithmetic. Eta alone is a
floating-point display approximation. Metadata numeric fields are not used as
exact assay inputs; the CSV carries those values as decimal/rational strings.

## Input identity and receipts

Unedited selected files retain the hash of their **original bytes**, including
CRLF line endings and any UTF-8 byte-order mark. The browser's display
normalization in a text box does not change that identity. Explicit text edits
switch the input to the edited UTF-8 bytes, with a corresponding source label.
The synthetic demo hashes its embedded UTF-8 strings.

WebCrypto computes SHA-256 for input and exported audit/CSV bytes when
available. Each hash carries `computed_in_browser` or `unavailable`; an
unavailable digest is recorded as null. The receipt includes the version,
counts, source identities, and the separate browser execution scope.

The running kernel's bytes are not independently read or hashed by this page.
Its provenance therefore records `status: "not_measured_in_browser"` and
`sha256: null`. This receipt does not execute, hash, or attest the Python
kernel, and it does not certify assay validity or a biological mechanism.

Source strings are retained in exported CSV. Spreadsheet applications may
interpret formula-like text in untrusted fields; inspect such CSV as text when
preserving literal source content.
