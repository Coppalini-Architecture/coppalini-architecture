"""Retry wrapper for the FLA gate: generate -> gate -> feedback -> regenerate.

The wrapper never edits model output. It delivers a candidate only when `fla.gate_text`
admits every line, otherwise it feeds the per-line gate values back to the model and asks
for a fresh full answer, up to `max_attempts`. If nothing is admitted the result is typed
silence ("withheld"), not an empty success.

`generate` is any callable taking a prompt string and returning the model's text.
"""
from __future__ import annotations

from pathlib import Path
from typing import Any, Callable, Mapping

import fla

GRAMMAR_NOTE = (
    "Reply only with lines of the form `key: value` or complete arithmetic equations `a = b`. "
    "Keep lines that were admitted. Fix or remove every other line. Return the full answer."
)


def feedback_prompt(prompt: str, result: Mapping[str, Any]) -> str:
    """Original prompt plus the gate values of the previous attempt. Reference values are not revealed."""
    lines = []
    for check in result["checks"]:
        if check["gate"] == "can":
            continue
        note = f'- "{check["line"]}": {check["gate"]} ({check["kind"]})'
        if check["kind"] == "arithmetic":
            note += f' computes to {check["left_exact"]} vs {check["right_exact"]}'
        lines.append(note)
    return f"{prompt}\n\nThe previous answer was withheld. Lines not admitted:\n" + "\n".join(lines) + f"\n\n{GRAMMAR_NOTE}"


def run_gated(
    generate: Callable[[str], str],
    prompt: str,
    references: Mapping[str, Any] | None = None,
    *,
    tolerance: fla.Tolerance = fla.EXACT,
    max_attempts: int = 3,
    ledger: str | Path | None = None,
) -> dict[str, Any]:
    """Returns {"emitted_text", "silence", "attempt_count", "attempts"}.

    silence is None when a candidate was admitted and "withheld" when no attempt was.
    An empty model reply counts as a failed attempt here, because the wrapper knows an
    answer was owed (the bare gate reads blank input as neutral silence).
    """
    if max_attempts < 1:
        raise ValueError("max_attempts must be at least 1")
    attempts: list[dict[str, Any]] = []
    current = prompt
    for number in range(1, max_attempts + 1):
        candidate = generate(current)
        if not candidate.strip():
            result: dict[str, Any] = {
                "accepted": False, "emitted_text": "", "silence": "withheld",
                "checks": [{"line": "", "status": "unverified", "kind": "empty_output", "gate": "open"}],
                "tolerances": tolerance.active(),
            }
        else:
            result = fla.gate_text(candidate, references, tolerance)
        attempt = {"attempt": number, "accepted": result["accepted"], "silence": result["silence"],
                   "checks": result["checks"], "tolerances": result["tolerances"]}
        attempts.append(attempt)
        if ledger is not None:
            fla.append_receipt(ledger, {"kind": "gate_attempt", **attempt})
        if result["accepted"]:
            return {"emitted_text": result["emitted_text"], "silence": None, "attempt_count": number, "attempts": attempts}
        current = feedback_prompt(prompt, result)
    return {"emitted_text": "", "silence": "withheld", "attempt_count": max_attempts, "attempts": attempts}
