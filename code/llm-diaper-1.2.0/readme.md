# LLM Diaper — rash-free FLA zero-noise kernel (v1.2.0)

An output gate for language models. It sits at the exit, passes only lines it can prove, and returns typed silence for everything else. Standard library only, Python 3.10+, no network.

Noise upstream is allowed. Nothing unproven leaves. The model, its weights and its generation are not touched.

## What it does

A candidate answer goes in. Each line is checked:

- **Arithmetic** (`2 + 2 = 4`): evaluated as exact rationals. `0.1 + 0.2 = 0.3` passes; `2 + 2 = 5` does not.
- **Keyed reference** (`Answer: Paris`): the whole value must match an externally supplied reference, or one of a list of accepted values.
- **Anything else** (prose, variables, chained equations): unproven.

If every line is proven, the candidate is emitted unchanged. If any line is not, **nothing** is emitted.

"Zero noise", as meant here: inside the supported grammar, no line is delivered without proof. It does not make the model correct, and it cannot check claims that have no reference or equation behind them.

## Quick start

```bash
python fla.py verify                                   # algebra and modular identities
python fla.py gate '2 + 2 = 4'                         # delivered, exit 0
python fla.py gate '2 + 2 = 5'                         # withheld, exit 1
python fla.py gate 'Answer: Paris' --references trusted.json
python example_wrap.py                                 # retry wrapper with a stub model
python -m unittest -v test_fla.py test_wrap.py         # 25 tests
```

Install as a package (optional): `pip install .` gives the `fla` command and the `fla` and `fla_wrap` modules.

## Typed silence

Silence is not one thing, and an empty string does not say which.

| `silence` | Meaning | `accepted` | `emitted_text` |
|---|---|---|---|
| `null` | Every line proven; delivered | `true` | the candidate |
| `"neutral"` | Blank candidate: nothing was owed | `true` | `""` |
| `"withheld"` | Output was present and not fully proven (∅: no admissible continuation) | `false` | `""` |

Each line also carries a gate value matching its status: `verified` → `can`, `contradicted` → `cannot`, `unverified` → `open`.

`withheld` is a failure to be handled (retry, escalate, tell the user). It is not a safe default. `neutral` is the only silence that means "nothing to do".

## Python API

```python
from fla import gate_text

result = gate_text(model_output, {"Answer": "Paris"})
if result["accepted"]:
    deliver(result["emitted_text"])        # "" when silence == "neutral"
elif result["silence"] == "withheld":
    handle(result["checks"])               # per-line status, gate, kind, match
```

Result fields: `accepted`, `emitted_text`, `silence`, `checks`, `tolerances`, `policy`. Each check has `line`, `status`, `gate`, `kind` (`arithmetic`, `reference`, `unsupported_equation`, `unstructured_text`) and, when verified, `match` (`exact`, `normalized`, `within_epsilon`). Arithmetic checks include `left_exact` and `right_exact`.

References are `{key: "value"}` or `{key: ["value", "other accepted value"]}`. Keys match exactly. A non-string, empty or non-list reference counts as no reference (`open`).

## Retry wrapper

`fla_wrap.run_gated(generate, prompt, references, max_attempts=3)` calls `generate(prompt)`, gates the reply, and on failure re-prompts with the gate value of each non-admitted line (and the computed values for failed arithmetic; reference values are not revealed). The model returns a full new answer each time because the gate judges the whole candidate.

```python
from fla_wrap import run_gated
out = run_gated(my_model, "Capital of France, then 2 + 2.", {"Answer": "Paris"}, ledger="wrap.jsonl")
# out["emitted_text"], out["silence"] (None or "withheld"), out["attempt_count"], out["attempts"]
```

`generate` is any `str -> str` callable. An empty model reply counts as a failed attempt, since the wrapper knows an answer was owed. Pass `ledger=` to record every attempt in the hash chain.

## Tolerances (opt-in)

Default is exact. Loosening is explicit, applies to values and equations only (never keys), and is written into `tolerances` on every result and receipt.

| Flag / field | Effect |
|---|---|
| `--fold-case` / `fold_case` | `paris` matches `Paris` |
| `--normalize-whitespace` / `normalize_whitespace` | runs of whitespace collapse |
| `--strip-thousands` / `strip_thousands` | `1,000` matches `1000` (`1,0000` does not) |
| `--epsilon 1/1000` / `epsilon` | equation passes when `\|left − right\| ≤ ε`; `match` is `within_epsilon` |

```python
from fractions import Fraction
from fla import gate_text, Tolerance
gate_text(text, refs, Tolerance(fold_case=True, epsilon=Fraction(1, 1000)))
```

## CLI reference

| Command | Purpose |
|---|---|
| `fla.py verify` | Check the algebra and modular identities |
| `fla.py audit TEXT [--steps N]` | Encode, transport by B^N, mirror back, confirm byte-exact round trip (\|N\| ≤ 256) |
| `fla.py check EQUATION [--epsilon E]` | One equation, exact |
| `fla.py claims FILE` | Compare `claims` to `references` from a JSON file: verified / contradicted / unverified |
| `fla.py gate TEXT [--references FILE] [tolerance flags]` | The output gate |
| `fla.py validate-ledger FILE` | Validate a hash-chained receipt file |
| `fla.py --version` | Print the version |

`audit`, `check`, `claims` and `gate` accept `--ledger FILE` to append a receipt. Exit codes: `0` passed (including neutral silence), `1` failed or withheld, `2` bad arguments.

## Deployment notes

- **Prompt for the grammar.** The gate only helps where the model is asked to answer in `key: value` lines and plain equations. Free prose is withheld every time.
- **References are the trust root.** A wrong reference is delivered as verified. Scope them per task and keep them outside the model's reach.
- **Retry budget.** `max_attempts` bounds latency and cost. After the last attempt the result is `withheld`; decide in the caller what the user sees.
- **Ledger.** Receipts are canonical JSON, SHA-256 chained, one per line. Blank lines are ignored; any edit, reorder or truncation is rejected. A chain detects edits only if the head hash is stored somewhere else. Appends are not locked, so use one writer per file. Receipts contain the checked text.
- **Receipt format.** `audit`, `check` and `claims` receipts are unchanged from 1.0. `gate` receipts gained `silence`, `tolerances`, and per-line `gate` and `match`.

## The algebra

Definitions: `Q = [[1,1],[1,0]]`, `Ω = [[0,1],[-1,0]]`, `G = [Q,Ω] = QΩ − ΩQ = [[-2,1],[1,2]]`, `B = Q²`. The opposite-sign Ω gives −G; every identity here holds for either sign, and this module fixes the one above.

Spine: address → gate → carrier → boundary → contact.

- **Address:** text → `z = (byte_length, int(b'\x01' + utf8_bytes))`. Injective; the empty string and NUL bytes round-trip. Byte fidelity, not a semantic embedding.
- **Gate:** transport by even powers of Q, `B = Q²`; forward and inverse powers are integer matrices.
- **Carrier:** `q_G(z) = zᵀGz` is preserved exactly under any `Bⁿ`. Integers only, no tolerance.
- **Boundary:** a claim is checked only against an explicitly supplied reference. No mixing across documents.
- **Contact:** optional hash-chained receipts.
- **Mirror:** `H = G/√5` is an exact normalized involution. `H Bⁿ H` is computed as `G Bⁿ G / 5` and checked equal to `B⁻ⁿ` entry by entry. This holds because `BᵀGB = G`, `G² = 5I`, and B is symmetric and unimodular; it is a consistency check on the algebra, not a separate transport mechanism.

`verify` checks `G = [Q,Ω]`, `det G = −5`, `G² = 5I`, signature (1,1), `B = Q²`, `BᵀGB = G`, `B·B⁻¹ = I`, the mirror identity at several powers, `4¹⁷ ≡ −1 (mod 137)` and `ord₁₃₇(4) = 34`.

## Limits

It cannot prove free-form natural-language claims, judge whether unreferenced output is true, or make a model generate correctly. Each class of assertion needs its own oracle; adding one extends the grammar and leaves the rule ("no proof, no emission") unchanged. It is a verification gate, not a harm policy, and it does not replace one.

## Files

| File | Purpose |
|---|---|
| `fla.py` | Validator, gate and CLI |
| `fla_wrap.py` | Retry wrapper |
| `example_wrap.py` | Runnable wrapper demo (stub model) |
| `test_fla.py`, `test_wrap.py` | Tests (25) |
| `trusted.json`, `example_claims.json`, `example_receipts.jsonl` | Examples |
| `pyproject.toml` | Packaging (`llm-diaper`, command `fla`) |
| `CHANGELOG.md`, `SHA256SUMS` | Release record |

License: none assigned yet. Add a `LICENSE` file before redistribution.
